// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IV5AggregationExecutor} from "src/interfaces/IV5AggregationExecutor.sol";
import {IV5AggregationRouter} from "src/interfaces/IV5AggregationRouter.sol";
import {IV4AggregationExecutor} from "src/interfaces/IV4AggregationExecutor.sol";
import {IV4AggregationRouter} from "src/interfaces/IV4AggregationRouter.sol";

contract OneInchContracts {
  IV5AggregationRouter v5AggregationRouter =
    IV5AggregationRouter(0x1111111254EEB25477B68fb85Ed929f73A960582);
  IV5AggregationExecutor v5AggregationExecutor =
    IV5AggregationExecutor(0xf0694ACc9E941B176E17B9Ef923e71E7B8b2477A);
  IV4AggregationRouter v4AggregationRouter =
    IV4AggregationRouter(0x1111111254760F7ab3F16433eea9304126DCd199);
  IV4AggregationExecutor v4AggregationExecutor =
    IV4AggregationExecutor(0xf0694ACc9E941B176E17B9Ef923e71E7B8b2477A);

  address public immutable USDC = 0x7F5c764cBc14f9669B88837ca1490cCa17c31607;
  address public immutable UNI = 0x6fd9d7AD17242c41f7131d257212c54A0e816691;
  address public immutable DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;

  function returnSliceBytes(bytes calldata d) public pure returns (bytes memory) {
    return d[4:];
  }

  function encodeArgs(uint256 amount, uint256 minReturnAmount) internal pure returns (uint192) {
    return (uint192(uint96(amount)) << 96) | uint192(uint96(minReturnAmount));
  }
}
