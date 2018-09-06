pragma solidity ^0.4.24;
import "../ERC223Token.sol";

/// @title Custom implementation of ERC223 
/// @author Aler Denisov <aler.zampillo@gmail.com>
contract ERC223Mock is ERC223Token {
  constructor() public {
    balances[msg.sender] = 1000000 ether;
  }
}