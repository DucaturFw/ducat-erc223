pragma solidity ^0.4.24;
import "./SmartToken.sol";


contract TransferTokenPolicy is SmartToken {
  function _allowTransfer(address, address, uint256) internal returns(bool) {
    return true;
  }

  modifier isTransferAllowed(address _from, address _to, uint256 _value) {
    require(_allowTransfer(_from, _to, _value));
    _;
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  ) public isTransferAllowed(_from, _to, _value) returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value,
    bytes _data
  ) public isTransferAllowed(_from, _to, _value) returns (bool)
  {
    return super.transferFrom(_from, _to, _value, _data);
  }

  function transfer(address _to, uint256 _value, bytes _data) public isTransferAllowed(msg.sender, _to, _value) returns (bool success) {
    return super.transfer(_to, _value, _data);
  }

  function transfer(address _to, uint256 _value) public isTransferAllowed(msg.sender, _to, _value) returns (bool success) {
    return super.transfer(_to, _value);
  }

  function burn(uint256 _amount) public isTransferAllowed(msg.sender, address(0x0), _amount) {
    super.burn(_amount);
  }
}