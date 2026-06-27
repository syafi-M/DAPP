import { expect } from "chai";
import hre from "hardhat";

const { ethers } = hre;

describe("GameTopup", function () {
  async function deployFixture() {
    const [owner, pembeli, orangLain] = await ethers.getSigners();
    const SMTToken = await ethers.getContractFactory("SMTToken");
    const smtToken = await SMTToken.deploy();
    const GameTopup = await ethers.getContractFactory("GameTopup");
    const gameTopup = await GameTopup.deploy(await smtToken.getAddress());
    return { owner, pembeli, orangLain, smtToken, gameTopup };
  }

  it("membaca paket on-chain", async function () {
    const { gameTopup } = await deployFixture();
    const paket = await gameTopup.lihatSemuaPaket();
    expect(paket.length).to.equal(13);
    expect(paket[0].game).to.equal("Mobile Legends");
    expect(paket[0].hargaSmt).to.equal(ethers.parseUnits("50", 18));
  });

  it("membuat order topup dengan token SMT", async function () {
    const { owner, pembeli, smtToken, gameTopup } = await deployFixture();
    const harga = ethers.parseUnits("50", 18);

    await smtToken.transfer(pembeli.address, harga);
    await smtToken.connect(pembeli).approve(await gameTopup.getAddress(), harga);
    await gameTopup.connect(pembeli).beliTopup(1, "12345678", "1234");

    expect(await gameTopup.totalOrder()).to.equal(1);
    expect(await smtToken.balanceOf(await gameTopup.getAddress())).to.equal(harga);

    const orders = await gameTopup.connect(pembeli).lihatOrderSaya();
    expect(orders[0].game).to.equal("Mobile Legends");
    expect(orders[0].hargaSmt).to.equal(harga);
    expect(orders[0].paketId).to.equal(1);
    expect(orders[0].status).to.equal(2);
    expect(await smtToken.balanceOf(owner.address)).to.be.greaterThan(0);
  });

  it("pemilik bisa update status order", async function () {
    const { pembeli, smtToken, gameTopup } = await deployFixture();
    const harga = ethers.parseUnits("50", 18);

    await smtToken.transfer(pembeli.address, harga);
    await smtToken.connect(pembeli).approve(await gameTopup.getAddress(), harga);
    await gameTopup.connect(pembeli).beliTopup(1, "777", "");
    await gameTopup.updateStatusOrder(1, 2);

    const order = await gameTopup.lihatOrder(1);
    expect(order.status).to.equal(2);
  });

  it("non-pemilik tidak bisa update status order", async function () {
    const { pembeli, orangLain, smtToken, gameTopup } = await deployFixture();
    const harga = ethers.parseUnits("50", 18);

    await smtToken.transfer(pembeli.address, harga);
    await smtToken.connect(pembeli).approve(await gameTopup.getAddress(), harga);
    await gameTopup.connect(pembeli).beliTopup(1, "888", "");

    await expect(gameTopup.connect(orangLain).updateStatusOrder(1, 1)).to.be.revertedWith("Hanya pemilik");
  });
});

