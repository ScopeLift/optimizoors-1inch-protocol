// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import {OneInchRouterFactory} from "src/RouterFactory.sol";
import {OneInchContracts} from "test/1InchContracts.sol";
import {IAggregationRouter} from "src/interfaces/IAggregationRouter.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract V5RouterForkTestBase is Test, OneInchContracts {
    OneInchRouterFactory factory;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("optimism"), 94_524_034);
        factory = new OneInchRouterFactory(
            aggreationExecutor,
            aggregationRouter
        );
        factory.deploy(USDC);
        deal(USDC, address(this), 100_000_000);
        // approve to send usdc
    }
}

// Is there a cheatcode to change the calling
// address. If so then I can get the calling data
// and run a test
contract V5RouterForkTest is V5RouterForkTestBase {
    function returnSlice(bytes calldata d) public returns (bytes memory) {
        return d[4:];
    }

    function test_swapUSDC() public {
        address addr = 0xEAC5F0d4A9a45E1f9FdD0e7e2882e9f60E301156;
        // Generated with the api
        bytes
            memory dataParams = hex"12aa3caf000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a0000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c316070000000000000000000000006fd9d7ad17242c41f7131d257212c54a0e816691000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a000000000000000000000000eac5f0d4a9a45e1f9fdd0e7e2882e9f60e30115600000000000000000000000000000000000000000000000000000000000186a0000000000000000000000000000000000000000000000000003e530a0ee30f45000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001f50000000000000000000000000000000000000000000000000000000001d700a007e5c0d20000000000000000000000000000000000000000000000000001b30001505126a132dab612db5cb9fc9ac426a0cc215a3423f9c97f5c764cbc14f9669b88837ca1490cca17c316070004f41766d8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002e2669c6242f00000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000f0694acc9e941b176e17b9ef923e71e7b8b2477a00000000000000000000000000000000000000000000000000000000644fdfe900000000000000000000000000000000000000000000000000000000000000010000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c316070000000000000000000000004200000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000102a0000000000000000000000000000000000000000000000000003e530a0ee30f45ee63c1e581ad4c666fc170b468b19988959eb931a3676f0e9f42000000000000000000000000000000000000061111111254eeb25477b68fb85ed929f73a9605820000000000000000000000cfee7c08";
        (
            address executor,
            IAggregationRouter.SwapDescription memory desc,
            bytes memory permit,
            bytes memory data
        ) = abi.decode(
                this.returnSlice(dataParams),
                (address, IAggregationRouter.SwapDescription, bytes, bytes)
            );
        console.logBytes(data);
        console.logBytes(permit);
        console.logAddress(address(desc.srcToken));
        console.logAddress(address(desc.dstToken));
        console.logAddress(desc.srcReceiver);
        console.logAddress(desc.dstReceiver);
        console.logUint(desc.amount);
        console.logUint(desc.minReturnAmount);
        console.logUint(desc.flags);
        vm.startPrank(0xEAC5F0d4A9a45E1f9FdD0e7e2882e9f60E301156);
        address routerAddr = factory.computeAddress(USDC);
        IERC20(USDC).approve(routerAddr, 100_000);
        uint256 startingBalance = IERC20(UNI).balanceOf(addr);
        // Check balance on UNI
        console.logAddress(addr);
        console.logUint(startingBalance);
        console.logBool(startingBalance == 0);
        assertTrue(startingBalance == 0);
        console.logAddress(address(factory));
        (bool ok, ) = payable(routerAddr).call(
            abi.encode(UNI, 100_000, desc.minReturnAmount, data, false)
        );
        assertTrue(ok);
        console.logAddress(addr);
        uint256 endingBalance = IERC20(UNI).balanceOf(addr);
        console.log(endingBalance);
        assertTrue(endingBalance == 17899388150783076);
    }
}
