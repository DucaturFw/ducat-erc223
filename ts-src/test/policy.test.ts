/// <reference path="../global.d.ts" />
import { sig, sideEvents } from "./utils";
import "mocha";
import { assert } from "chai";
import { AsyncResource } from "async_hooks";

const DATA = Buffer.from("test");
const {
  assertRevert
} = require("openzeppelin-solidity/test/helpers/assertRevert");

const DucatToken = artifacts.require("./DucatToken.sol");

contract("Token trasfer policy", ([owner, another, strange]) => {
  let token: any;
  beforeEach(async () => {
    token = await DucatToken.new();
    await token.mint(owner, 1e6);
  });

  it("allow transfer by default", async () => {
    await token.transfer(another, 10, sig(owner));
    await token.transfer(another, 10, DATA, sig(owner));
    await token.transfer(owner, 10, sig(another));
    await token.transfer(owner, 10, DATA, sig(another));
    await token.approve(another, 100, sig(owner));
    await token.transferFrom(owner, another, 10, sig(another));
    await token.transferFrom(owner, another, 10, DATA, sig(another));
  });

  it("reject blacklisting from non-owners", async () => {
    assert.isFalse(await token.isBlacklisted(another));
    await assertRevert(token.addBlackList(another, sig(strange)));
    assert.isFalse(await token.isBlacklisted(another));
  });

  it("allow blacklisting from owners", async () => {
    assert.isFalse(await token.isBlacklisted(another));
    await token.addBlackList(another, sig(owner));
    assert.isTrue(await token.isBlacklisted(another));
  });

  it("reject transfers from blacklisted addresses", async () => {
    await token.transfer(another, 1000, sig(owner));
    await token.addBlackList(another, sig(owner));
    await assertRevert(token.transfer(owner, 10, sig(another)));
    await assertRevert(token.transfer(owner, 10, DATA, sig(another)));
    await token.approve(owner, 10000, sig(another));
    await assertRevert(token.transferFrom(owner, another, 10, sig(another)));
    await assertRevert(
      token.transferFrom(owner, another, 10, DATA, sig(another))
    );
  });

  it("reject transfers to blacklisted addresses", async () => {
    await token.addBlackList(another, sig(owner));
    await assertRevert(token.transfer(another, 10000, sig(owner)));
  });

  it("should destroy black funds", async () => {
    await token.transfer(another, 1000, sig(owner));
    await token.addBlackList(another, sig(owner));
    const beforeDestroy = await token.totalSupply();
    await token.destroyBlackFunds(another, sig(owner));
    const afterDestroy = await token.totalSupply();
    assert.isTrue(beforeDestroy.gt(afterDestroy), "total supply same or grows");
    assert.isTrue(
      beforeDestroy.sub(1000).eq(afterDestroy),
      `${beforeDestroy.toString(10)} - 1000 != ${afterDestroy.toString(10)}`
    );
    assert.equal(
      await token.balanceOf(another),
      0,
      `balance is ${(await token.balanceOf(another)).toString(10)}`
    );
  });
});
