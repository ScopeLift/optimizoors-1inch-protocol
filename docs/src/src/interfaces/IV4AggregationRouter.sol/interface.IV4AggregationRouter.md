# IV4AggregationRouter
[Git Source](https://github.com/ScopeLift/optimizoors-1inch-protocol/blob/e9de00f1fcf1fead01a01a7915e828574099428e/src/interfaces/IV4AggregationRouter.sol)


## Functions
### swap


```solidity
function swap(IV4AggregationExecutor executor, SwapDescription calldata desc, bytes calldata data)
  external
  payable
  returns (uint256 returnAmount, uint256 spentAmount, uint256 gasLeft);
```

## Structs
### SwapDescription

```solidity
struct SwapDescription {
  IERC20 srcToken;
  IERC20 dstToken;
  address payable srcReceiver;
  address payable dstReceiver;
  uint256 amount;
  uint256 minReturnAmount;
  uint256 flags;
  bytes permit;
}
```

