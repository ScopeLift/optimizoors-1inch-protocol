// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Script, stdJson} from "forge-std/Script.sol";

import {IV5AggregationRouter} from "src/interfaces/IV5AggregationRouter.sol";
import {IV4AggregationRouter} from "src/interfaces/IV4AggregationRouter.sol";
import {OneInchContracts} from "test/OneInchContracts.sol";
import "forge-std/console.sol";

// Script to get benchmarks the test will need
// to be swapped out for new data as it is meant
// to be used by a specific test wallet
contract Benchmark is Script, OneInchContracts {
  using stdJson for string;

  error OptimizedV4RouterFailed();
  error OptimizedV5RouterFailed();

  bytes public v5DataParams =
    hex"12aa3caf000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a0000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c316070000000000000000000000006fd9d7ad17242c41f7131d257212c54a0e816691000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a000000000000000000000000eac5f0d4a9a45e1f9fdd0e7e2882e9f60e30115600000000000000000000000000000000000000000000000000000000000186a0000000000000000000000000000000000000000000000000003e530a0ee30f45000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001f50000000000000000000000000000000000000000000000000000000001d700a007e5c0d20000000000000000000000000000000000000000000000000001b30001505126a132dab612db5cb9fc9ac426a0cc215a3423f9c97f5c764cbc14f9669b88837ca1490cca17c316070004f41766d8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002e2669c6242f00000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a00000000000000000000000000000000000000000000000000000000644fdfe900000000000000000000000000000000000000000000000000000000000000010000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c316070000000000000000000000004200000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000102a0000000000000000000000000000000000000000000000000003e530a0ee30f45ee63c1e581ad4c666fc170b468b19988959eb931a3676f0e9f42000000000000000000000000000000000000061111111254eeb25477b68fb85ed929f73a9605820000000000000000000000cfee7c08";
  bytes public v4DataParams =
    hex"7c025200000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000001800000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c316070000000000000000000000006fd9d7ad17242c41f7131d257212c54a0e816691000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a000000000000000000000000eac5f0d4a9a45e1f9fdd0e7e2882e9f60e30115600000000000000000000000000000000000000000000000000000000000186a0000000000000000000000000000000000000000000000000003e1aba8fed6bc100000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e10000000000000000000000000000000000000000000000000000000001a300a007e5c0d200000000000000000000000000000000000000000000000000017f00011c4330f9d5940c2313636546ab9852354860dce275dbad00000000000000000000000000000000000000000000000000002ecaf7212e2f002424b31a0c000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffd8963efd1fc6a506488495d951d5263988d2500000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000200000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c3160702a0000000000000000000000000000000000000000000000000003e1aba8fed6bc1ee63c1e581ad4c666fc170b468b19988959eb931a3676f0e9f42000000000000000000000000000000000000061111111254760f7ab3f16433eea9304126dcd19900000000000000000000000000000000000000000000000000000000000186a000000000000000000000000000000000000000000000000000000000000000cfee7c08";

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
    (bool v5Ok,) =
      payable(v5Rtr).call(abi.encode(UNI, 100_000, v5Desc.minReturnAmount, v5Data, false));

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
    (bool v4Ok,) =
      payable(v4Rtr).call(abi.encode(UNI, 100_000, v4Desc.minReturnAmount, v4Data, false));
    if (!v4Ok) revert OptimizedV4RouterFailed();
  }
}
