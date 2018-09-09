/// <reference path="../global.d.ts" />

import { sig, sideEvents } from "./utils";
const {
  assertRevert
} = require("openzeppelin-solidity/test/helpers/assertRevert");

const ERC223Mock = artifacts.require("ERC223Mock.sol");
const ERC223ReceiverMock = artifacts.require("ERC223ReceiverMock.sol");
const NonERC223ReceiverMock = artifacts.require("NonERC223ReceiverMock.sol");

import "mocha";
import { assert } from "chai";

contract("ERC223", function([owner, another]) {
  let token: any;
  before(async () => {
    token = await ERC223Mock.new();
  });

  it("fallback test", async () => {
    const mockFallback = await ERC223ReceiverMock.new();
    const tx = await token.transfer(mockFallback.address, 1000);
    assert.isBelow(
      0,
      tx.logs.filter(
        (log: any) => log.event === "Transfer" && log.args.from === owner
      ).length
    );
  });

  it("fallback test with approval", async () => {
    const mockFallback = await ERC223ReceiverMock.new();
    await token.approve(another, 1000);
    const tx = await token.transferFrom(
      owner,
      mockFallback.address,
      1000,
      sig(another)
    );
    assert.isBelow(
      0,
      tx.logs.filter(
        (log: any) => log.event === "Transfer" && log.args.from === owner
      ).length
    );
  });

  it("fall in transfer to non erc223 receiver", async () => {
    const mockFallback = await NonERC223ReceiverMock.new();
    const bar = await mockFallback.bar();
    assert.equal(bar.div(1e18), 10);

    await assertRevert(token.transfer(mockFallback.address, 1000));
  });

  it("side effects", async () => {
    const mockFallback = await ERC223ReceiverMock.new();
    const tx = await token.transfer(mockFallback.address, 1000);

    const logs = sideEvents([ERC223ReceiverMock.abi], tx) as any[];

    assert.isTrue(logs.some(log => log.event === "Fallback"));
    assert.equal(logs.find(log => log.event === "Fallback")!.args._value, 1000);
  });
});
