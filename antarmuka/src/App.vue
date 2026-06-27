<script setup>
import { computed, onMounted, onUnmounted, ref } from "vue";
import { ethers } from "ethers";
import contractInfo from "../../konektor/contract.json";

const HARDHAT_CHAIN_ID = "0x7a69";
const HARDHAT_RPC_URL = "http://127.0.0.1:8545";
const FALLBACK_PAKET = [
  [1, "Mobile Legends", "86 Diamonds", "50"], [2, "Mobile Legends", "172 Diamonds", "95"], [3, "Mobile Legends", "257 Diamonds", "140"], [4, "Mobile Legends", "Weekly Diamond Pass", "75"],
  [5, "Free Fire", "70 Diamonds", "40"], [6, "Free Fire", "140 Diamonds", "80"], [7, "Free Fire", "355 Diamonds", "180"],
  [8, "PUBG Mobile", "60 UC", "55"], [9, "PUBG Mobile", "325 UC", "250"], [10, "PUBG Mobile", "660 UC", "480"],
  [11, "Valorant", "475 VP", "120"], [12, "Valorant", "1000 VP", "240"], [13, "Valorant", "2050 VP", "460"],
].map(([id, game, nama, hargaText]) => ({ id, game, nama, hargaSmt: ethers.parseUnits(hargaText, 18), hargaText, aktif: true }));
const HARDHAT_NETWORK = {
  chainId: HARDHAT_CHAIN_ID,
  chainName: "Ethereum Hardhat Localhost",
  nativeCurrency: { name: "Ether", symbol: "ETH", decimals: 18 },
  rpcUrls: [HARDHAT_RPC_URL],
  blockExplorerUrls: [],
};

const account = ref("");
const saldoSmt = ref("0");
const game = ref("");
const paketId = ref("");
const userGameId = ref("");
const serverId = ref("");
const orders = ref([]);
const paketList = ref([]);
const status = ref("Belum terhubung");
const isConnecting = ref(false);
const isClaiming = ref(false);
const isBuying = ref(false);
const isAddingToken = ref(false);
const toast = ref(null);
const txDetail = ref(null);

const paketAktifList = computed(() => paketList.value.filter((item) => item.aktif && item.game === game.value));
const daftarGame = computed(() => [...new Set(paketList.value.filter((item) => item.aktif).map((item) => item.game))]);
const paketAktif = computed(() => paketAktifList.value.find((item) => String(item.id) === String(paketId.value)) ?? paketAktifList.value[0]);
const shortAccount = computed(() => account.value ? `${account.value.slice(0, 6)}...${account.value.slice(-4)}` : "Belum connect");
const totalOrderText = computed(() => `${orders.value.length} order`);
const formattedSaldoSmt = computed(() => formatSmt(saldoSmt.value));

function getErrorMessage(error) { return error?.shortMessage ?? error?.message ?? "Terjadi error"; }
function formatSmt(value) {
  const numberValue = Number(value);
  if (!Number.isFinite(numberValue)) return "0.00";
  return new Intl.NumberFormat("id-ID", { maximumFractionDigits: 2, minimumFractionDigits: 2 }).format(numberValue);
}
function shortHash(hash) { return hash ? `${hash.slice(0, 10)}...${hash.slice(-8)}` : "-"; }
function showToast(type, message) {
  toast.value = { type, message };
  window.clearTimeout(showToast.timer);
  showToast.timer = window.setTimeout(() => { toast.value = null; }, 4200);
}
function statusLabel(statusValue) { return ["Pending", "Processing", "Success", "Failed"][Number(statusValue)] ?? "Unknown"; }

