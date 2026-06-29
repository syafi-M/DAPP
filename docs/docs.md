# Dokumentasi Lengkap DApp Topup SMT

Dokumen ini adalah sumber utama yang bisa langsung dimasukkan ke NotebookLM. Isinya merangkum konsep, arsitektur, cara menjalankan, alur penggunaan, smart contract, frontend, dan troubleshooting untuk project DApp Topup SMT.

## 1. Gambaran Umum Project

DApp Topup SMT adalah aplikasi topup game berbasis blockchain lokal. Aplikasi ini dibuat untuk demo dan pembelajaran integrasi smart contract, token ERC20, wallet Metamask, dan frontend Vue.

User dapat membuka aplikasi, menghubungkan wallet Metamask, klaim token demo SMT, memilih game dan paket topup, lalu membayar paket tersebut memakai token SMT. Semua paket topup dan order disimpan di smart contract. Frontend membaca data dari smart contract dan mendengarkan event agar riwayat order bisa diperbarui secara realtime.

Project ini tidak memakai token asli. Token SMT hanya token demo lokal di jaringan Hardhat. Private key dari Hardhat juga hanya untuk testing lokal dan tidak boleh dipakai di mainnet.

## 2. Stack Teknologi

Project menggunakan beberapa teknologi utama:

- Solidity untuk menulis smart contract.
- Hardhat untuk menjalankan blockchain lokal, compile, deploy, dan testing kontrak.
- OpenZeppelin untuk implementasi standar ERC20 dan ownership pada token SMT.
- Vue 3 untuk membangun antarmuka frontend.
- Vite untuk development server frontend.
- Ethers.js untuk komunikasi frontend dengan smart contract.
- Metamask untuk koneksi wallet, approve token, dan konfirmasi transaksi.
- Network lokal Hardhat dengan `chainId 31337`.

## 3. Struktur Folder Penting

Struktur penting project:

```text
backend/contracts/SMTToken.sol       Smart contract token ERC20 demo SMT
backend/contracts/GameTopup.sol      Smart contract order topup game
antarmuka/src/main.js                Entry point Vue
antarmuka/src/App.vue                Halaman utama dan logic aplikasi
antarmuka/src/style.css              Styling antarmuka
konektor/contract.json               Address dan ABI hasil deploy kontrak
docs/                                Folder dokumentasi
```

File `konektor/contract.json` penting karena frontend membaca alamat kontrak dan ABI dari file ini. Setelah deploy ulang, address kontrak dapat berubah sehingga file ini harus ikut diperbarui oleh script deploy.

## 4. Cara Menjalankan Project

Prasyarat:

- Node.js dan npm sudah terinstall.
- Browser Chrome atau Edge tersedia.
- Extension Metamask sudah terinstall.

Install dependency dari root project:

```bash
npm install
```

Jalankan aplikasi dengan satu command:

```bash
npm start
```

Command `npm start` menjalankan alur otomatis:

1. Menjalankan Hardhat node lokal.
2. Deploy kontrak `SMTToken`.
3. Deploy kontrak `GameTopup`.
4. Update file `konektor/contract.json` dengan address dan ABI terbaru.
5. Menjalankan Vite dev server untuk frontend.

Setelah berjalan, buka URL dari terminal, biasanya:

```text
http://localhost:5173/
```

## 5. Setup Metamask

Aplikasi mencoba menambahkan network Hardhat secara otomatis. Jika perlu setup manual, gunakan konfigurasi ini:

```text
Network name: Ethereum Hardhat Localhost
RPC URL: http://127.0.0.1:8545
Chain ID: 31337
Currency symbol: ETH
```

Untuk testing, import private key dari akun Hardhat yang muncul di terminal saat `npm start`. Akun Hardhat hanya untuk lokal/testing.

Peringatan penting: jangan pernah memakai private key Hardhat untuk mainnet atau wallet berisi aset asli.

## 6. Alur Penggunaan User

Alur penggunaan aplikasi dari sisi user:

1. Buka aplikasi di browser.
2. Klik `Connect Metamask`.
3. Izinkan koneksi wallet di Metamask.
4. Pastikan network aktif adalah Hardhat localhost `31337`.
5. Klik `Claim 1000 SMT` untuk mendapatkan token demo.
6. Opsional: klik `Add SMT` agar token SMT muncul di Metamask.
7. Pilih game yang ingin ditopup.
8. Pilih paket topup yang tersedia.
9. Isi `User ID Game`.
10. Isi `Server ID / Zone ID` jika game membutuhkan server atau zone ID.
11. Klik `Beli Sekarang`.
12. Konfirmasi transaksi approve token SMT di Metamask.
13. Konfirmasi transaksi pembelian topup di Metamask.
14. Setelah transaksi berhasil, order masuk ke riwayat.

