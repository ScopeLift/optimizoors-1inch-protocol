// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Test} from "forge-std/Test.sol";

import {IV5AggregationRouter} from "src/interfaces/IV5AggregationRouter.sol";
import {IV5AggregationExecutor} from "src/interfaces/IV5AggregationExecutor.sol";
import {RouterFactory} from "src/RouterFactory.sol";
import {V5Router} from "src/V5Router.sol";
import {OneInchContracts} from "test/1InchContracts.sol";

contract V5RouterTest is Test, OneInchContracts {}

contract Constructor is V5RouterTest {
  function testFuzz_CorrectlySetsAllConstructorArgs(
    address aggregationRouterAddress,
    address aggregationExecutorAddress,
    address token
  ) public {
    IV5AggregationRouter aggregationRouter = IV5AggregationRouter(aggregationRouterAddress);
    IV5AggregationExecutor aggregationExecutor = IV5AggregationExecutor(aggregationExecutorAddress);
    V5Router router = new V5Router(
            aggregationRouter,
            aggregationExecutor,
            token
        );
    assertEq(
      address(router.AGGREGATION_ROUTER()),
      aggregationRouterAddress,
      "AGGREGATION_ROUTER not set correctly"
    );
    assertEq(
      address(router.AGGREGATION_EXECUTOR()),
      aggregationExecutorAddress,
      "AGGREGATION_EXECUTOR not set correctly"
    );
    assertEq(
      router.SOURCE_RECEIVER(), aggregationExecutorAddress, "SOURCE_RECEIVER not set correctly"
    );
  }
}

contract Fallback is V5RouterTest {
  RouterFactory factory;
  address swappingAddress;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl("optimism"), 94_524_034);
    factory = new RouterFactory(
            v5AggregationExecutor,
            v5AggregationRouter,
            v4AggregationExecutor,
            v4AggregationRouter
        );
    factory.deploy(RouterFactory.RouterType.V5AggregationRouter, USDC);
    deal(USDC, address(this), 100_000_000);
    // Address the api calldata uses as the swapper
    swappingAddress = 0xEAC5F0d4A9a45E1f9FdD0e7e2882e9f60E301156;
  }

  function helper_apiParams()
    public
    view
    returns (IV5AggregationRouter.SwapDescription memory, bytes memory, bytes memory)
  {
    // Calldata generated from calling 1inch's api
    bytes memory dataParams =
      hex"12aa3caf000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a0000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c316070000000000000000000000006fd9d7ad17242c41f7131d257212c54a0e816691000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a000000000000000000000000eac5f0d4a9a45e1f9fdd0e7e2882e9f60e30115600000000000000000000000000000000000000000000000000000000000186a0000000000000000000000000000000000000000000000000003e530a0ee30f45000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001f50000000000000000000000000000000000000000000000000000000001d700a007e5c0d20000000000000000000000000000000000000000000000000001b30001505126a132dab612db5cb9fc9ac426a0cc215a3423f9c97f5c764cbc14f9669b88837ca1490cca17c316070004f41766d8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002e2669c6242f00000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a00000000000000000000000000000000000000000000000000000000644fdfe900000000000000000000000000000000000000000000000000000000000000010000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c316070000000000000000000000004200000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000102a0000000000000000000000000000000000000000000000000003e530a0ee30f45ee63c1e581ad4c666fc170b468b19988959eb931a3676f0e9f42000000000000000000000000000000000000061111111254eeb25477b68fb85ed929f73a9605820000000000000000000000cfee7c08";
    // Decode api calldata to get the data parameter needed for both calls
    (, IV5AggregationRouter.SwapDescription memory desc, bytes memory permit, bytes memory data) =
    abi.decode(
      this.returnSliceBytes(dataParams),
      (address, IV5AggregationRouter.SwapDescription, bytes, bytes)
    );
    return (desc, permit, data);
  }

  function helper_nativeSwap(
    IV5AggregationRouter.SwapDescription memory desc,
    bytes memory permit,
    bytes memory data,
    uint256 snapshotId
  ) public returns (uint256) {
    vm.revertTo(snapshotId);
    v5AggregationRouter.swap(v5AggregationExecutor, desc, permit, data);
    return IERC20(UNI).balanceOf(swappingAddress);
  }

  function testFork_RevertIf_NotEnoughFunds() public {
    (IV5AggregationRouter.SwapDescription memory desc, bytes memory permit, bytes memory data) =
      helper_apiParams();

    address routerAddr = factory.computeAddress(RouterFactory.RouterType.V5AggregationRouter, USDC);
    uint256 balance = IERC20(USDC).balanceOf(swappingAddress);
    vm.startPrank(swappingAddress);
    IERC20(USDC).approve(routerAddr, 10_000_000);
    (bool ok,) =
      payable(routerAddr).call(abi.encode(UNI, 10_000_000, desc.minReturnAmount, data, 0));
    assertTrue(!ok, "Swap succeeded");
  }

  function testFork_RevertIf_ZeroAddress() public {
    (IV5AggregationRouter.SwapDescription memory desc, bytes memory permit, bytes memory data) =
      helper_apiParams();
    address routerAddr = factory.computeAddress(RouterFactory.RouterType.V5AggregationRouter, USDC);
    IERC20(USDC).approve(routerAddr, 250_000);
    (bool ok,) =
      payable(routerAddr).call(abi.encode(address(0), 250_000, desc.minReturnAmount, data, 0));
    assertTrue(!ok, "Swap succeeded");
  }

  function testFork_swapUSDC() public {
    uint256 snapshotId = vm.snapshot();
    (IV5AggregationRouter.SwapDescription memory desc, bytes memory permit, bytes memory data) =
      helper_apiParams();
    // Setup optimized router call
    vm.startPrank(swappingAddress);
    address routerAddr = factory.computeAddress(RouterFactory.RouterType.V5AggregationRouter, USDC);
    IERC20(USDC).approve(routerAddr, 100_000);
    uint256 startingBalance = IERC20(UNI).balanceOf(swappingAddress);
    assertTrue(startingBalance == 0);

    // Optimized router call
    (bool ok,) = payable(routerAddr).call(abi.encode(UNI, 100_000, desc.minReturnAmount, data, 0));

    assertTrue(ok);

    // Compare balance to native aggregation router call
    uint256 endingBalance = IERC20(UNI).balanceOf(swappingAddress);
    uint256 nativeEndingBalance = helper_nativeSwap(desc, permit, data, snapshotId);
    assertTrue(endingBalance == nativeEndingBalance);
  }
}
