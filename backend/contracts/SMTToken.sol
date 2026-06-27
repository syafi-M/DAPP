// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SMTToken is ERC20, Ownable {
    uint256 public constant FAUCET_AMOUNT = 1000 * 10 ** 18;
    mapping(address => bool) public sudahClaim;

    constructor() ERC20("Sampel Metaverse Token", "SMT") Ownable(msg.sender) {
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
    }

    function claimFaucet() external {
        require(!sudahClaim[msg.sender], "Faucet sudah diklaim");
        sudahClaim[msg.sender] = true;
        _mint(msg.sender, FAUCET_AMOUNT);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
