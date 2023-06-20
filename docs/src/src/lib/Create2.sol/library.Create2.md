# Create2
[Git Source](https://github.com/ScopeLift/optimizoors-1inch-protocol/blob/e9de00f1fcf1fead01a01a7915e828574099428e/src/lib/Create2.sol)


## Functions
### computeCreate2Address


```solidity
function computeCreate2Address(
  bytes32 salt,
  address deployer,
  bytes memory initcode,
  bytes memory constructorArgs
) internal pure returns (address);
```

