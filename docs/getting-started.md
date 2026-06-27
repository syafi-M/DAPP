# Getting Started

## Prasyarat

- Node.js dan npm terinstall.
- Browser Chrome/Edge.
- Extension Metamask terinstall.

## Install

Dari root project:

```bash
npm install
```

## Jalankan 1 Command

```bash
npm start
```

Command ini otomatis:

1. Menjalankan Hardhat node lokal.
2. Deploy `SMTToken`.
3. Deploy `GameTopup`.
4. Update `konektor/contract.json`.
5. Menjalankan Vite dev server.

## Buka Aplikasi

Buka URL yang muncul di terminal, biasanya:

```text
http://localhost:5173/
```

## Setup Metamask

Aplikasi akan mencoba menambahkan network otomatis. Jika perlu manual:

- Network name: `Ethereum Hardhat Localhost`
- RPC URL: `http://127.0.0.1:8545`
- Chain ID: `31337`
- Currency symbol: `ETH`

Import private key dari akun Hardhat yang muncul di terminal `npm start`.

> Akun Hardhat hanya untuk lokal/testing. Jangan gunakan private key tersebut untuk mainnet.
