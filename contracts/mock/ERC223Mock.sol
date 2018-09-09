pragma solidity ^0.4.24;
import "../SmartToken.sol";

/// @title Custom implementation of ERC223 
/// @author Aler Denisov <aler.zampillo@gmail.com>
contract ERC223Mock is SmartToken {
  constructor() public SmartToken(1000000 ether) {
    balances[msg.sender] = 1000000 ether;
  }
}