// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IAggregationExecutor} from "src/interfaces/IAggregationExecutionRouter.sol";
import {IAggregationRouter} from "src/interfaces/IAggregationRouter.sol";
import {Create2} from "src/lib/Create2.sol";
import {V5Router} from "src/V5Router.sol";

contract OneInchRouterFactory {
    IAggregationExecutor public immutable AGGREGATION_EXECUTOR;
    IAggregationRouter public immutable V5_AGGREGATION_ROUTER;
    address public immutable SOURCE_RECEIVER;

    event RouterDeployed(address indexed asset);

    constructor(
        IAggregationExecutor aggregationExecutor,
        IAggregationRouter v5AggregationRouter
    ) {
        AGGREGATION_EXECUTOR = aggregationExecutor;
        V5_AGGREGATION_ROUTER = v5AggregationRouter;
        SOURCE_RECEIVER = address(aggregationExecutor);
    }

    function deploy(address asset) external returns (address) {
        bytes32 salt = _salt(asset);
        address router = address(
            new V5Router{salt: salt}(
                V5_AGGREGATION_ROUTER,
                AGGREGATION_EXECUTOR,
                asset,
                SOURCE_RECEIVER
            )
        );
        emit RouterDeployed(router);
        return router;
    }

    function computeAddress(address asset) external view returns (address) {
        return
            Create2.computeCreate2Address(
                _salt(asset),
                address(this),
                type(V5Router).creationCode,
                abi.encode(
                    V5_AGGREGATION_ROUTER,
                    AGGREGATION_EXECUTOR,
                    asset,
                    SOURCE_RECEIVER
                )
            );
    }

    function _salt(address asset) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(asset)));
    }
}
