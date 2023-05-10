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

  function testFork_CorrectlyDeployV4Router() public {
    vm.expectEmit();
    emit RouterDeployed(RouterFactory.RouterType.V4AggregationRouter, USDC);

    address deployedRouterAddress =
      factory.deploy(RouterFactory.RouterType.V4AggregationRouter, USDC);

    factory.computeAddress(RouterFactory.RouterType.V4AggregationRouter, USDC);
    assertEq(
      deployedRouterAddress,
      factory.computeAddress(RouterFactory.RouterType.V4AggregationRouter, USDC),
      "Address not equal to computed v4 router address"
    );
  }

  function testFork_CorrectlyDeployV5Router() public {
    vm.expectEmit();
    emit RouterDeployed(RouterFactory.RouterType.V5AggregationRouter, USDC);

    address deployedRouterAddress =
      factory.deploy(RouterFactory.RouterType.V5AggregationRouter, USDC);

    assertEq(
      deployedRouterAddress,
      factory.computeAddress(RouterFactory.RouterType.V5AggregationRouter, USDC),
      "Address not equal to computed v5 router address"
    );
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
    factory = new RouterFactory(
            v5AggregationExecutor,
            v5AggregationRouter,
            v4AggregationExecutor,
            v4AggregationRouter
        );
  }

  function helper_salt(address asset) internal pure returns (bytes32) {
    return bytes32(uint256(uint160(asset)));
  }

  function helper_computeV4Address(address asset, address factoryAddr)
    internal
    view
    returns (address)
  {
    return Create2.computeCreate2Address(
      helper_salt(asset),
      factoryAddr,
      type(V4Router).creationCode,
      abi.encode(v4AggregationRouter, v4AggregationExecutor, asset)
    );
  }

  function helper_computeV5Address(address asset, address factoryAddr)
    internal
    view
    returns (address)
  {
    return Create2.computeCreate2Address(
      helper_salt(asset),
      factoryAddr,
      type(V5Router).creationCode,
      abi.encode(v5AggregationRouter, v5AggregationExecutor, asset)
    );
  }

  function testFuzz_ComputeV4Address(address asset) public {
    address computedAddress =
      factory.computeAddress(RouterFactory.RouterType.V4AggregationRouter, asset);
    assertEq(
      computedAddress,
      helper_computeV4Address(asset, address(factory)),
      "V4 computed address is not equal to its expected address"
    );
  }

  function testFuzz_ComputeV5Address(address asset) public {
    address computedAddress =
      factory.computeAddress(RouterFactory.RouterType.V5AggregationRouter, asset);
    assertEq(
      computedAddress,
      helper_computeV5Address(asset, address(factory)),
      "V5 computed address is not equal to its expected address"
    );
  }

  function test_RevertIf_InvalidRouterTypeIsProvided() public {
    vm.expectRevert(bytes(""));
    IBadRouterFactory(address(factory)).computeAddress(
      IBadRouterFactory.BadRouterType.MadeUpRouter, USDC
    );
  }
}
