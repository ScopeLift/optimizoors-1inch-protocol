// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Test} from "forge-std/Test.sol";

import {OneInchRouterFactory} from "src/RouterFactory.sol";
import {OneInchContracts} from "test/1InchContracts.sol";
import {IV4AggregationRouter} from "src/interfaces/IV4AggregationRouter.sol";

contract V4RouterForkTestBase is Test, OneInchContracts {
  OneInchRouterFactory factory;
  address addr;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl("optimism"), 95_544_472);
    factory = new OneInchRouterFactory(
            v5AggregationExecutor,
            v5AggregationRouter,
            v4AggregationExecutor,
            v4AggregationRouter
        );
    factory.deploy(OneInchRouterFactory.RouterTypes.V4AggregationRouter, USDC);
    deal(USDC, address(this), 100_000_000);
    addr = 0xEAC5F0d4A9a45E1f9FdD0e7e2882e9f60E301156;
  }
}

contract V4RouterForkTest is V4RouterForkTestBase {
  function nativeSwap(
    IV4AggregationRouter.SwapDescription memory desc,
    bytes memory data,
    uint256 snapshotId
  ) public returns (uint256) {
    vm.revertTo(snapshotId);
    v4AggregationRouter.swap(v4AggregationExecutor, desc, data);
    return IERC20(UNI).balanceOf(addr);
  }

  function test_swapUSDC() public {
    uint256 snapshotId = vm.snapshot();
    // Calldata generated from calling 1inch's api
    bytes memory dataParams =
      hex"7c025200000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000001800000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c316070000000000000000000000006fd9d7ad17242c41f7131d257212c54a0e816691000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a000000000000000000000000eac5f0d4a9a45e1f9fdd0e7e2882e9f60e30115600000000000000000000000000000000000000000000000000000000000186a0000000000000000000000000000000000000000000000000003e1aba8fed6bc100000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e10000000000000000000000000000000000000000000000000000000001a300a007e5c0d200000000000000000000000000000000000000000000000000017f00011c4330f9d5940c2313636546ab9852354860dce275dbad00000000000000000000000000000000000000000000000000002ecaf7212e2f002424b31a0c000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffd8963efd1fc6a506488495d951d5263988d2500000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000200000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c3160702a0000000000000000000000000000000000000000000000000003e1aba8fed6bc1ee63c1e581ad4c666fc170b468b19988959eb931a3676f0e9f42000000000000000000000000000000000000061111111254760f7ab3f16433eea9304126dcd19900000000000000000000000000000000000000000000000000000000000186a000000000000000000000000000000000000000000000000000000000000000cfee7c08";
    // Decode the api calldata to get the data parameter needed for both calls
    (, IV4AggregationRouter.SwapDescription memory desc, bytes memory data) = abi.decode(
      this.returnSliceBytes(dataParams), (address, IV4AggregationRouter.SwapDescription, bytes)
    );

    // Setup the optimized router call
    vm.startPrank(0xEAC5F0d4A9a45E1f9FdD0e7e2882e9f60E301156);
    address routerAddr =
      factory.computeAddress(OneInchRouterFactory.RouterTypes.V4AggregationRouter, USDC);
    IERC20(USDC).approve(routerAddr, 100_000);
    uint256 startingBalance = IERC20(UNI).balanceOf(addr);
    assertTrue(startingBalance == 0);

    // Optimized router call
    (bool ok,) = payable(routerAddr).call(abi.encode(UNI, 100_000, desc.minReturnAmount, data, 0));

    assertTrue(ok);

    // Compare balance to native aggregation router call
    uint256 endingBalance = IERC20(UNI).balanceOf(addr);
    uint256 nativeEndingBalance = nativeSwap(desc, data, snapshotId);
    assertTrue(endingBalance == nativeEndingBalance);
  }
}
