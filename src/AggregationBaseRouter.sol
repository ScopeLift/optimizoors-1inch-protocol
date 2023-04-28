import {IAggregationExecutor} from "src/interfaces/IAggregationExecutionRouter.sol";

abstract contract AggregationBaseRouter {
  IAggregationExecutor public immutable AGGREGATION_EXECUTOR;

  address public immutable TOKEN;
  address public immutable SOURCE_RECEIVER;

  constructor(IAggregationExecutor aggreationExecutor, address token, address sourceReceiver) {
    AGGREGATION_EXECUTOR = aggreationExecutor;
    TOKEN = token;
    SOURCE_RECEIVER = sourceReceiver;
  }
}
