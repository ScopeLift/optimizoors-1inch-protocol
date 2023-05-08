// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {IV5AggregationExecutor} from "src/interfaces/IV5AggregationExecutor.sol";
import {IV5AggregationRouter} from "src/interfaces/IV5AggregationRouter.sol";
import {AggregationV5BaseRouter} from "src/AggregationBaseRouter.sol";

/// @notice A router to swap tokens using 1inch's v5 aggregation router.
contract V5Router is AggregationV5BaseRouter {
  constructor(
    IV5AggregationRouter aggregationRouter,
    IV5AggregationExecutor aggregationExecutor,
    address token
  ) AggregationV5BaseRouter(aggregationExecutor, aggregationRouter, token) {}

  // TODO: Update to handle receiving ETH
  receive() external payable {}

  // TODO: minReturnAmount is the minimum allowed output amount, and
  // can probably be reduced to a max integer of 500 or something of
  // a similar magnitude. Also, amount and destination have
  // opportunities to be optimized.
  //
  // Flags match specific constant masks. There is no documentation on these.
  fallback() external payable {
    (address dstToken, uint256 amount, uint256 minReturnAmount, bytes memory data, uint256 flags) =
      abi.decode(msg.data, (address, uint256, uint256, bytes, uint256));
    IERC20(TOKEN).transferFrom(msg.sender, address(this), amount);
    IERC20(TOKEN).approve(address(AGGREGATION_ROUTER), type(uint256).max);
    AGGREGATION_ROUTER.swap(
      AGGREGATION_EXECUTOR,
      IV5AggregationRouter.SwapDescription({
        srcToken: IERC20(TOKEN),
        dstToken: IERC20(dstToken),
        srcReceiver: payable(SOURCE_RECEIVER),
        dstReceiver: payable(msg.sender),
        amount: amount,
        minReturnAmount: minReturnAmount,
        flags: flags
      }),
      "",
      data
    );
  }
}
