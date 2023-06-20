# V5Router
[Git Source](https://github.com/ScopeLift/optimizoors-1inch-protocol/blob/e9de00f1fcf1fead01a01a7915e828574099428e/src/V5Router.sol)

**Inherits:**
[AggregationV5BaseRouter](/src/AggregationBaseRouter.sol/abstract.AggregationV5BaseRouter.md)

A router to swap tokens using 1inch's v5 aggregation router.


## Functions
### constructor


```solidity
constructor(
  IV5AggregationRouter aggregationRouter,
  IV5AggregationExecutor aggregationExecutor,
  address token
) AggregationV5BaseRouter(aggregationExecutor, aggregationRouter, token);
```

### receive

*If we remove this function solc will give a missing-receive-ether warning because we have
a payable fallback function. We cannot change the fallback function to a receive function
because receive does not have access to msg.data. In order to prevent a missing-receive-ether
warning we add a receive function and revert.*


```solidity
receive() external payable;
```

### fallback


```solidity
fallback() external payable;
```

## Errors
### UnsupportedFunction
*Thrown when a function is not supported.*


```solidity
error UnsupportedFunction();
```

