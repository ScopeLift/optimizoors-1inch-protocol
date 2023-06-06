// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

  // Flags match specific constant masks. There is no documentation on these.
  fallback() external payable {
    address dstToken = address(bytes20(msg.data[0:20]));
    uint256 amount = uint256(uint96(bytes12(msg.data[20:32])));
    uint256 minReturnAmount = uint256(uint96(bytes12(msg.data[32:44])));
    uint256 flags = uint256(uint8(bytes1(msg.data[44:45])));
    bytes memory data = bytes(msg.data[45:msg.data.length]);

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
