// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Test} from "forge-std/Test.sol";

import {Create2} from "src/lib/Create2.sol";
import {IV5AggregationExecutor} from "src/interfaces/IV5AggregationExecutor.sol";
import {IV5AggregationRouter} from "src/interfaces/IV5AggregationRouter.sol";
import {IV4AggregationExecutor} from "src/interfaces/IV4AggregationExecutor.sol";
import {IV4AggregationRouter} from "src/interfaces/IV4AggregationRouter.sol";
import {RouterFactory} from "src/RouterFactory.sol";
import {V5Router} from "src/V5Router.sol";
import {V4Router} from "src/V4Router.sol";
import {OneInchContracts} from "test/OneInchContracts.sol";

interface IBadRouterFactory {
  enum BadRouterType {
    V4AggregationRouter,
    V5AggregationRouter,
    MadeUpRouter
  }

  function deploy(BadRouterType type_, address asset) external returns (address);

  function computeAddress(BadRouterType type_, address asset) external returns (address);
}

contract RouterFactoryTest is Test, OneInchContracts {
  RouterFactory factory;

  event RouterDeployed(RouterFactory.RouterType type_, address indexed asset);
}

contract Constructor is RouterFactoryTest {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl("optimism"), 95_544_472);
  }

  function testFork_CorrectlySetsAllConstructorArgs() public {
    RouterFactory factory = new RouterFactory(
            v5AggregationExecutor,
            v5AggregationRouter,
            v4AggregationExecutor,
            v4AggregationRouter
        );
    assertEq(
      address(factory.V5_AGGREGATION_EXECUTOR()),
      address(v5AggregationExecutor),
      "V5_AGGREGATION_EXECUTOR not set correctly"
    );
    assertEq(
      address(factory.V5_AGGREGATION_ROUTER()),
      address(v5AggregationRouter),
      "V5_AGGREGATION_ROUTER was not set correctly"
    );
    assertEq(
      address(factory.V4_AGGREGATION_EXECUTOR()),
      address(v4AggregationExecutor),
      "V4_AGGREGATION_EXECUTOR was not set correctly"
    );
    assertEq(
      address(factory.V4_AGGREGATION_ROUTER()),
      address(v4AggregationRouter),
      "V4_AGGREGATION_ROUTER was not set correctly"
    );
  }
}

contract Deploy is RouterFactoryTest {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl("optimism"), 95_544_472);
    factory = new RouterFactory(
            v5AggregationExecutor,
            v5AggregationRouter,
            v4AggregationExecutor,
            v4AggregationRouter
        );
  }

  function testFork_EmitV4RouterDeployedEvent() public {
    vm.expectEmit();
    emit RouterDeployed(RouterFactory.RouterType.V4AggregationRouter, USDC);

    factory.deploy(RouterFactory.RouterType.V4AggregationRouter, USDC);
  }

  function testFork_ReturnsV4RouterAddress() public {
    address deployedRouterAddress =
      factory.deploy(RouterFactory.RouterType.V4AggregationRouter, USDC);

    factory.computeAddress(RouterFactory.RouterType.V4AggregationRouter, USDC);
    assertEq(
      deployedRouterAddress,
      factory.computeAddress(RouterFactory.RouterType.V4AggregationRouter, USDC),
      "Address not equal to computed v4 router address"
    );
  }

  function testFork_CorrectlyDeploysV4Router() public {
    address deployedRouterAddress =
      factory.deploy(RouterFactory.RouterType.V4AggregationRouter, USDC);
    assertGt(deployedRouterAddress.code.length, 0, "no code");
  }

  function testFork_EmitV5RouterDeployedEvent() public {
    vm.expectEmit();
    emit RouterDeployed(RouterFactory.RouterType.V5AggregationRouter, USDC);

    factory.deploy(RouterFactory.RouterType.V5AggregationRouter, USDC);
  }

  function testFork_ReturnsV5RouterAddress() public {
    address deployedRouterAddress =
      factory.deploy(RouterFactory.RouterType.V5AggregationRouter, USDC);

    assertEq(
      deployedRouterAddress,
      factory.computeAddress(RouterFactory.RouterType.V5AggregationRouter, USDC),
      "Address not equal to computed v5 router address"
    );
  }

  function testFork_CorrectlyDeploysV5Router() public {
    address deployedRouterAddress =
      factory.deploy(RouterFactory.RouterType.V5AggregationRouter, USDC);
    assertGt(deployedRouterAddress.code.length, 0, "no code");
  }

  function test_RevertIf_UnsupportedRouterType() public {
    vm.expectRevert(bytes(""));
    IBadRouterFactory(address(factory)).deploy(IBadRouterFactory.BadRouterType.MadeUpRouter, USDC);
  }

  function test_RevertIf_RouterIsAlreadyDeployed() public {
    factory.deploy(RouterFactory.RouterType.V5AggregationRouter, USDC);

    vm.expectRevert(bytes(""));
    factory.deploy(RouterFactory.RouterType.V5AggregationRouter, USDC);
  }
}

contract ComputeAddress is RouterFactoryTest {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl("optimism"), 95_544_472);
    factory = new RouterFactory(
            v5AggregationExecutor,
            v5AggregationRouter,
            v4AggregationExecutor,
            v4AggregationRouter
        );
  }

  function testFork_ComputeV4Address() public {
    address computedAddress =
      factory.computeAddress(RouterFactory.RouterType.V4AggregationRouter, USDC);
    assertEq(computedAddress.code.length, 0, "There is code at the computed address");
    factory.deploy(RouterFactory.RouterType.V4AggregationRouter, USDC);
    assertGt(computedAddress.code.length, 0, "There should be code at the computed address");
  }

  function testFork_ComputeV5Address() public {
    address computedAddress =
      factory.computeAddress(RouterFactory.RouterType.V5AggregationRouter, USDC);
    assertEq(computedAddress.code.length, 0, "There is code at the computed address");
    factory.deploy(RouterFactory.RouterType.V5AggregationRouter, USDC);
    assertGt(computedAddress.code.length, 0, "There should be code at the computed address");
  }

  function test_RevertIf_InvalidRouterTypeIsProvided() public {
    vm.expectRevert(bytes(""));
    IBadRouterFactory(address(factory)).computeAddress(
      IBadRouterFactory.BadRouterType.MadeUpRouter, USDC
    );
  }
}