Pada versi demo ini, order baru langsung mendapat status `Success` setelah transaksi pembelian berhasil.

## 7. Token SMT

Token SMT adalah token demo ERC20 lokal. Nama lengkapnya adalah `Sampel Metaverse Token` dan simbolnya `SMT`.

Karakteristik token SMT:

- Standar token: ERC20.
- Nama token: `Sampel Metaverse Token`.
- Symbol: `SMT`.
- Decimals: `18`.
- Supply awal: `1,000,000 SMT` dikirim ke deployer.
- Faucet: setiap wallet bisa claim `1000 SMT` satu kali.
- Owner token bisa mint token tambahan.

Token SMT tidak punya nilai asli. Token ini hanya berjalan di network lokal Hardhat untuk demo pembayaran topup.

## 8. Smart Contract `SMTToken.sol`

Path kontrak:

```text
backend/contracts/SMTToken.sol
```

`SMTToken` adalah kontrak ERC20 demo berbasis OpenZeppelin. Kontrak ini mewarisi `ERC20` dan `Ownable`.

State penting:

- `FAUCET_AMOUNT`: jumlah faucet tetap sebesar `1000 * 10 ** 18`.
- `sudahClaim`: mapping untuk mencatat wallet yang sudah claim faucet.

Constructor kontrak:

- Menentukan nama token `Sampel Metaverse Token`.
- Menentukan simbol token `SMT`.
- Menetapkan deployer sebagai owner.
- Mint `1,000,000 SMT` ke deployer.

Fungsi penting:

- `claimFaucet()` digunakan user untuk mendapatkan `1000 SMT` sekali per wallet.
- `mint(address to, uint256 amount)` digunakan owner untuk mint token tambahan.

Validasi penting:

- `claimFaucet()` gagal jika wallet sudah pernah claim.
- `mint()` hanya bisa dipanggil oleh owner.

## 9. Smart Contract `GameTopup.sol`

Path kontrak:

```text
backend/contracts/GameTopup.sol
```

`GameTopup` adalah kontrak utama untuk menyimpan paket topup, membuat order, menerima pembayaran SMT, dan menyimpan status order.

Kontrak ini menerima alamat token SMT di constructor. Alamat token tidak boleh `address(0)`. Setelah kontrak dibuat, deployer menjadi `pemilik` kontrak.

### 9.1 Status Order

Status order didefinisikan sebagai enum:

```text
0 = Pending
1 = Processing
2 = Success
3 = Failed
```

Walaupun enum menyediakan empat status, pada versi demo fungsi `beliTopup()` langsung membuat order dengan status `Success`.

### 9.2 Data Paket Topup

Struct `PaketTopup` berisi:

- `id`: ID paket.
- `game`: nama game.
- `nama`: nama paket.
- `hargaSmt`: harga paket dalam SMT dengan decimals 18.
- `aktif`: status aktif paket.

Paket default dibuat saat constructor dijalankan.

Daftar paket default:

| ID | Game | Paket | Harga |
|---:|---|---|---:|
| 1 | Mobile Legends | 86 Diamonds | 50 SMT |
| 2 | Mobile Legends | 172 Diamonds | 95 SMT |
| 3 | Mobile Legends | 257 Diamonds | 140 SMT |
| 4 | Mobile Legends | Weekly Diamond Pass | 75 SMT |
| 5 | Free Fire | 70 Diamonds | 40 SMT |
| 6 | Free Fire | 140 Diamonds | 80 SMT |
| 7 | Free Fire | 355 Diamonds | 180 SMT |
| 8 | PUBG Mobile | 60 UC | 55 SMT |
| 9 | PUBG Mobile | 325 UC | 250 SMT |
| 10 | PUBG Mobile | 660 UC | 480 SMT |
| 11 | Valorant | 475 VP | 120 SMT |
| 12 | Valorant | 1000 VP | 240 SMT |
| 13 | Valorant | 2050 VP | 460 SMT |

### 9.3 Data Order

Struct `Order` berisi:

- `id`: ID order.
- `pembeli`: alamat wallet pembeli.
- `game`: nama game dari paket.
- `userGameId`: ID game tujuan topup.
- `serverId`: server ID atau zone ID jika ada.
- `paket`: nama paket yang dibeli.
- `hargaSmt`: harga yang dibayar.
- `waktu`: timestamp blockchain saat order dibuat.
- `status`: status order.
- `paketId`: ID paket yang dibeli.

