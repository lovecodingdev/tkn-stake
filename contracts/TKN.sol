// SPDX-License-Identifier: MIT
// Optimization: 1500
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TKN is ERC20 {
    constructor() ERC20("TKN", "TKN") {
        _mint(msg.sender, 10000 * 10**uint(decimals()));
    }
}