async function getProvider() {
  if (!window.ethereum) throw new Error("Metamask belum terpasang");
  return new ethers.BrowserProvider(window.ethereum);
}
async function getContract(config, withSigner = false) {
  if (!withSigner) {
    return new ethers.Contract(config.address, config.abi, new ethers.JsonRpcProvider(HARDHAT_RPC_URL));
  }
  const provider = await getProvider();
  return new ethers.Contract(config.address, config.abi, await provider.getSigner());
}
async function switchToHardhat() {
  try {
    await window.ethereum.request({ method: "wallet_switchEthereumChain", params: [{ chainId: HARDHAT_CHAIN_ID }] });
  } catch (error) {
    if (error.code !== 4902 && !String(error.message).includes("Unrecognized chain ID")) throw error;
    await window.ethereum.request({ method: "wallet_addEthereumChain", params: [HARDHAT_NETWORK] });
    await window.ethereum.request({ method: "wallet_switchEthereumChain", params: [{ chainId: HARDHAT_CHAIN_ID }] });
  }
}
async function loadPaket() {
  try {
    const topup = await getContract(contractInfo.topup);
    const result = await topup.lihatSemuaPaket();
    paketList.value = result.map((item) => ({ id: Number(item.id), game: item.game, nama: item.nama, hargaSmt: item.hargaSmt, hargaText: ethers.formatUnits(item.hargaSmt, 18), aktif: item.aktif }));
  } catch (error) {
    paketList.value = FALLBACK_PAKET;
    status.value = "Paket fallback ditampilkan. Jalankan ulang npm start untuk deploy kontrak terbaru.";
  }

  if (!game.value && daftarGame.value.length) game.value = daftarGame.value[0];
  if (!paketId.value && paketAktifList.value.length) paketId.value = String(paketAktifList.value[0].id);
}
async function connectWallet() {
  try {
    isConnecting.value = true;
    if (!window.ethereum) { status.value = "Install Metamask dulu"; showToast("error", status.value); return; }
    await switchToHardhat();
    const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
    account.value = accounts[0];
    status.value = "Wallet terhubung ke jaringan Ethereum lokal";
    showToast("success", "Wallet terhubung");
    await loadSaldo(accounts[0]);
    await loadOrders();
  } catch (error) { status.value = getErrorMessage(error); showToast("error", status.value); }
  finally { isConnecting.value = false; }
}
async function loadSaldo(address = account.value) {
  if (!address) return;
  const token = await getContract(contractInfo.token);
  saldoSmt.value = ethers.formatUnits(await token.balanceOf(address), 18);
}
async function claimSmt() {
  try {
    isClaiming.value = true;
    const token = await getContract(contractInfo.token, true);
    status.value = "Claim SMT faucet..."; showToast("info", status.value);
    const tx = await token.claimFaucet();
    txDetail.value = { title: "Claim SMT", hash: tx.hash, state: "Pending" };
    await tx.wait();
    txDetail.value.state = "Success";
    status.value = "1000 SMT berhasil diklaim"; showToast("success", "1000 SMT masuk ke wallet");
    await loadSaldo();
  } catch (error) { status.value = getErrorMessage(error); showToast("error", status.value); }
  finally { isClaiming.value = false; }
}
async function addSmtToMetamask() {
  try {
    isAddingToken.value = true;
    const added = await window.ethereum.request({ method: "wallet_watchAsset", params: { type: "ERC20", options: { address: contractInfo.token.address, symbol: "SMT", decimals: 18 } } });
    showToast(added ? "success" : "info", added ? "SMT ditambahkan ke Metamask" : "Tambah token dibatalkan");
  } catch (error) { showToast("error", getErrorMessage(error)); }
  finally { isAddingToken.value = false; }
}
async function loadOrders() {
  try {
    const topup = await getContract(contractInfo.topup, true);
    orders.value = [...await topup.lihatOrderSaya()].reverse();
  } catch (error) { status.value = getErrorMessage(error); }
}
async function beliTopup() {
  try {
    isBuying.value = true;
    const selectedPaket = paketAktif.value;
    const token = await getContract(contractInfo.token, true);
    const topup = await getContract(contractInfo.topup, true);
    status.value = "Approve pembayaran SMT..."; showToast("info", status.value);
    const approveTx = await token.approve(contractInfo.topup.address, selectedPaket.hargaSmt);
    txDetail.value = { title: "Approve SMT", hash: approveTx.hash, state: "Pending" };
    await approveTx.wait();
    txDetail.value.state = "Success";
    status.value = "Membuat order topup..."; showToast("info", status.value);
    const tx = await topup.beliTopup(selectedPaket.id, userGameId.value, serverId.value);
    txDetail.value = { title: "Order Topup", hash: tx.hash, state: "Pending" };
    await tx.wait();
    txDetail.value.state = "Success";
    status.value = "Order topup berhasil dibuat"; showToast("success", "Order berhasil dibuat");
    userGameId.value = ""; serverId.value = "";
    await loadOrders(); await loadSaldo();
  } catch (error) { status.value = getErrorMessage(error); showToast("error", status.value); }
  finally { isBuying.value = false; }
}
async function restoreWalletSession() {
  try {
    if (!window.ethereum) return;
    await switchToHardhat();
    const accounts = await window.ethereum.request({ method: "eth_accounts" });
    if (!accounts.length) return;
    account.value = accounts[0]; status.value = "Wallet otomatis terhubung";
    await loadSaldo(accounts[0]); await loadOrders();
  } catch (error) { status.value = getErrorMessage(error); }
}
function onGameChange() { paketId.value = paketAktifList.value.length ? String(paketAktifList.value[0].id) : ""; }
function handleAccountsChanged([nextAccount]) { account.value = nextAccount ?? ""; orders.value = []; if (nextAccount) { loadSaldo(nextAccount); loadOrders(); } }
function handleOrderEvent() { if (account.value) { loadOrders(); loadSaldo(); showToast("info", "Data order diperbarui realtime"); } }

