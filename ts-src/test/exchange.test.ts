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

const ADDRESS = web3.sha3("hey ho");

contract("Multichain Token", async ([owner, another]) => {
  let token: any;
  beforeEach(async () => {
    token = await DucatToken.new();
    await token.mint(owner, 1e6, sig(owner));
    await token.transfer(another, 100, sig(owner));
  });

  describe("blockchainExchange", () => {
    it("should emit event BlockchainExchange", async () => {
      const tx = await token.blockchainExchange(1, 1, ADDRESS, sig(another));

      inTransaction(tx, "BlockchainExchange", {
        from: another,
        value: 1,
        newNetwork: 1,
        adr: ADDRESS
      });
    });

    it("should burn tokens", async () => {
      const beforeDestroy = await token.totalSupply();
      const tx = await token.blockchainExchange(1, 1, ADDRESS, sig(another));
      const afterDestroy = await token.totalSupply();

      assert.isTrue(
        beforeDestroy.gt(afterDestroy),
        "total supply same or grows"
      );
      assert.isTrue(
        beforeDestroy.sub(1).eq(afterDestroy),
        `${beforeDestroy.toString(10)} - 1 != ${afterDestroy.toString(10)}`
      );
    });

    it("should decrease balance", async () => {
      const beforeDestroy = await token.balanceOf(another);
      const tx = await token.blockchainExchange(100, 1, ADDRESS, sig(another));
      const afterDestroy = await token.balanceOf(another);

      assert.isTrue(
        beforeDestroy.gt(afterDestroy),
        "total supply same or grows"
      );
      assert.isTrue(
        beforeDestroy.sub(100).eq(afterDestroy),
        `${beforeDestroy.toString(10)} - 100 != ${afterDestroy.toString(10)}`
      );
    });
  });
});
