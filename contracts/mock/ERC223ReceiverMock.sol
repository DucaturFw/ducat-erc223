pragma solidity ^0.4.24;


contract ERC223ReceiverMock {
  event Fallback(address indexed _from, uint256 _value, bytes _data);

  function tokenFallback(address _from, uint256 _value, bytes _data) public {
    emit Fallback(_from, _value, _data);
  }
}