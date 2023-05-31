// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Test} from "forge-std/Test.sol";

import {IV4AggregationExecutor} from "src/interfaces/IV4AggregationExecutor.sol";
import {IV4AggregationRouter} from "src/interfaces/IV4AggregationRouter.sol";
import {RouterFactory} from "src/RouterFactory.sol";
import {V4Router} from "src/V4Router.sol";
import {OneInchContracts} from "test/OneInchContracts.sol";

contract V4RouterTest is Test, OneInchContracts {}

contract Constructor is V4RouterTest {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl("optimism"), 95_544_472);
  }

  function testFork_CorrectlySetsAllConstructorArgs() public {
    V4Router router = new V4Router(
            v4AggregationRouter,
            v4AggregationExecutor,
            USDC
        );
    assertEq(
      address(router.AGGREGATION_ROUTER()),
      address(v4AggregationRouter),
      "AGGREGATION_ROUTER not set correctly"
    );
    assertEq(
      address(router.AGGREGATION_EXECUTOR()),
      address(v4AggregationExecutor),
      "AGGREGATION_EXECUTOR not set correctly"
    );
    assertEq(
      router.SOURCE_RECEIVER(), address(v4AggregationExecutor), "SOURCE_RECEIVER not set correctly"
    );
  }
}

contract Fallback is V4RouterTest {
  RouterFactory factory;
  // The address that is initiating the swap on 1inch.
  // This address is hardcoded because it needs to
  // match the address used to generate the data argument
  // needed for a swap.
  //
  // If the data argument in these tests is recreated
  // than this address will potentially need to change.
  address swapSenderAddress;
  address routerAddr;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl("optimism"), 95_544_472);
    factory = new RouterFactory(
            v5AggregationExecutor,
            v5AggregationRouter,
            v4AggregationExecutor,
            v4AggregationRouter
        );
    factory.deploy(RouterFactory.RouterType.V4AggregationRouter, USDC);
    deal(USDC, address(this), 100_000_000);
    swapSenderAddress = 0xEAC5F0d4A9a45E1f9FdD0e7e2882e9f60E301156;
    routerAddr = factory.computeAddress(RouterFactory.RouterType.V4AggregationRouter, USDC);
  }

  function helper_nativeSwap(IV4AggregationRouter.SwapDescription memory desc, bytes memory data)
    public
    returns (uint256)
  {
    v4AggregationRouter.swap(v4AggregationExecutor, desc, data);
    return IERC20(UNI).balanceOf(swapSenderAddress);
  }

  function helper_apiParams()
    public
    view
    returns (IV4AggregationRouter.SwapDescription memory, bytes memory)
  {
    // Calldata generated from calling the below api endpoint
    //
    // https://api.1inch.io/v4.0/10/swap?fromTokenAddress=0x7F5c764cBc14f9669B88837ca1490cCa17c31607&toTokenAddress=0x6fd9d7AD17242c41f7131d257212c54A0e816691&amount=250000&fromAddress=0xEAC5F0d4A9a45E1f9FdD0e7e2882e9f60E301156&slippage=1
    bytes memory dataParams =
      hex"7c025200000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000001800000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c316070000000000000000000000006fd9d7ad17242c41f7131d257212c54a0e816691000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a000000000000000000000000eac5f0d4a9a45e1f9fdd0e7e2882e9f60e30115600000000000000000000000000000000000000000000000000000000000186a0000000000000000000000000000000000000000000000000003e1aba8fed6bc100000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e10000000000000000000000000000000000000000000000000000000001a300a007e5c0d200000000000000000000000000000000000000000000000000017f00011c4330f9d5940c2313636546ab9852354860dce275dbad00000000000000000000000000000000000000000000000000002ecaf7212e2f002424b31a0c000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffd8963efd1fc6a506488495d951d5263988d2500000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000200000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c3160702a0000000000000000000000000000000000000000000000000003e1aba8fed6bc1ee63c1e581ad4c666fc170b468b19988959eb931a3676f0e9f42000000000000000000000000000000000000061111111254760f7ab3f16433eea9304126dcd19900000000000000000000000000000000000000000000000000000000000186a000000000000000000000000000000000000000000000000000000000000000cfee7c08";
    // Decode the api calldata to get the data parameter needed for both calls
    (, IV4AggregationRouter.SwapDescription memory desc, bytes memory data) = abi.decode(
      this.returnSliceBytes(dataParams), (address, IV4AggregationRouter.SwapDescription, bytes)
    );
    return (desc, data);
  }

  function testFork_SwapUsdcForUni() public {
    uint256 snapshotId = vm.snapshot();
    (IV4AggregationRouter.SwapDescription memory desc, bytes memory data) = helper_apiParams();
    // Setup the optimized router call
    vm.startPrank(swapSenderAddress);
    IERC20(USDC).approve(routerAddr, 100_000);
    uint256 startingUNIBalance = IERC20(UNI).balanceOf(swapSenderAddress);
    assertEq(startingUNIBalance, 0, "Starting balance is incorrect");

    // Optimized router call
    (bool ok,) =
      payable(routerAddr).call(abi.encode(UNI, encodeArgs(100_000, desc.minReturnAmount), data, 0));

    assertTrue(ok, "Swap failed");

    // Compare balance to native aggregation router call

    uint256 endingUNIBalance = IERC20(UNI).balanceOf(swapSenderAddress);
    uint256 endingUSDCBalance = IERC20(USDC).balanceOf(swapSenderAddress);
    vm.revertTo(snapshotId);
    uint256 nativeEndingUNIBalance = helper_nativeSwap(desc, data);
    uint256 nativeEndingUSDCBalance = IERC20(USDC).balanceOf(swapSenderAddress);

    assertEq(
      endingUNIBalance,
      nativeEndingUNIBalance,
      "Ending UNI balance does not match the balance when calling 1inch directly"
    );
    assertEq(
      endingUSDCBalance,
      nativeEndingUSDCBalance,
      "Ending USDC balance does not match the balance when calling 1inch directly"
    );
  }

  function testFork_RevertIf_NotEnoughFunds() public {
    (IV4AggregationRouter.SwapDescription memory desc, bytes memory data) = helper_apiParams();

    vm.startPrank(swapSenderAddress);
    IERC20(USDC).approve(routerAddr, 10_000_000);
    uint256 startingBalance = IERC20(USDC).balanceOf(swapSenderAddress);
    (bool ok,) = payable(routerAddr).call(
      abi.encode(UNI, encodeArgs(10_000_000, desc.minReturnAmount), data, 0)
    );
    uint256 endingBalance = IERC20(USDC).balanceOf(swapSenderAddress);

    assertTrue(!ok, "Swap succeeded");
    assertEq(startingBalance, endingBalance, "Funds were held by the router contract");
  }

  function testFork_RevertIf_ZeroAddress() public {
    (IV4AggregationRouter.SwapDescription memory desc, bytes memory data) = helper_apiParams();
    IERC20(USDC).approve(routerAddr, 250_000);
    uint256 startingBalance = IERC20(USDC).balanceOf(swapSenderAddress);
    (bool ok,) = payable(routerAddr).call(
      abi.encode(address(0), encodeArgs(250_000, desc.minReturnAmount), data, 0)
    );
    uint256 endingBalance = IERC20(USDC).balanceOf(swapSenderAddress);

    assertTrue(!ok, "Swap succeeded");
    assertEq(startingBalance, endingBalance, "Funds were held by the router contract");
  }
}
