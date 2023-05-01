// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {IV5AggregationExecutor} from "src/interfaces/IV5AggregationExecutor.sol";
import {IV5AggregationRouter} from "src/interfaces/IV5AggregationRouter.sol";
import {AggregationV5BaseRouter} from "src/AggregationBaseRouter.sol";

/// @notice A router to swap tokens using 1inch v5 aggregation
contract V5Router is AggregationV5BaseRouter {
  constructor(
    IV5AggregationRouter aggregationRouter,
    IV5AggregationExecutor aggregationExecutor,
    address token,
    address sourceReceiver
  ) AggregationV5BaseRouter(aggregationExecutor, aggregationRouter, token, sourceReceiver) {}

  receive() external payable {}

  // TODO: minReturnAmount is the minimum allowed output amount, and can probably reduced to a max
  // int of 500.
  //
  // the flags match specific constant masks. there is no documentation on these, and there seems to
  // be no specific logic on them
  fallback() external payable {
    (address dstToken, uint256 amount, uint256 minReturnAmount, bytes memory data, bool flags) =
      abi.decode(msg.data, (address, uint256, uint256, bytes, bool));
    IERC20(TOKEN).transferFrom(msg.sender, address(this), amount);
    IERC20(TOKEN).approve(address(AGGREGATION_ROUTER), amount);
    AGGREGATION_ROUTER.swap(
      AGGREGATION_EXECUTOR,
      IV5AggregationRouter.SwapDescription({
        srcToken: IERC20(TOKEN),
        dstToken: IERC20(dstToken),
        srcReceiver: payable(SOURCE_RECEIVER),
        dstReceiver: payable(msg.sender),
        amount: amount,
        minReturnAmount: minReturnAmount,
        flags: flags ? 1 : 0
      }),
      "",
      data
    );
  }
}
