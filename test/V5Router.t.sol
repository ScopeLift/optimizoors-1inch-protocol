// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Test} from "forge-std/Test.sol";

import {IV5AggregationRouter} from "src/interfaces/IV5AggregationRouter.sol";
import {IV5AggregationExecutor} from "src/interfaces/IV5AggregationExecutor.sol";
import {RouterFactory} from "src/RouterFactory.sol";
import {V5Router} from "src/V5Router.sol";
import {OneInchContracts} from "test/OneInchContracts.sol";

contract V5RouterTest is Test, OneInchContracts {}

contract Constructor is V5RouterTest {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl("optimism"), 95_544_472);
  }

  function testFork_CorrectlySetsAllConstructorArgs() public {
    V5Router router = new V5Router(
            v5AggregationRouter,
            v5AggregationExecutor,
            USDC
        );
    assertEq(
      address(router.AGGREGATION_ROUTER()),
      address(v5AggregationRouter),
      "AGGREGATION_ROUTER not set correctly"
    );
    assertEq(
      address(router.AGGREGATION_EXECUTOR()),
      address(v5AggregationExecutor),
      "AGGREGATION_EXECUTOR not set correctly"
    );
    assertEq(
      router.SOURCE_RECEIVER(), address(v5AggregationExecutor), "SOURCE_RECEIVER not set correctly"
    );
  }
}

contract Receive is V5RouterTest {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl("optimism"), 95_544_472);
  }

  function testFork_RevertIf_Called(uint256 amount) public {
    V5Router router = new V5Router(
       v5AggregationRouter,
       v5AggregationExecutor,
       USDC
    );

    vm.deal(address(this), amount);

    vm.expectRevert(bytes(""));
    (bool ok,) = payable(address(router)).call{value: amount}("");

    assertTrue(!ok, "Call did not revert");
    assertEq(address(this).balance, amount, "Router did not return all funds");
    assertEq(address(router).balance, 0, "Router kept some funds");
  }
}

contract Fallback is V5RouterTest {
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
    swapSenderAddress = 0xEAC5F0d4A9a45E1f9FdD0e7e2882e9f60E301156;

    routerAddr = factory.computeAddress(RouterFactory.RouterType.V5AggregationRouter, USDC);
  }

  function helper_apiParams()
    public
    view
    returns (IV5AggregationRouter.SwapDescription memory, bytes memory, bytes memory)
  {
    // Calldata generated from calling the below endpoint
    //
    // https://api.1inch.io/v5.0/10/swap?fromTokenAddress=0x7F5c764cBc14f9669B88837ca1490cCa17c31607&toTokenAddress=0x6fd9d7AD17242c41f7131d257212c54A0e816691&amount=250000&fromAddress=0xEAC5F0d4A9a45E1f9FdD0e7e2882e9f60E301156&slippage=1
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
    bytes memory data
  ) public returns (uint256) {
    v5AggregationRouter.swap(v5AggregationExecutor, desc, permit, data);
    return IERC20(UNI).balanceOf(swapSenderAddress);
  }

  function testFork_SwapUSDCForUni() public {
    uint256 snapshotId = vm.snapshot();
    (IV5AggregationRouter.SwapDescription memory desc, bytes memory permit, bytes memory data) =
      helper_apiParams();
    // Setup optimized router call
    vm.startPrank(swapSenderAddress);
    IERC20(USDC).approve(routerAddr, 100_000);
    uint256 startingUNIBalance = IERC20(UNI).balanceOf(swapSenderAddress);
    assertEq(startingUNIBalance, 0, "Starting balance is not 0");

    // Optimized router call
    (bool ok,) = payable(routerAddr).call(
      abi.encodePacked(UNI, uint96(100_000), uint96(desc.minReturnAmount), uint8(0), data)
    );

    assertTrue(ok, "Swap failed");

    // Compare balance to native aggregation router call
    uint256 endingUNIBalance = IERC20(UNI).balanceOf(swapSenderAddress);
    uint256 endingUSDCBalance = IERC20(USDC).balanceOf(swapSenderAddress);

    vm.revertTo(snapshotId);
    uint256 nativeEndingUNIBalance = helper_nativeSwap(desc, permit, data);
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
    (IV5AggregationRouter.SwapDescription memory desc,, bytes memory data) = helper_apiParams();

    vm.startPrank(swapSenderAddress);
    IERC20(USDC).approve(routerAddr, 10_000_000);
    uint256 startingBalance = IERC20(USDC).balanceOf(swapSenderAddress);
    (bool ok,) = payable(routerAddr).call(
      abi.encodePacked(UNI, uint96(10_000_000), uint96(desc.minReturnAmount), uint8(0), data)
    );
    uint256 endingBalance = IERC20(USDC).balanceOf(swapSenderAddress);

    assertTrue(!ok, "Swap succeeded");
    assertEq(startingBalance, endingBalance, "Funds were held by the router contract");
  }

  function testFork_RevertIf_ZeroAddress() public {
    (IV5AggregationRouter.SwapDescription memory desc,, bytes memory data) = helper_apiParams();
    IERC20(USDC).approve(routerAddr, 250_000);
    uint256 startingBalance = IERC20(USDC).balanceOf(swapSenderAddress);
    (bool ok,) = payable(routerAddr).call(
      abi.encodePacked(
        address(0), uint96(250_000), uint96(desc.minReturnAmount), uint8(0), bytes(data)
      )
    );
    uint256 endingBalance = IERC20(USDC).balanceOf(swapSenderAddress);
    assertTrue(!ok, "Swap succeeded");
    assertEq(startingBalance, endingBalance, "Funds were held by the router contract");
  }
}
