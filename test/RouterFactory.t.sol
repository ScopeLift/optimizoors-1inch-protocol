// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Test} from "forge-std/Test.sol";

import {Create2} from "src/lib/Create2.sol";
import {IV5AggregationExecutor} from "src/interfaces/IV5AggregationExecutor.sol";
import {IV5AggregationRouter} from "src/interfaces/IV5AggregationRouter.sol";
import {IV4AggregationExecutor} from "src/interfaces/IV4AggregationExecutor.sol";
import {IV4AggregationRouter} from "src/interfaces/IV4AggregationRouter.sol";
import {OneInchRouterFactory} from "src/RouterFactory.sol";
import {V5Router} from "src/V5Router.sol";
import {V4Router} from "src/V4Router.sol";
import {OneInchContracts} from "test/1InchContracts.sol";

interface IBadOneInchRouterFactory {
  enum BadRouterType {
    V4AggregationRouter,
    V5AggregationRouter,
    MadeUpRouter
  }

  function deploy(BadRouterType type_, address asset) external returns (address);
}

contract RouterFactoryTest is Test, OneInchContracts {
  OneInchRouterFactory factory;

  event RouterDeployed(OneInchRouterFactory.RouterType type_, address indexed asset);

  function setUp() public {
    factory = new OneInchRouterFactory(
            v5AggregationExecutor,
            v5AggregationRouter,
            v4AggregationExecutor,
            v4AggregationRouter
        );
  }
}

contract Constructor is RouterFactoryTest {
  function testFuzz_CorrectlySetsAllConstructorArgs(
    address v5AggregationExecutorAddress,
    address v5AggregationRouterAddress,
    address v4AggregationExecutorAddress,
    address v4AggregationRouterAddress
  ) public {
    IV5AggregationExecutor v5AggregationExecutor =
      IV5AggregationExecutor(v5AggregationExecutorAddress);
    IV5AggregationRouter v5AggregationRouter = IV5AggregationRouter(v5AggregationRouterAddress);
    IV4AggregationExecutor v4AggregationExecutor = IV4AggregationExecutor(v4AggregationExecutor);
    IV4AggregationRouter v4AggregationRouter = IV4AggregationRouter(v4AggregationRouterAddress);

    OneInchRouterFactory factory = new OneInchRouterFactory(
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
  function testFuzz_CorrectlyDeployV4Router(address asset) public {
    vm.expectEmit(true, true, true, true);
    emit RouterDeployed(OneInchRouterFactory.RouterType.V4AggregationRouter, asset);

    address deployedRouterAddress =
      factory.deploy(OneInchRouterFactory.RouterType.V4AggregationRouter, asset);

    factory.computeAddress(OneInchRouterFactory.RouterType.V4AggregationRouter, asset);
    assertEq(
      deployedRouterAddress,
      factory.computeAddress(OneInchRouterFactory.RouterType.V4AggregationRouter, asset),
      "Address not equal to computed v4 router address"
    );
  }

  function testFuzz_CorrectlyDeployV5Router(address asset) public {
    vm.expectEmit(true, true, true, true);
    emit RouterDeployed(OneInchRouterFactory.RouterType.V5AggregationRouter, asset);

    address deployedRouterAddress =
      factory.deploy(OneInchRouterFactory.RouterType.V5AggregationRouter, asset);

    assertEq(
      deployedRouterAddress,
      factory.computeAddress(OneInchRouterFactory.RouterType.V5AggregationRouter, asset),
      "Address not equal to computed v5 router address"
    );
  }

  function test_RevertIfUnsupportedRouterType() public {
    vm.expectRevert();
    IBadOneInchRouterFactory(address(factory)).deploy(
      IBadOneInchRouterFactory.BadRouterType.MadeUpRouter, USDC
    );
  }
}

contract ComputeAddress is RouterFactoryTest {
  function helper_salt(address asset) internal returns (bytes32) {
    return bytes32(uint256(uint160(asset)));
  }

  function helper_computeV4Address(address asset, address factoryAddr) internal returns (address) {
    return Create2.computeCreate2Address(
      helper_salt(asset),
      factoryAddr,
      type(V4Router).creationCode,
      abi.encode(v4AggregationRouter, v4AggregationExecutor, asset)
    );
  }

  function helper_computeV5Address(address asset, address factoryAddr) internal returns (address) {
    return Create2.computeCreate2Address(
      helper_salt(asset),
      factoryAddr,
      type(V5Router).creationCode,
      abi.encode(v5AggregationRouter, v5AggregationExecutor, asset)
    );
  }

  function testFuzz_ComputeV4Address(address asset) public {
    address computedAddress =
      factory.computeAddress(OneInchRouterFactory.RouterType.V4AggregationRouter, asset);
    assertEq(
      computedAddress,
      helper_computeV4Address(asset, address(factory)),
      "V4 computed address is not equal to its expected address"
    );
  }

  function testFuzz_ComputeV5Address(address asset) public {
    address computedAddress =
      factory.computeAddress(OneInchRouterFactory.RouterType.V5AggregationRouter, asset);
    assertEq(
      computedAddress,
      helper_computeV5Address(asset, address(factory)),
      "V5 computed address is not equal to its expected address"
    );
  }
}