Order disimpan dalam mapping `orders`. Daftar order per user disimpan di mapping `orderPembeli`.

### 9.4 Fungsi Pembelian Topup

Fungsi utama pembelian:

```solidity
beliTopup(uint256 paketId, string calldata userGameId, string calldata serverId)
```

Alur fungsi:

1. Membaca data paket berdasarkan `paketId`.
2. Memastikan `paketId` valid.
3. Memastikan paket aktif.
4. Memastikan `userGameId` tidak kosong.
5. Menarik token SMT dari user ke kontrak memakai `transferFrom`.
6. Menambah `totalOrder`.
7. Menyimpan order baru.
8. Menyimpan ID order ke daftar order pembeli.
9. Emit event `OrderDibuat`.
10. Emit event `StatusOrderDiubah` dengan status `Success`.

Karena pembayaran memakai `transferFrom`, user harus melakukan approve token SMT lebih dulu dari frontend sebelum memanggil `beliTopup()`.

### 9.5 Fungsi Admin/Pemilik

Fungsi khusus pemilik kontrak:

- `tambahPaket(...)`: menambah paket topup baru.
- `updatePaket(...)`: mengubah data paket dan status aktif paket.
- `updateStatusOrder(...)`: mengubah status order.
- `tarikSmt(address tujuan, uint256 amount)`: menarik SMT dari kontrak ke alamat tujuan.

Semua fungsi ini memakai modifier `hanyaPemilik`, sehingga hanya address `pemilik` yang bisa memanggilnya.

### 9.6 Fungsi Baca Data

Fungsi baca data:

- `lihatSemuaPaket()`: mengembalikan semua paket topup.
- `lihatOrderSaya()`: mengembalikan semua order milik wallet pemanggil.
- `lihatOrder(uint256 id)`: mengembalikan detail order berdasarkan ID.

### 9.7 Event Smart Contract

Event yang dipakai:

- `OrderDibuat`: dipancarkan saat order dibuat.
- `StatusOrderDiubah`: dipancarkan saat status order berubah.
- `PaketDiubah`: dipancarkan saat paket ditambah atau diubah.

Frontend memakai event ini untuk memperbarui data order dan saldo secara realtime.

## 10. Frontend Vue

Frontend memakai Vite dan Vue 3. File utama frontend adalah:

```text
antarmuka/src/App.vue
```

Frontend mengurus:

- Koneksi wallet Metamask.
- Switch atau add network Hardhat.
- Membaca saldo SMT.
- Claim faucet SMT.
- Menambahkan token SMT ke Metamask.
- Membaca daftar paket dari kontrak.
- Menampilkan pilihan game dan paket.
- Melakukan approve token SMT.
- Membuat order topup.
- Menampilkan hash transaksi.
- Menampilkan riwayat order.
- Mendengarkan event smart contract.

## 11. Integrasi Wallet dan Network

Frontend memakai `window.ethereum` dari Metamask untuk operasi wallet.

Operasi wallet meliputi:

- Request akun wallet.
- Switch ke network Hardhat `31337`.
- Add network jika belum ada di Metamask.
- Sign transaksi approve SMT.
- Sign transaksi order topup.
- Add token SMT ke daftar aset Metamask.

Jika wallet belum connect, aplikasi tetap bisa menampilkan paket karena menggunakan read-only provider.

## 12. Read-only Provider

Untuk membaca paket on-chain tanpa harus connect wallet, frontend memakai provider RPC langsung:

```js
new ethers.JsonRpcProvider("http://127.0.0.1:8545")
```

Tujuannya agar dropdown game dan paket tetap muncul walaupun user belum connect Metamask.

Saat transaksi dibutuhkan, frontend baru memakai signer dari Metamask.

## 13. Alur Pembelian di Frontend

Alur pembelian topup di frontend:

1. User memilih game dan paket.
2. User mengisi `User ID Game` dan opsional `Server ID / Zone ID`.
3. Frontend mengecek wallet sudah connect.
4. Frontend membaca harga paket.
5. Frontend memanggil kontrak token SMT untuk `approve` ke alamat kontrak `GameTopup`.
6. User konfirmasi approve di Metamask.
7. Setelah approve sukses, frontend memanggil `beliTopup()` pada kontrak `GameTopup`.
8. User konfirmasi order di Metamask.
9. Setelah transaksi sukses, kontrak membuat order dan menerima SMT.
10. Frontend memperbarui saldo dan riwayat order.
11. Hash transaksi ditampilkan dan bisa disalin.

## 14. Riwayat Order

Riwayat order ditampilkan di panel kanan aplikasi. Data order berasal dari fungsi `lihatOrderSaya()`.

Setiap order menampilkan informasi:

