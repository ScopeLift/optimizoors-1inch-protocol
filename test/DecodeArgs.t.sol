// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";

import {DecodeArgs} from "src/DecodeArgs.sol";
import {OneInchContracts} from "test/OneInchContracts.sol";

contract DecodeArgsTest is Test, OneInchContracts {}

contract DecodeArgsTestHarness is DecodeArgs {
  function extractAmount(uint192 args) external pure returns (uint96) {
    return _extractAmount(args);
  }

  function extractMinReturnAmount(uint192 args) external pure returns (uint96) {
    return _extractMinReturnAmount(args);
  }
}

contract _ExtractMinReturnAmount is DecodeArgsTest {
  function testFuzz_SuccessfullyExtractMinReturnAmount(uint96 amount, uint96 minReturnAmount)
    public
  {
    DecodeArgsTestHarness harness = new DecodeArgsTestHarness();
    assertEq(harness.extractMinReturnAmount(encodeArgs(amount, minReturnAmount)), minReturnAmount);
  }
}

contract _ExtractAmount is DecodeArgsTest {
  function testFuzz_SuccessfullyExtractAmount(uint96 amount, uint96 minReturnAmount) public {
    DecodeArgsTestHarness harness = new DecodeArgsTestHarness();
    assertEq(harness.extractAmount(encodeArgs(amount, minReturnAmount)), amount);
  }

  function testFuzz_SuccessfullyReencodeArgs(uint192 args) public {
    DecodeArgsTestHarness harness = new DecodeArgsTestHarness();
    assertEq(encodeArgs(harness.extractAmount(args), harness.extractMinReturnAmount(args)), args);
  }
}
