// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.16;

import {Script} from "forge-std/Script.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {OneInchContracts} from "test/OneInchContracts.sol";
import {RouterFactory} from "src/RouterFactory.sol";

contract Deploy is Script, OneInchContracts {
  function run() public {
    // Deploy the optimized router factory
    vm.broadcast();
    RouterFactory factory = new RouterFactory(
      v5AggregationExecutor,
      v5AggregationRouter,
      v4AggregationExecutor,
      v4AggregationRouter
    );

    // Deploy the optimized router for V5Aggregation
    vm.broadcast();
    factory.deploy(RouterFactory.RouterType.V5AggregationRouter, USDC);

    // Deploy the optimized router for V4Aggregation
    vm.broadcast();
    factory.deploy(RouterFactory.RouterType.V4AggregationRouter, USDC);
  }
}
