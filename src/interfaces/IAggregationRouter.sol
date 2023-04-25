pragma solidity >=0.8.0;

import {IAggregationExecutor} from "src/interfaces/IAggregationExecutionRouter.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface IAggregationRouter {
  struct SwapDescription {
    IERC20 srcToken;
    IERC20 dstToken;
    address payable srcReceiver;
    address payable dstReceiver;
    uint256 amount;
    uint256 minReturnAmount;
    uint256 flags;
  }

  /// @notice propagates information about original msg.sender and executes arbitrary data
  function swap(
    IAggregationExecutor executor,
    SwapDescription calldata desc,
    bytes calldata permit,
    bytes calldata data
  ) external payable returns (uint256 returnAmount, uint256 spentAmount); // 0x4b64e492
}
