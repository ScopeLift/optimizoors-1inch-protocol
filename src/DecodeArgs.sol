// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecodeArgs {
  /// @dev Returns the `minReturnAmount` from a `uint96`.
  /// @param args A `uint192` that contains both the `minReturnAmount` and `amount` needed to swap a
  /// token.
  function _extractMinReturnAmount(uint192 args) internal pure returns (uint96) {
    uint168 mask = (1 << 96) - 1;
    return uint96(args & mask);
  }

  /// @dev Returns the `amount` from a `uint96`.
  /// @param args A `uint192` that contains both the `minReturnAmount` and `amount` needed to swap a
  /// token.
  function _extractAmount(uint192 args) internal pure returns (uint96) {
    uint192 firstNinetySixBitMask = ((1 << 96) - 1) << 96;
    return uint96((args & firstNinetySixBitMask) >> 96);
  }
}
