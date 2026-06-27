# Smart Contracts

## `SMTToken.sol`

Path: `backend/contracts/SMTToken.sol`

Token ERC20 demo dengan symbol `SMT`.

### Fitur

- Nama token: `Sampel Metaverse Token`.
- Symbol: `SMT`.
- Mint awal ke deployer: `1,000,000 SMT`.
- Faucet user: `1000 SMT` per wallet.
- Owner bisa mint token tambahan.

### Fungsi Penting

- `claimFaucet()` — user claim 1000 SMT sekali.
- `mint(address to, uint256 amount)` — owner mint token.

## `GameTopup.sol`

Path: `backend/contracts/GameTopup.sol`

Kontrak order topup game yang memakai token `SMT` sebagai alat bayar.

### Data Paket

Paket topup disimpan on-chain dengan struct `PaketTopup`:

- `id`
- `game`
- `nama`
- `hargaSmt`
- `aktif`

Paket default dibuat di constructor.

### Data Order

Order disimpan dengan struct `Order`:

- `id`
- `pembeli`
- `game`
- `userGameId`
- `serverId`
- `paket`
- `hargaSmt`
- `waktu`
- `status`
- `paketId`

### Fungsi Penting

- `beliTopup(uint256 paketId, string userGameId, string serverId)` — membuat order dan membayar SMT.
- `lihatSemuaPaket()` — membaca semua paket on-chain.
- `lihatOrderSaya()` — membaca order milik wallet pemanggil.
- `lihatOrder(uint256 id)` — membaca order berdasarkan ID.
- `updateStatusOrder(uint256 id, StatusOrder statusBaru)` — owner mengubah status order.
- `tambahPaket(...)` — owner menambah paket.
- `updatePaket(...)` — owner mengubah paket.
- `tarikSmt(address tujuan, uint256 amount)` — owner menarik SMT dari kontrak.

### Event

- `OrderDibuat`
- `StatusOrderDiubah`
- `PaketDiubah`

Frontend memakai event ini untuk update data realtime.
