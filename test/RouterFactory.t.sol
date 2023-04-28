// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Test} from "forge-std/Test.sol";
import {OneInchRouterFactory} from "src/RouterFactory.sol";
import {OneInchContracts} from "test/1InchContracts.sol";

contract RouterFactoryTest is Test, OneInchContracts {
  OneInchRouterFactory factory;

  function test_deployV5Router() public {
    factory = new OneInchRouterFactory(
            aggregationExecutor,
            aggregationRouter
        );
    address V5Router = factory.deploy(USDC);
    assertEq(V5Router, factory.computeAddress(USDC), "V5Router address should be correct");
  }
}
