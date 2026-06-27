import { spawn } from "node:child_process";

const env = { ...process.env, HARDHAT_TELEMETRY_DISABLED: "true" };
const processes = [];
let shuttingDown = false;

function run(name, command) {
  const child = spawn(command, { shell: true, env, stdio: ["inherit", "pipe", "pipe"] });

  child.stdout.on("data", (data) => process.stdout.write(`[${name}] ${data}`));
  child.stderr.on("data", (data) => process.stderr.write(`[${name}] ${data}`));
  child.on("exit", (code) => {
    if (code && !shuttingDown) {
      console.error(`[${name}] exit ${code}`);
      shutdown(code);
    }
  });

  processes.push(child);
  return child;
}

function runOnce(name, command) {
  return new Promise((resolve, reject) => {
    const child = spawn(command, { shell: true, env, stdio: ["inherit", "pipe", "pipe"] });
    child.stdout.on("data", (data) => process.stdout.write(`[${name}] ${data}`));
    child.stderr.on("data", (data) => process.stderr.write(`[${name}] ${data}`));
    child.on("exit", (code) => (code === 0 ? resolve() : reject(new Error(`${command} exit ${code}`))));
  });
}

function waitForOutput(child, matcher, timeoutMs) {
  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => reject(new Error("Hardhat node timeout")), timeoutMs);

    function onData(data) {
      if (matcher(data.toString())) {
        clearTimeout(timeout);
        child.stdout.off("data", onData);
        resolve();
      }
    }

    child.stdout.on("data", onData);
  });
}

function shutdown(code = 0) {
  shuttingDown = true;
  for (const child of processes) child.kill("SIGINT");
  process.exit(code);
}

process.on("SIGINT", () => shutdown(0));
process.on("SIGTERM", () => shutdown(0));

async function main() {
  const hardhat = run("hardhat", "npm run node");
  await waitForOutput(hardhat, (output) => output.includes("127.0.0.1:8545"), 30000);
  await runOnce("deploy", "npm run deploy:local");
  run("frontend", "npm run dev");
}

main().catch((error) => {
  console.error(error.message);
  shutdown(1);
});
