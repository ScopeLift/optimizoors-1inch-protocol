// executor can be removed
// srcToken: each contract is a src token
// dstToken: Can be represented by an integer??
// amount: strat
// minReturnAmount: strat
// flags?
// permit?
// data - don't think we can do anything, comes from their api.
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IAggregationExecutor} from "src/interfaces/AggregationExecutionRouter.sol";


// Struct for the aggregation router
struct SwapDescription {
    IERC20 srcToken;
    IERC20 dstToken;
    address payable srcReceiver;
    address payable dstReceiver;
    uint256 amount;
    uint256 minReturnAmount;
    uint256 flags;
}

abstract contract AggregationBaseRouter {
		  IAggregationExecutor public immutable AGGREGATION_EXECUTOR;

  address public immutable TOKEN;
  address public immutable SOURCE_RECEIVER;

  constructor(
    IAggregationExecutor aggreationExecutor,
    address token,
	address sourceReceiver
  ) {
		  AGGREGATION_EXECUTOR = aggreationExecutor;
		  TOKEN = token;
		  SOURCE_RECEIVER = sourceReceiver;
  }



}

contract V5Router {

		//
		function fallback() external payable {
			// This is the fallback function

		}
}
