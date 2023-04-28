import {IV5AggregationExecutor} from "src/interfaces/IV5AggregationExecutor.sol";
import {IV5AggregationRouter} from "src/interfaces/IV5AggregationRouter.sol";
import {IV4AggregationExecutor} from "src/interfaces/IV4AggregationExecutor.sol";
import {IV4AggregationRouter} from "src/interfaces/IV4AggregationRouter.sol";

abstract contract AggregationV5BaseRouter {
    IV5AggregationExecutor public immutable AGGREGATION_EXECUTOR;
    IV5AggregationRouter public immutable AGGREGATION_ROUTER;

    address public immutable TOKEN;
    address public immutable SOURCE_RECEIVER;

    constructor(
        IV5AggregationExecutor aggregationExecutor,
        IV5AggregationRouter aggregationRouter,
        address token,
        address sourceReceiver
    ) {
        AGGREGATION_EXECUTOR = aggregationExecutor;
        AGGREGATION_ROUTER = aggregationRouter;
        TOKEN = token;
        SOURCE_RECEIVER = sourceReceiver;
    }
}

abstract contract AggregationV4BaseRouter {
    IV4AggregationExecutor public immutable AGGREGATION_EXECUTOR;
    IV4AggregationRouter public immutable AGGREGATION_ROUTER;

    address public immutable TOKEN;
    address public immutable SOURCE_RECEIVER;

    constructor(
        IV4AggregationExecutor aggregationExecutor,
        IV4AggregationRouter aggregationRouter,
        address token,
        address sourceReceiver
    ) {
        AGGREGATION_EXECUTOR = aggregationExecutor;
        AGGREGATION_ROUTER = aggregationRouter;
        TOKEN = token;
        SOURCE_RECEIVER = sourceReceiver;
    }
}
