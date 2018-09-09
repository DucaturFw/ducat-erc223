/// <reference path="../global.d.ts" />
import { sig, sideEvents } from "./utils";
import "mocha";
import { assert } from "chai";
const {
  assertRevert
} = require("openzeppelin-solidity/test/helpers/assertRevert");
const {
  inTransaction
} = require("openzeppelin-solidity/test/helpers/expectEvent");

const DucatToken = artifacts.require("./DucatToken.sol");

contract("Ducat", () => {
  let token: any;
  beforeEach(async () => {
    token = await DucatToken.new();
  });

  it("should have proper details", async () => {
    assert.equal(await token.decimals(), 4);
    assert.equal(await token.name(), "Ducat");
    assert.equal(await token.symbol(), "DUCAT");
  });

  it("should have proper cap", async () => {
    const decimals = await token.decimals();
    const cap = 7e9; // 7 billions

    assert.equal(
      (await token.cap()).toString(10),
      decimals
        .sub(decimals) // hack to make right BigNumber without extra dependency
        .add(10)
        .pow(decimals)
        .mul(cap)
        .toString(10)
    );
  });
});
