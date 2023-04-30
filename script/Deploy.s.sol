// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.16;

import {Script} from "forge-std/Script.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {OneInchContracts} from "test/1InchContracts.sol";
import {OneInchRouterFactory} from "src/RouterFactory.sol";

// IERC20(USDC).approve(0x1111111254EEB25477B68fb85Ed929f73A960582, 100_000);
//IERC20(USDC).approve(
//    0x1111111254760F7ab3F16433eea9304126DCd199,
//    100_000
//);
contract Deploy is Script, OneInchContracts {
    function run() public {
        // Deploy the optimized router factory
        vm.broadcast();
        OneInchRouterFactory factory = new OneInchRouterFactory(
            v5AggregationExecutor,
            v5AggregationRouter,
            v4AggregationExecutor,
            v4AggregationRouter
        );

        // Deploy the optimized router for V5Aggregation
        vm.broadcast();
        factory.deploy(
            OneInchRouterFactory.RouterTypes.V5AggregationRouter,
            USDC
        );

        // Deploy the optimized router for V4Aggregation
        vm.broadcast();
        factory.deploy(
            OneInchRouterFactory.RouterTypes.V4AggregationRouter,
            USDC
        );
    }
}
