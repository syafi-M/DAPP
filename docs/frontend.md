# Frontend

Frontend memakai Vite + Vue 3.

## Struktur Penting

- `antarmuka/src/main.js` — entry Vue.
- `antarmuka/src/App.vue` — halaman utama, logic wallet, order, event listener.
- `antarmuka/src/style.css` — styling UI.
- `konektor/contract.json` — address + ABI hasil deploy.

## Integrasi Wallet

Aplikasi memakai `window.ethereum` dari Metamask untuk:

- connect wallet,
- switch/add network Hardhat,
- approve token SMT,
- membuat order topup,
- add token SMT ke Metamask.

## Read-only Provider

Untuk membaca paket on-chain, aplikasi memakai RPC lokal langsung:

```js
new ethers.JsonRpcProvider("http://127.0.0.1:8545")
```

Ini membuat dropdown game/paket tetap bisa muncul walau wallet belum connect.

## Event Realtime

Frontend listen event:

- `OrderDibuat`
- `StatusOrderDiubah`

Saat event masuk, aplikasi reload order dan saldo.

## Fallback Paket

Jika kontrak belum siap, frontend punya fallback list paket agar dropdown tidak kosong. Setelah deploy benar, data kontrak tetap jadi sumber utama.
