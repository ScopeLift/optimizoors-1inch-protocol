// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import {OneInchRouterFactory} from "src/RouterFactory.sol";
import {OneInchContracts} from "test/1InchContracts.sol";

contract V5RouterTestBase is Test, OneInchContracts {
    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("optimism"), 87_407_144);
        OneInchRouterFactory factory = new OneInchRouterFactory(
            aggreationExecutor,
            aggregationRouter
        );
        factory.deploy(USDC);
        deal(USDC, address(this), 100_000_000);
    }
}
