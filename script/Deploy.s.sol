// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

// approve for amount to router
contract Deploy is Script {
  function run() public {
    address USDC = 0x7F5c764cBc14f9669B88837ca1490cCa17c31607;
    vm.broadcast();
    IERC20(USDC).approve(0x1111111254EEB25477B68fb85Ed929f73A960582, 100_000);
  }
}
