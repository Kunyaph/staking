// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract USDT is ERC20, Ownable {
    constructor() ERC20("USDT token", "USDT") {
        _mint(msg.sender, 1000000 * 10**decimals()); // Mint 1,000,000 USDT tokens
    }
}