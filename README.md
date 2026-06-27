# DApp Game Topup + Token SMT

DApp demo Vue.js untuk pembelian diamond/kredit game pakai token bohongan `SMT` di jaringan Ethereum lokal Hardhat. `SMT` tidak punya nilai asli.

## Jalankan simpel

Install dependency sekali saja:

```bash
npm install
```

Lalu jalankan semuanya dengan 1 command:

```bash
npm start
```

Command ini otomatis:

- menjalankan Hardhat node lokal,
- deploy token `SMTToken`,
- deploy kontrak `GameTopup`,
- mengisi `konektor/contract.json`,
- menjalankan frontend Vite.

Buka URL Vite yang muncul di terminal, lalu klik `Connect`.

## Setup Metamask

Tambah network manual jika belum ada:

- Network name: `Ethereum Hardhat Localhost`
- RPC URL: `http://127.0.0.1:8545`
- Chain ID: `31337`
- Currency symbol: `ETH`

Import akun dari private key yang muncul di terminal `npm start`.

> Akun Hardhat dan token SMT hanya untuk lokal/testing. Jangan kirim dana mainnet ke akun tersebut.

## Cara pakai

1. Klik `Connect`.
2. Klik `Claim SMT` untuk dapat 1000 SMT gratis.
3. Pilih game dan paket.
4. Isi User ID / Server ID.
5. Klik `Beli Sekarang`.
6. Metamask akan meminta `approve SMT`, lalu transaksi order topup.

## Fitur

- Token sendiri: `Sampel Metaverse Token` symbol `SMT`.
- SMT faucet 1000 token per wallet.
- Pembayaran topup via ERC20 SMT.
- Status order on-chain: Pending, Processing, Success, Failed. Untuk demo, order otomatis Success setelah transaksi berhasil.
- Paket dan harga topup disimpan on-chain.
- Event realtime untuk order/status.
- Detail transaksi menampilkan tx hash + copy.
- Tombol Add SMT ke Metamask.
- UX loading state dan toast transaksi.
- Game contoh: Mobile Legends, Free Fire, PUBG Mobile, Valorant.
- Riwayat order per wallet.

## Command manual

Jika ingin jalan terpisah:

```bash
npm run node
npm run deploy:local
npm run dev
```

## Struktur

- `backend/contracts/SMTToken.sol`: token ERC20 SMT palsu.
- `backend/contracts/GameTopup.sol`: smart contract order topup SMT + status order.
- `backend/scripts/deploy.js`: deploy token + topup + export ABI/address.
- `antarmuka/src/App.vue`: UI Vue + koneksi Metamask + pembayaran SMT.
- `konektor/contract.json`: konektor frontend ke kontrak.





## Dokumentasi

Dokumentasi lengkap tersedia di docs/README.md.

