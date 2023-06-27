// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Script} from "forge-std/Script.sol";

import {OneInchContracts} from "test/OneInchContracts.sol";
import {RouterFactory} from "src/RouterFactory.sol";
import {IV5AggregationExecutor} from "src/interfaces/IV5AggregationExecutor.sol";
import {IV5AggregationRouter} from "src/interfaces/IV5AggregationRouter.sol";
import {IV4AggregationExecutor} from "src/interfaces/IV4AggregationExecutor.sol";
import {IV4AggregationRouter} from "src/interfaces/IV4AggregationRouter.sol";



contract Deploy is Script, OneInchContracts {
  function run() public {
    IV5AggregationRouter v5AggregationRouter =
      IV5AggregationRouter(0x1111111254EEB25477B68fb85Ed929f73A960582);
    IV5AggregationExecutor v5AggregationExecutor =
      IV5AggregationExecutor(0x454C8b4DC6a2AFfe669A3Db1633133F7d305e305);
    IV4AggregationRouter v4AggregationRouter =
      IV4AggregationRouter(0x1111111254fb6c44bAC0beD2854e76F90643097d);
    IV4AggregationExecutor v4AggregationExecutor =
      IV4AggregationExecutor(0x454C8b4DC6a2AFfe669A3Db1633133F7d305e305);

    address WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

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
    factory.deploy(RouterFactory.RouterType.V5AggregationRouter, WETH);

    // Deploy the optimized router for V4Aggregation
    vm.broadcast();
    factory.deploy(RouterFactory.RouterType.V4AggregationRouter, WETH);
  }
}
