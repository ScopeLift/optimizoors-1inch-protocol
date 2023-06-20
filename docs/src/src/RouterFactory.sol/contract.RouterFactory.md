# RouterFactory
[Git Source](https://github.com/ScopeLift/optimizoors-1inch-protocol/blob/e9de00f1fcf1fead01a01a7915e828574099428e/src/RouterFactory.sol)

A factory for deploying an optimized router for a given asset and router type.


## State Variables
### V5_AGGREGATION_EXECUTOR
The 1inch v5 contract used to execute the swap along an optimized token swapping path.


```solidity
IV5AggregationExecutor public immutable V5_AGGREGATION_EXECUTOR;
```


### V5_AGGREGATION_ROUTER
The 1inch v5 aggregation router contract.


```solidity
IV5AggregationRouter public immutable V5_AGGREGATION_ROUTER;
```


### V4_AGGREGATION_EXECUTOR
The 1inch v4 aggregation router contract used to execute the swap along an optimized
token swapping path.


```solidity
IV4AggregationExecutor public immutable V4_AGGREGATION_EXECUTOR;
```


### V4_AGGREGATION_ROUTER
The 1inch v4 aggregation router contract.


```solidity
IV4AggregationRouter public immutable V4_AGGREGATION_ROUTER;
```


## Functions
### constructor


```solidity
constructor(
  IV5AggregationExecutor v5AggregationExecutor,
  IV5AggregationRouter v5AggregationRouter,
  IV4AggregationExecutor v4AggregationExecutor,
  IV4AggregationRouter v4AggregationRouter
);
```

### deploy


```solidity
function deploy(RouterType type_, address asset) external returns (address);
```

### computeAddress


```solidity
function computeAddress(RouterType type_, address asset) external view returns (address);
```

### _computeV4AggregationRouterAddress


```solidity
function _computeV4AggregationRouterAddress(address asset) internal view returns (address);
```

### _computeV5AggregationRouterAddress


```solidity
function _computeV5AggregationRouterAddress(address asset) internal view returns (address);
```

### _salt


```solidity
function _salt(address asset) internal pure returns (bytes32);
```

## Events
### RouterDeployed

```solidity
event RouterDeployed(RouterType type_, address indexed asset);
```

## Errors
### RouterTypeDoesNotExist

```solidity
error RouterTypeDoesNotExist();
```

## Enums
### RouterType

```solidity
enum RouterType {
  V4AggregationRouter,
  V5AggregationRouter
}
```

