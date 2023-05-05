// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IV5AggregationExecutor} from "src/interfaces/IV5AggregationExecutor.sol";
import {IV5AggregationRouter} from "src/interfaces/IV5AggregationRouter.sol";
import {IV4AggregationExecutor} from "src/interfaces/IV4AggregationExecutor.sol";
import {IV4AggregationRouter} from "src/interfaces/IV4AggregationRouter.sol";
import {Create2} from "src/lib/Create2.sol";
import {V5Router} from "src/V5Router.sol";
import {V4Router} from "src/V4Router.sol";

/// @notice A factory for deploying an optimized router for a given asset and router type.
contract OneInchRouterFactory {
  error RouterTypeDoesNotExist();

  enum RouterTypes {
    V4AggregationRouter,
    V5AggregationRouter
  }

  /// @notice The 1inch v5 contract used to execute the swap along an optimized token swapping path.
  IV5AggregationExecutor public immutable V5_AGGREGATION_EXECUTOR;

  /// @notice The 1inch v5 aggregation router contract.
  IV5AggregationRouter public immutable V5_AGGREGATION_ROUTER;

  /// @notice The 1inch v4 aggregation router contract used to execute the swap along an optimized
  /// token swapping path.
  IV4AggregationExecutor public immutable V4_AGGREGATION_EXECUTOR;

  /// @notice The 1inch v4 aggregation router contract.
  IV4AggregationRouter public immutable V4_AGGREGATION_ROUTER;

  /// @notice The address the 1inch v5 aggregation router will send the the input tokens.
  /// This will match the V5_AGGREGATION_EXECUTOR address.
  address public immutable V5_SOURCE_RECEIVER;

  /// @notice The address the 1inch v4 aggregation router will send the the input tokens.
  /// This will match the V4_AGGREGATION_EXECUTOR address.
  address public immutable V4_SOURCE_RECEIVER;

  event RouterDeployed(RouterTypes type_, address indexed asset);

  constructor(
    IV5AggregationExecutor v5AggregationExecutor,
    IV5AggregationRouter v5AggregationRouter,
    IV4AggregationExecutor v4AggregationExecutor,
    IV4AggregationRouter v4AggregationRouter
  ) {
    V5_AGGREGATION_EXECUTOR = v5AggregationExecutor;
    V5_AGGREGATION_ROUTER = v5AggregationRouter;
    V5_SOURCE_RECEIVER = address(v5AggregationExecutor);
    V4_AGGREGATION_EXECUTOR = v4AggregationExecutor;
    V4_AGGREGATION_ROUTER = v4AggregationRouter;
    V4_SOURCE_RECEIVER = address(v4AggregationExecutor);
  }

  function deploy(RouterTypes type_, address asset) external returns (address) {
    bytes32 salt = _salt(asset);
    address router;
    if (type_ == RouterTypes.V5AggregationRouter) {
      router = address(
        new V5Router{salt: salt}(
                    V5_AGGREGATION_ROUTER,
                    V5_AGGREGATION_EXECUTOR,
                    asset,
                    V5_SOURCE_RECEIVER
                )
      );
    } else if (type_ == RouterTypes.V4AggregationRouter) {
      router = address(
        new V4Router{salt: salt}(
                    V4_AGGREGATION_ROUTER,
                    V4_AGGREGATION_EXECUTOR,
                    asset,
                    V4_SOURCE_RECEIVER
                )
      );
    } else {
      revert RouterTypeDoesNotExist();
    }
    emit RouterDeployed(type_, asset);
    return router;
  }

  function computeAddress(RouterTypes type_, address asset) external view returns (address) {
    if (type_ == RouterTypes.V4AggregationRouter) {
      return _computeV4AggregationRouterAddress(asset);
    } else if (type_ == RouterTypes.V5AggregationRouter) {
      return _computeV5AggregationRouterAddress(asset);
    } else {
      revert RouterTypeDoesNotExist();
    }
  }

  function _computeV4AggregationRouterAddress(address asset) internal view returns (address) {
    return Create2.computeCreate2Address(
      _salt(asset),
      address(this),
      type(V4Router).creationCode,
      abi.encode(V4_AGGREGATION_ROUTER, V4_AGGREGATION_EXECUTOR, asset, V4_SOURCE_RECEIVER)
    );
  }

  function _computeV5AggregationRouterAddress(address asset) internal view returns (address) {
    return Create2.computeCreate2Address(
      _salt(asset),
      address(this),
      type(V5Router).creationCode,
      abi.encode(V5_AGGREGATION_ROUTER, V5_AGGREGATION_EXECUTOR, asset, V5_SOURCE_RECEIVER)
    );
  }

  function _salt(address asset) internal pure returns (bytes32) {
    return bytes32(uint256(uint160(asset)));
  }
}
