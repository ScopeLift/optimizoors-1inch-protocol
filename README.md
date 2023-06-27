# 1inch Optimizoors

⚠️ **This code is not audited. Use at your own risk.**


- [About](#about)
- [Development](#development)
  - [Instructions](#instructions)
  - [Contracts](#contracts)
  - [Addresses](#addresses)
- [License](#license)

## About

1inch optimizoors provides calldata-optimized routers for [1inch Network](https://1inch.io/),
providing significant gas savings when deployed on Optimism or Arbitrum. There are 
two optimized routers. One that wraps 1inch's V4 aggregation router and another
that wraps their V5 aggregation router. This work was funded by an Ethereum Foundation [grant](https://blog.ethereum.org/2023/02/14/layer-2-grants-roundup). Read our [blog post](https://www.scopelift.co/blog/calldata-optimizooooors) to learn 
more about how we optimize gas usage for protocols on L2s.

## Development

### Instructions

To get started, clone this repo, then follow the below instructions:

```sh
# run these commands from the workspace root!
cp .env.example .env

# Run tests
forge test

# Build smart contracts
forge build
```

### Contracts

Documentation for the contracts can he found [here](docs/src/SUMMARY.md).

### Addresses

| Name   | Chain |    Address      |
|----------|:-------:|:-------------:|
| 1inch Router Factory | Optimism | 0xDfb453656A14c8e9ad3F4095483CE3328977eb47 |
| 1inch Router Factory | Aribitrum | 0x8a33e6288d155aDB1d368838CB91E01d30C66eC1|




## How it works

We have a router factory which deploys calldata optimized `AggregationRouter` contracts. 
Currently, we have two types of optimized routers. One for the V5 aggregation router and another 
for the v4 aggregation router.

There will be one deployed optimized router per sell token. For example if a user
is swapping USDC for WETH they will call the USDC optimized router.

## License

This project is available under the [MIT](LICENSE.txt) license.

Copyright (c) 2023 ScopeLift
