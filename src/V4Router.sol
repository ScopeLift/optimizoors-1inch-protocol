// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {IV4AggregationExecutor} from "src/interfaces/IV4AggregationExecutor.sol";
import {IV4AggregationRouter} from "src/interfaces/IV4AggregationRouter.sol";
import {AggregationV4BaseRouter} from "src/AggregationBaseRouter.sol";

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
