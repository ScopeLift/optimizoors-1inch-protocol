// executor can be removed
// srcToken: each contract is a src token
// dstToken: Can be represented by an integer??
// amount: strat
// minReturnAmount: strat
// flags?
// permit?
// data - don't think we can do anything, comes from their api.
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IAggregationExecutor} from "src/interfaces/IAggregationExecutionRouter.sol";
import {IAggregationRouter} from "src/interfaces/IAggregationRouter.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

abstract contract AggregationBaseRouter {
    IAggregationExecutor public immutable AGGREGATION_EXECUTOR;

    address public immutable TOKEN;
    address public immutable SOURCE_RECEIVER;

    constructor(
        IAggregationExecutor aggreationExecutor,
        address token,
        address sourceReceiver
    ) {
        AGGREGATION_EXECUTOR = aggreationExecutor;
        TOKEN = token;
        SOURCE_RECEIVER = sourceReceiver;
    }
}

contract V5Router is AggregationBaseRouter {
    IAggregationRouter public immutable AGGREGATION_ROUTER;

    constructor(
        IAggregationRouter aggregationRouter,
        IAggregationExecutor aggregationExecutor,
        address token,
        address sourceReceiver
    ) AggregationBaseRouter(aggregationExecutor, token, sourceReceiver) {
        AGGREGATION_ROUTER = aggregationRouter;
    }

    //
    // TODO: minReturnAmount is the minimum allowed output amount
    //
    // Can we have exact out? And maybe a percentage slipppage.
    //
    // the flags match specific constant masks. there is no documentation on these though
    fallback() external payable {
        // This is the fallback function
        (
            address dstToken,
            uint256 amount,
            uint256 minReturnAmount,
            bytes memory data,
            bool flags
        ) = abi.decode(msg.data, (address, uint256, uint256, bytes, bool));
        AGGREGATION_ROUTER.swap(
            AGGREGATION_EXECUTOR,
            IAggregationRouter.SwapDescription({
                srcToken: IERC20(TOKEN),
                dstToken: IERC20(dstToken),
                srcReceiver: payable(SOURCE_RECEIVER),
                dstReceiver: payable(msg.sender),
                amount: amount,
                minReturnAmount: minReturnAmount,
                flags: flags ? 1 : 0
            }),
            "",
            data
        );
    }
}
