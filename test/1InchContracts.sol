// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IAggregationExecutor} from "src/interfaces/IAggregationExecutionRouter.sol";
import {IAggregationRouter} from "src/interfaces/IAggregationRouter.sol";

contract OneInchContracts {
  IAggregationRouter aggregationRouter =
    IAggregationRouter(0x1111111254EEB25477B68fb85Ed929f73A960582);
  IAggregationExecutor aggreationExecutor =
    IAggregationExecutor(0xf0694ACc9E941B176E17B9Ef923e71E7B8b2477A);
  address public immutable USDC = 0x7F5c764cBc14f9669B88837ca1490cCa17c31607;
  address public immutable UNI = 0x6fd9d7AD17242c41f7131d257212c54A0e816691;
}
