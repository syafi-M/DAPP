# User Guide

## Alur Penggunaan

1. Buka aplikasi.
2. Klik `Connect Metamask`.
3. Klik `Claim 1000 SMT` untuk mendapatkan token demo.
4. Opsional: klik `Add SMT` agar token tampil di Metamask.
5. Pilih game.
6. Pilih paket topup.
7. Isi `User ID Game` dan `Server ID / Zone ID` jika diperlukan.
8. Klik `Beli Sekarang`.
9. Konfirmasi approve SMT di Metamask.
10. Konfirmasi transaksi order topup di Metamask.

## Status Order

Untuk kebutuhan demo, order baru otomatis menjadi `Success` setelah transaksi berhasil.

Status yang tersedia di kontrak:

- `Pending`
- `Processing`
- `Success`
- `Failed`

## Token SMT

`SMT` adalah token demo ERC20 lokal. Token ini tidak punya nilai asli dan hanya berjalan di network Hardhat lokal.

## Riwayat Order

Riwayat order tampil di panel kanan. Data diperbarui lewat event smart contract dan tombol `Refresh`.

## Detail Transaksi

Setelah approve/order, aplikasi menampilkan hash transaksi. Klik `Copy` untuk menyalin hash.
