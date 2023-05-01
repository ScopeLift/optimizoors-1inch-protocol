// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IV5AggregationExecutor} from "src/interfaces/IV5AggregationExecutor.sol";
import {IV5AggregationRouter} from "src/interfaces/IV5AggregationRouter.sol";
import {IV4AggregationExecutor} from "src/interfaces/IV4AggregationExecutor.sol";
import {IV4AggregationRouter} from "src/interfaces/IV4AggregationRouter.sol";

/// @notice An abstract class with the necessary class variables to make a aggregation v5 optimized
/// router
abstract contract AggregationV5BaseRouter {
  /// @notice The contract used to execute the swap along an optimized path
  IV5AggregationExecutor public immutable AGGREGATION_EXECUTOR;

  /// @notice The 1inch contract with the unoptimized route
  IV5AggregationRouter public immutable AGGREGATION_ROUTER;

  /// @notice The token being from a user to be swapped
  address public immutable TOKEN;

  /// @notice Where the tokens are going in the router and it should match the executor
  address public immutable SOURCE_RECEIVER;

  constructor(
    IV5AggregationExecutor aggregationExecutor,
    IV5AggregationRouter aggregationRouter,
    address token,
    address sourceReceiver
  ) {
    AGGREGATION_EXECUTOR = aggregationExecutor;
    AGGREGATION_ROUTER = aggregationRouter;
    TOKEN = token;
    SOURCE_RECEIVER = sourceReceiver;
  }
}

/// @notice An abstract class with the necessary class variables to make a aggregation v4 optimized
/// router
abstract contract AggregationV4BaseRouter {
  /// @notice The contract used to execute the swap along an optimized path
  IV4AggregationExecutor public immutable AGGREGATION_EXECUTOR;

  /// @notice The 1inch contract with the unoptimized route
  IV4AggregationRouter public immutable AGGREGATION_ROUTER;

  /// @notice The token being from a user to be swapped
  address public immutable TOKEN;

  /// @notice Where the tokens are going in the router and it should match the executor
  address public immutable SOURCE_RECEIVER;

  constructor(
    IV4AggregationExecutor aggregationExecutor,
    IV4AggregationRouter aggregationRouter,
    address token,
    address sourceReceiver
  ) {
    AGGREGATION_EXECUTOR = aggregationExecutor;
    AGGREGATION_ROUTER = aggregationRouter;
    TOKEN = token;
    SOURCE_RECEIVER = sourceReceiver;
  }
}
