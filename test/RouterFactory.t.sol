// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Test} from "forge-std/Test.sol";
import {OneInchRouterFactory} from "src/RouterFactory.sol";
import {OneInchContracts} from "test/1InchContracts.sol";

contract RouterFactoryTest is Test, OneInchContracts {
    OneInchRouterFactory factory;

    function test_deployV5Router() public {
        factory = new OneInchRouterFactory(
            v5AggregationExecutor,
            v5AggregationRouter,
            v4AggregationExecutor,
            v4AggregationRouter
        );
        address V5Router = factory.deploy(
            OneInchRouterFactory.RouterTypes.V5AggregationRouter,
            USDC
        );
        assertEq(
            V5Router,
            factory.computeAddress(
                OneInchRouterFactory.RouterTypes.V5AggregationRouter,
                USDC
            ),
            "V5Router address should be correct"
        );
    }
}