- ID order.
- Nama game.
- Status order.
- Nama paket.
- User ID game.
- Server ID jika ada.
- Harga dalam SMT.

User juga bisa menekan tombol `Refresh` untuk memuat ulang riwayat.

## 15. Fallback Paket

Frontend memiliki fallback list paket agar dropdown tidak kosong jika kontrak belum siap. Namun saat kontrak sudah deploy dan RPC berjalan, sumber data utama tetap smart contract.

Fallback hanya membantu pengalaman development, bukan sumber data utama aplikasi.

## 16. File `contract.json`

File:

```text
konektor/contract.json
```

File ini berisi data koneksi kontrak hasil deploy, biasanya mencakup:

- Address kontrak token SMT.
- ABI kontrak token SMT.
- Address kontrak GameTopup.
- ABI kontrak GameTopup.

Frontend memakai file ini agar tahu kontrak mana yang harus dipanggil. Jika Hardhat node direstart dan kontrak dideploy ulang, address kontrak bisa berubah. Karena itu `contract.json` harus ikut diperbarui.

## 17. Error dan Troubleshooting

### 17.1 Dropdown Game atau Paket Kosong

Penyebab umum:

- Hardhat node belum berjalan.
- Kontrak belum deploy.
- ABI berubah tapi kontrak belum deploy ulang.
- `konektor/contract.json` masih berisi address lama.

Solusi:

```bash
Ctrl + C
npm start
```

### 17.2 Metamask Error `Unrecognized Chain ID`

Penyebab: network Hardhat localhost belum dikenal oleh Metamask.

Solusi otomatis biasanya cukup klik `Connect Metamask`. Jika masih gagal:

1. Hapus network `Ethereum Hardhat Localhost` di Metamask.
2. Refresh browser.
3. Klik `Connect Metamask` lagi.

Setup manual:

```text
RPC URL: http://127.0.0.1:8545
Chain ID: 31337
Symbol: ETH
```

### 17.3 Saldo SMT Tidak Muncul di Metamask

Klik tombol `Add SMT` di aplikasi. Jika gagal, tambahkan token manual:

```text
Token contract address: lihat konektor/contract.json bagian token.address
Symbol: SMT
Decimals: 18
```

### 17.4 Order Masih Pending

Versi demo terbaru membuat order langsung `Success`. Jika order masih `Pending`, kemungkinan kontrak lama masih berjalan.

Solusi:

```bash
Ctrl + C
npm start
```

Lalu buat order baru.

### 17.5 `MaxListenersExceededWarning` atau `ObjectMultiplex`

Warning ini biasanya berasal dari Metamask content script, bukan dari aplikasi.

Solusi:

- Hard refresh browser dengan `Ctrl + Shift + R`.
- Tutup tab lama.
- Restart browser.
- Disable lalu enable kembali Metamask.

### 17.6 Nonce atau Transaction Error

Penyebab umum: Metamask masih menyimpan nonce lama setelah Hardhat node restart.

Solusi:

1. Buka Metamask.
2. Masuk ke `Settings`.
3. Masuk ke `Advanced`.
4. Klik `Clear activity and nonce data`.
5. Refresh aplikasi.
6. Connect wallet ulang.

## 18. Catatan Keamanan

Project ini hanya untuk demo lokal. Hal penting yang harus diingat:

- Token SMT tidak punya nilai asli.
- Network Hardhat hanya berjalan lokal.
- Private key Hardhat hanya untuk testing.
- Jangan import private key Hardhat ke wallet utama.
- Jangan gunakan private key Hardhat untuk mainnet.
- Jangan mengirim aset asli ke address testing lokal.
- Jika ingin produksi, kontrak perlu audit, validasi tambahan, handling status order yang lebih matang, dan backend/admin panel untuk fulfillment topup asli.

## 19. Ringkasan Cara Kerja End-to-End

Secara sederhana, aplikasi bekerja seperti ini:

```text
User buka frontend
  -> frontend membaca paket dari GameTopup
  -> user connect Metamask
  -> user claim SMT dari SMTToken
  -> user pilih paket topup
  -> frontend meminta approve SMT
  -> SMTToken memberi allowance ke GameTopup
  -> frontend memanggil beliTopup()
  -> GameTopup menarik SMT dari user
  -> GameTopup membuat order
  -> GameTopup emit event OrderDibuat dan StatusOrderDiubah
  -> frontend menangkap event
  -> frontend refresh saldo dan riwayat order
```

Inti project ini adalah simulasi marketplace topup game on-chain: paket disimpan di kontrak, pembayaran memakai token ERC20, dan order terekam di blockchain lokal.
