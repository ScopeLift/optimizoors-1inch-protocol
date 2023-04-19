// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

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
		  IAccountBalance public immutable ACCOUNT_BALANCE;

  address public immutable TOKEN;
  address public immutable SOURCE_RECEIVER;

  constructor(
    IClearingHouse clearingHouse,
    address asset,
    bool isBaseToQuote,
    bool isExactInput,
    IAccountBalance accountBalance
  ) {
    PERPETUAL_CLEARING_HOUSE = clearingHouse;
    IS_BASE_TO_QUOTE = isBaseToQuote;
    IS_EXACT_INPUT = isExactInput;
    TOKEN = asset;
    ACCOUNT_BALANCE = accountBalance;
  }



}

contract V5Router {

		//
		function fallback() external payable {
			// This is the fallback function

		}
}
