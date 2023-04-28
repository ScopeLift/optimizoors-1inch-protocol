// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IV5AggregationExecutor} from "src/interfaces/IV5AggregationExecutor.sol";
import {IV5AggregationRouter} from "src/interfaces/IV5AggregationRouter.sol";

contract OneInchContracts {
    IV5AggregationRouter aggregationRouter =
        IV5AggregationRouter(0x1111111254EEB25477B68fb85Ed929f73A960582);
    IV5AggregationExecutor aggregationExecutor =
        IV5AggregationExecutor(0xf0694ACc9E941B176E17B9Ef923e71E7B8b2477A);
    address public immutable USDC = 0x7F5c764cBc14f9669B88837ca1490cCa17c31607;
    address public immutable UNI = 0x6fd9d7AD17242c41f7131d257212c54A0e816691;
}
