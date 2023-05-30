// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {IV4AggregationExecutor} from "src/interfaces/IV4AggregationExecutor.sol";
import {IV4AggregationRouter} from "src/interfaces/IV4AggregationRouter.sol";
import {AggregationV4BaseRouter} from "src/AggregationBaseRouter.sol";
import "forge-std/console2.sol";

/// @notice An optimized router to swap tokens using 1inch's v4 aggregation router.
contract V4Router is AggregationV4BaseRouter {
  constructor(
    IV4AggregationRouter aggregationRouter,
    IV4AggregationExecutor aggregationExecutor,
    address token
  ) AggregationV4BaseRouter(aggregationExecutor, aggregationRouter, token) {
    IERC20(token).approve(address(aggregationRouter), type(uint256).max);
  }

  // TODO: Update to handle receiving ETH
  receive() external payable {}

  /// @dev Returns the `sqrtPriceLimitX96` from a `uint168`.
  /// @param args A `uint168` that contains both the `funcId` and the `sqrtPriceLimitX96` needed to
  /// open or close a position.
  function _extractMinReturnAmount(uint192 args) internal pure returns (uint96) {
    uint168 mask = (1 << 96) - 1;
    return uint96(args & mask);
  }

  /// @dev Returns the `sqrtPriceLimitX96` from a `uint168`.
  /// @param args A `uint168` that contains both the `funcId` and the `sqrtPriceLimitX96` needed to
  /// open or close a position.
  function _extractAmount(uint192 args) internal pure returns (uint96) {
    uint192 firstNinetySixBitMask = ((1 << 96) - 1) << 96;
    return uint96((args & firstNinetySixBitMask) >> 96);
  }



  // Flags match specific constant masks. There is no documentation on these.
  fallback() external payable {
    (address dstToken, uint192 args, bytes memory data, uint256 flags) =
      abi.decode(msg.data, (address, uint192, bytes, uint256));

	uint96 amount = _extractAmount(args);
	uint96 minReturnAmount = _extractMinReturnAmount(args);
    IERC20(TOKEN).transferFrom(msg.sender, address(this), amount);
    AGGREGATION_ROUTER.swap(
      AGGREGATION_EXECUTOR,
      IV4AggregationRouter.SwapDescription({
        srcToken: IERC20(TOKEN),
        dstToken: IERC20(dstToken),
        srcReceiver: payable(SOURCE_RECEIVER),
        dstReceiver: payable(msg.sender),
        amount: amount,
        minReturnAmount: minReturnAmount,
        flags: flags,
        permit: ""
      }),
      data
    );
  }
}