let eventContract;
onMounted(async () => {
  try { await loadPaket(); } catch (error) { status.value = getErrorMessage(error); }
  if (!window.ethereum) return;
  window.ethereum.removeListener?.("accountsChanged", handleAccountsChanged);
  window.ethereum.on?.("accountsChanged", handleAccountsChanged);
  eventContract = await getContract(contractInfo.topup);
  eventContract.on("OrderDibuat", handleOrderEvent);
  eventContract.on("StatusOrderDiubah", handleOrderEvent);
  restoreWalletSession();
});
onUnmounted(() => {
  window.ethereum?.removeListener?.("accountsChanged", handleAccountsChanged);
  eventContract?.removeAllListeners?.();
});
</script>

<template>
  <main class="container">
    <Transition name="toast"><div v-if="toast" :class="[`toast`, toast.type]">{{ toast.message }}</div></Transition>
    <section class="hero-shell">
      <div class="hero-copy">
        <p class="eyebrow">SMT Token Demo Store</p><h1>Top Up Diamond Game Pakai Token Web3.</h1>
        <p class="muted">Paket dan harga diambil langsung dari smart contract. Order dan perubahan status update realtime via event.</p>
        <div class="hero-actions">
          <button type="button" :disabled="isConnecting" @click="connectWallet">{{ isConnecting ? "Connecting..." : account ? "Wallet Connected" : "Connect Metamask" }}</button>
          <button class="ghost" type="button" :disabled="!account || isClaiming" @click="claimSmt">{{ isClaiming ? "Claiming..." : "Claim 1000 SMT" }}</button>
          <button class="ghost" type="button" :disabled="!account || isAddingToken" @click="addSmtToMetamask">{{ isAddingToken ? "Adding..." : "Add SMT" }}</button>
        </div>
      </div>
      <aside class="wallet-card"><div class="orb"></div><p class="label">Saldo Wallet</p><strong>{{ formattedSaldoSmt }} SMT</strong><span>{{ shortAccount }}</span><small>Token demo tanpa nilai asli</small></aside>
    </section>

    <section class="stats">
      <article><span>Token</span><strong>SMT</strong><p>Sampel Metaverse Token</p></article>
      <article><span>Paket</span><strong>{{ paketList.length }}</strong><p>Data dari smart contract</p></article>
      <article><span>Riwayat</span><strong>{{ totalOrderText }}</strong><p>Realtime event listener</p></article>
    </section>

    <section class="game-strip">
      <button v-for="namaGame in daftarGame" :key="namaGame" :class="['game-pill', { active: game === namaGame }]" type="button" @click="game = namaGame; onGameChange()"><span>{{ namaGame.slice(0, 2).toUpperCase() }}</span>{{ namaGame }}</button>
    </section>

    <section class="grid">
      <form class="card checkout-card" @submit.prevent="beliTopup">
        <div class="section-head"><div><p class="label">Checkout</p><h2>Detail Top Up</h2></div><span class="badge">On-chain Packages</span></div>
        <div class="form-grid">
          <label>Game<select v-model="game" @change="onGameChange"><option v-for="namaGame in daftarGame" :key="namaGame">{{ namaGame }}</option></select></label>
          <label>Paket<select v-model="paketId"><option v-for="item in paketAktifList" :key="item.id" :value="String(item.id)">{{ item.nama }} - {{ formatSmt(item.hargaText) }} SMT</option></select></label>
          <label>User ID Game<input v-model="userGameId" placeholder="Contoh: 123456789" required /></label>
          <label>Server ID / Zone ID<input v-model="serverId" placeholder="Contoh ML: 1234" /></label>
        </div>
        <div class="summary-box">
          <div><span>Game</span><strong>{{ game }}</strong></div><div><span>Paket</span><strong>{{ paketAktif?.nama ?? "-" }}</strong></div><div class="total-row"><span>Total bayar</span><strong>{{ formatSmt(paketAktif?.hargaText) }} SMT</strong></div>
        </div>
        <button class="wide" type="submit" :disabled="!account || isBuying || !paketAktif">{{ isBuying ? "Memproses..." : "Beli Sekarang" }}</button><p class="status">{{ status }}</p>
      </form>

      <aside class="side-stack">
        <section v-if="txDetail" class="card mini-card tx-card"><div class="section-head compact"><div><p class="label">Transaksi</p><h2>{{ txDetail.title }}</h2></div><span class="badge">{{ txDetail.state }}</span></div><div class="tx-line"><span>{{ shortHash(txDetail.hash) }}</span><button class="small" type="button" @click="navigator.clipboard.writeText(txDetail.hash); showToast('success', 'Tx hash disalin')">Copy</button></div></section>
        <section class="card mini-card"><div class="section-head compact"><div><p class="label">Wallet</p><h2>Akun Aktif</h2></div><button class="small" type="button" :disabled="isConnecting" @click="connectWallet">{{ isConnecting ? "..." : account ? "Reconnect" : "Connect" }}</button></div><div class="wallet-line"><span>{{ shortAccount }}</span><b>{{ formattedSaldoSmt }} SMT</b></div></section>
        <section class="card mini-card"><div class="section-head compact"><div><p class="label">Riwayat</p><h2>Order Saya</h2></div><button class="small" type="button" :disabled="!account" @click="loadOrders">Refresh</button></div><div class="orders"><p v-if="orders.length === 0" class="muted">Belum ada order.</p><article v-for="order in orders" v-else :key="order.id.toString()" class="order"><div><div class="order-title"><strong>#{{ order.id.toString() }} {{ order.game }}</strong><em :class="[`status-badge`, `status-${Number(order.status)}`]">{{ statusLabel(order.status) }}</em></div><span>{{ order.paket }}</span><span>ID: {{ order.userGameId }}{{ order.serverId ? ` (${order.serverId})` : "" }}</span></div><b>{{ formatSmt(ethers.formatUnits(order.hargaSmt, 18)) }} SMT</b></article></div></section>
      </aside>
    </section>

    <section class="steps"><article><b>1</b><strong>Paket On-chain</strong><span>Harga dibaca dari kontrak.</span></article><article><b>2</b><strong>Realtime</strong><span>Event update order otomatis.</span></article><article><b>3</b><strong>Tx Detail</strong><span>Hash bisa dicopy.</span></article></section>
  </main>
</template>

