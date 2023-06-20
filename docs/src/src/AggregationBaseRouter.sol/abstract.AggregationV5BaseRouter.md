# AggregationV5BaseRouter
[Git Source](https://github.com/ScopeLift/optimizoors-1inch-protocol/blob/e9de00f1fcf1fead01a01a7915e828574099428e/src/AggregationBaseRouter.sol)

An abstract class with the necessary class variables
to make a 1inch v5 aggregation router optimized.


## State Variables
### AGGREGATION_EXECUTOR
The contract used to execute the swap along an optimized path.


```solidity
IV5AggregationExecutor public immutable AGGREGATION_EXECUTOR;
```


### AGGREGATION_ROUTER
The 1inch v5 aggregation router contract.


```solidity
IV5AggregationRouter public immutable AGGREGATION_ROUTER;
```


### TOKEN
The input token being swapped.


```solidity
address public immutable TOKEN;
```


### SOURCE_RECEIVER
Where the tokens are transferred in the 1inch v5 aggregation router.
It will match the AGGREGATION_EXECUTOR address.


```solidity
address public immutable SOURCE_RECEIVER;
```


## Functions
### constructor


```solidity
constructor(
  IV5AggregationExecutor aggregationExecutor,
  IV5AggregationRouter aggregationRouter,
  address token
);
```

