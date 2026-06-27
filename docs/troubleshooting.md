# Troubleshooting

## Dropdown Game/Paket Kosong

Penyebab umum:

- Hardhat node belum jalan.
- Kontrak belum deploy ulang setelah ABI berubah.
- `konektor/contract.json` masih address lama.

Solusi:

```bash
Ctrl + C
npm start
```

## Metamask Error: Unrecognized Chain ID

Aplikasi sudah auto-add network. Jika masih error:

1. Hapus network `Ethereum Hardhat Localhost` di Metamask.
2. Refresh browser.
3. Klik `Connect Metamask` lagi.

Manual network:

- RPC URL: `http://127.0.0.1:8545`
- Chain ID: `31337`
- Symbol: `ETH`

## Saldo SMT Tidak Muncul di Metamask

Klik tombol `Add SMT` di aplikasi. Jika gagal, tambahkan token manual:

- Token contract address: lihat `konektor/contract.json` bagian `token.address`.
- Symbol: `SMT`
- Decimals: `18`

## Order Pending

Versi demo terbaru membuat order otomatis `Success`. Jika masih `Pending`, kemungkinan kontrak lama masih berjalan.

Solusi:

```bash
Ctrl + C
npm start
```

Lalu buat order baru.

## MaxListenersExceededWarning / ObjectMultiplex

Warning ini biasanya berasal dari Metamask content script, bukan aplikasi.

Solusi:

- Hard refresh browser: `Ctrl + Shift + R`.
- Tutup tab lama.
- Restart browser.
- Disable/enable Metamask.

## Nonce / Transaction Error

Jika Metamask bingung nonce karena Hardhat node restart:

1. Metamask → Settings → Advanced.
2. Klik `Clear activity and nonce data`.
3. Refresh aplikasi.
4. Connect ulang.
