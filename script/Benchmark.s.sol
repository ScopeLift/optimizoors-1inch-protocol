// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Script, stdJson} from "forge-std/Script.sol";

import {IV5AggregationRouter} from "src/interfaces/IV5AggregationRouter.sol";
import {IV4AggregationRouter} from "src/interfaces/IV4AggregationRouter.sol";
import {OneInchContracts} from "test/OneInchContracts.sol";

// A script to get benchmarks for 1inch's V4 and V5 router against the optimized routers. Due to
// 1inch requiring their api be used to generate the data parameter the benchmarks are tied to a
// specific wallet. When rerunning these benchmrks it is recommended to regenerate the v4 and v5
// data params with a new wallet address using the api calls below.
contract Benchmark is Script, OneInchContracts {
  using stdJson for string;

  error OptimizedV4RouterFailed();
  error OptimizedV5RouterFailed();

  // Data was generated with the below api call:
  // https://api.1inch.io/v5.0/10/swap?fromTokenAddress=0x7F5c764cBc14f9669B88837ca1490cCa17c31607&toTokenAddress=0xda10009cbd5d07dd0cecc66161fc93d7c9000da1&amount=100000&fromAddress=0xEAC5F0d4A9a45E1f9FdD0e7e2882e9f60E301156&slippage=1
  bytes public v5DataParams =
    hex"12aa3caf000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a0000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c31607000000000000000000000000da10009cbd5d07dd0cecc66161fc93d7c9000da1000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a000000000000000000000000eac5f0d4a9a45e1f9fdd0e7e2882e9f60e30115600000000000000000000000000000000000000000000000000000000000186a0000000000000000000000000000000000000000000000000015fe617f1829bdb0000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000001600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008100000000000000000000000000000000000000000000000000000000006300a0fbb7cd0680373643b17cd80e37675c8c98ef774efe6ca0b4de00000000000000000000001c7f5c764cbc14f9669b88837ca1490cca17c31607da10009cbd5d07dd0cecc66161fc93d7c9000da11111111254eeb25477b68fb85ed929f73a96058200000000000000000000000000000000000000000000000000000000000000cfee7c08";

  // Data was generated with the below api call:
  // https://api.1inch.io/v4.0/10/swap?fromTokenAddress=0x7F5c764cBc14f9669B88837ca1490cCa17c31607&toTokenAddress=0xda10009cbd5d07dd0cecc66161fc93d7c9000da1&amount=100000&fromAddress=0xEAC5F0d4A9a45E1f9FdD0e7e2882e9f60E301156&slippage=1
  bytes public v4DataParams =
    hex"7c025200000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000001800000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c31607000000000000000000000000da10009cbd5d07dd0cecc66161fc93d7c9000da1000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a000000000000000000000000eac5f0d4a9a45e1f9fdd0e7e2882e9f60e30115600000000000000000000000000000000000000000000000000000000000186a0000000000000000000000000000000000000000000000000015fe617f1829bdb00000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a100000000000000000000000000000000000000000000000000000000006300a0fbb7cd0680373643b17cd80e37675c8c98ef774efe6ca0b4de00000000000000000000001c7f5c764cbc14f9669b88837ca1490cca17c31607da10009cbd5d07dd0cecc66161fc93d7c9000da11111111254760f7ab3f16433eea9304126dcd19900000000000000000000000000000000000000000000000000000000000186a000000000000000000000000000000000000000000000000000000000000000cfee7c08";

  function run() public {
    require(block.chainid == 10, "script can only be run on optimism");
    string memory file = "broadcast/Deploy.s.sol/10/run-latest.json";
    string memory json = vm.readFile(file);

    address v5Rtr = json.readAddress(".transactions[1].additionalContracts[0].address");
    address v4Rtr = json.readAddress(".transactions[2].additionalContracts[0].address");

    // ===========================
    // ======== Execution ========
    // ===========================

    vm.startBroadcast();
    // Optimized v5 router approval
    IERC20(USDC).approve(v5Rtr, 100_000);
    // Regular v5 router approval
    IERC20(USDC).approve(address(v5AggregationRouter), 100_000);

    // Parse calldata returned by the api to get params
    (
      ,
      IV5AggregationRouter.SwapDescription memory v5Desc,
      bytes memory v5Permit,
      bytes memory v5Data
    ) = abi.decode(
      this.returnSliceBytes(v5DataParams),
      (address, IV5AggregationRouter.SwapDescription, bytes, bytes)
    );
    // Regular v5 swap call
    v5AggregationRouter.swap(v5AggregationExecutor, v5Desc, v5Permit, v5Data);

    // Optimized router v5 swap call
    (bool v5Ok,) = payable(v5Rtr).call(
      abi.encodePacked(DAI, uint96(100_000), uint96(v5Desc.minReturnAmount), uint256(0), v5Data)
    );

    if (!v5Ok) revert OptimizedV5RouterFailed();

    // Parse v4 calldata returned by the 1inch api
    (, IV4AggregationRouter.SwapDescription memory v4Desc, bytes memory v4Data) = abi.decode(
      this.returnSliceBytes(v4DataParams), (address, IV4AggregationRouter.SwapDescription, bytes)
    );

    // Optimized v4 router approval
    IERC20(USDC).approve(v4Rtr, 100_000);
    // Regular v4 router approval
    IERC20(USDC).approve(address(v4AggregationRouter), 100_000);

    // Regular v4 swap call
    v4AggregationRouter.swap(v4AggregationExecutor, v4Desc, v4Data);

    // Optimized v4 swap call
    (bool v4Ok,) = payable(v4Rtr).call(
      abi.encodePacked(DAI, uint96(100_000), uint96(v4Desc.minReturnAmount), uint256(0), v4Data)
    );
    if (!v4Ok) revert OptimizedV4RouterFailed();
  }
}
