// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GameTopup {
    enum StatusOrder {
        Pending,
        Processing,
        Success,
        Failed
    }

    struct PaketTopup {
        uint256 id;
        string game;
        string nama;
        uint256 hargaSmt;
        bool aktif;
    }

    struct Order {
        uint256 id;
        address pembeli;
        string game;
        string userGameId;
        string serverId;
        string paket;
        uint256 hargaSmt;
        uint256 waktu;
        StatusOrder status;
        uint256 paketId;
    }

    IERC20 public immutable smtToken;
    uint256 public totalOrder;
    uint256 public totalPaket;
    address public pemilik;
    mapping(uint256 => Order) public orders;
    mapping(uint256 => PaketTopup) public paketTopups;
    mapping(address => uint256[]) private orderPembeli;

    event OrderDibuat(uint256 indexed id, address indexed pembeli, string game, string userGameId, string serverId, string paket, uint256 hargaSmt);
    event StatusOrderDiubah(uint256 indexed id, StatusOrder status);
    event PaketDiubah(uint256 indexed id, string game, string nama, uint256 hargaSmt, bool aktif);

    modifier hanyaPemilik() {
        require(msg.sender == pemilik, "Hanya pemilik");
        _;
    }

    constructor(address smtTokenAddress) {
        require(smtTokenAddress != address(0), "Token SMT tidak valid");
        smtToken = IERC20(smtTokenAddress);
        pemilik = msg.sender;

        _tambahPaket("Mobile Legends", "86 Diamonds", 50 ether, true);
        _tambahPaket("Mobile Legends", "172 Diamonds", 95 ether, true);
        _tambahPaket("Mobile Legends", "257 Diamonds", 140 ether, true);
        _tambahPaket("Mobile Legends", "Weekly Diamond Pass", 75 ether, true);
        _tambahPaket("Free Fire", "70 Diamonds", 40 ether, true);
        _tambahPaket("Free Fire", "140 Diamonds", 80 ether, true);
        _tambahPaket("Free Fire", "355 Diamonds", 180 ether, true);
        _tambahPaket("PUBG Mobile", "60 UC", 55 ether, true);
        _tambahPaket("PUBG Mobile", "325 UC", 250 ether, true);
        _tambahPaket("PUBG Mobile", "660 UC", 480 ether, true);
        _tambahPaket("Valorant", "475 VP", 120 ether, true);
        _tambahPaket("Valorant", "1000 VP", 240 ether, true);
        _tambahPaket("Valorant", "2050 VP", 460 ether, true);
    }

    function beliTopup(uint256 paketId, string calldata userGameId, string calldata serverId) external {
        PaketTopup memory paketData = paketTopups[paketId];
        require(paketId > 0 && paketId <= totalPaket, "Paket tidak ditemukan");
        require(paketData.aktif, "Paket tidak aktif");
        require(bytes(userGameId).length > 0, "User ID wajib diisi");
        require(smtToken.transferFrom(msg.sender, address(this), paketData.hargaSmt), "Pembayaran SMT gagal");

        totalOrder += 1;
        orders[totalOrder] = Order({
            id: totalOrder,
            pembeli: msg.sender,
            game: paketData.game,
            userGameId: userGameId,
            serverId: serverId,
            paket: paketData.nama,
            hargaSmt: paketData.hargaSmt,
            waktu: block.timestamp,
            status: StatusOrder.Success,
            paketId: paketId
        });

        orderPembeli[msg.sender].push(totalOrder);
        emit OrderDibuat(totalOrder, msg.sender, paketData.game, userGameId, serverId, paketData.nama, paketData.hargaSmt);
        emit StatusOrderDiubah(totalOrder, StatusOrder.Success);
    }

    function tambahPaket(string calldata game, string calldata nama, uint256 hargaSmt, bool aktif) external hanyaPemilik {
        _tambahPaket(game, nama, hargaSmt, aktif);
    }

    function updatePaket(uint256 paketId, string calldata game, string calldata nama, uint256 hargaSmt, bool aktif) external hanyaPemilik {
        require(paketId > 0 && paketId <= totalPaket, "Paket tidak ditemukan");
        require(bytes(game).length > 0, "Game wajib diisi");
        require(bytes(nama).length > 0, "Paket wajib diisi");
        require(hargaSmt > 0, "Harga wajib lebih dari 0");
        paketTopups[paketId] = PaketTopup(paketId, game, nama, hargaSmt, aktif);
        emit PaketDiubah(paketId, game, nama, hargaSmt, aktif);
    }

    function updateStatusOrder(uint256 id, StatusOrder statusBaru) external hanyaPemilik {
        require(id > 0 && id <= totalOrder, "Order tidak ditemukan");
        orders[id].status = statusBaru;
        emit StatusOrderDiubah(id, statusBaru);
    }

    function lihatSemuaPaket() external view returns (PaketTopup[] memory) {
        PaketTopup[] memory hasil = new PaketTopup[](totalPaket);
        for (uint256 i = 1; i <= totalPaket; i++) {
            hasil[i - 1] = paketTopups[i];
        }
        return hasil;
    }

    function lihatOrderSaya() external view returns (Order[] memory) {
        uint256[] storage ids = orderPembeli[msg.sender];
        Order[] memory hasil = new Order[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            hasil[i] = orders[ids[i]];
        }
        return hasil;
    }

    function lihatOrder(uint256 id) external view returns (Order memory) {
        require(id > 0 && id <= totalOrder, "Order tidak ditemukan");
        return orders[id];
    }

    function tarikSmt(address tujuan, uint256 amount) external hanyaPemilik {
        require(tujuan != address(0), "Alamat tidak valid");
        require(smtToken.transfer(tujuan, amount), "Transfer SMT gagal");
    }

    function _tambahPaket(string memory game, string memory nama, uint256 hargaSmt, bool aktif) private {
        require(bytes(game).length > 0, "Game wajib diisi");
        require(bytes(nama).length > 0, "Paket wajib diisi");
        require(hargaSmt > 0, "Harga wajib lebih dari 0");
        totalPaket += 1;
        paketTopups[totalPaket] = PaketTopup(totalPaket, game, nama, hargaSmt, aktif);
        emit PaketDiubah(totalPaket, game, nama, hargaSmt, aktif);
    }
}

