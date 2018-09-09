pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";

interface IERC223Receiver {
  function tokenFallback(address _from, uint256 _value, bytes _data) external;
}

/// @title Smart token implementation compatible with ERC20, ERC223, Mintable, Burnable and Pausable tokens
/// @author Aler Denisov <aler.zampillo@gmail.com>
contract SmartToken is BurnableToken, MintableToken, PausableToken {
  event Transfer(address indexed from, address indexed to, uint256 value, bytes data);

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  ) public returns (bool) 
  {
    bytes memory empty;
    return transferFrom(
      _from, 
      _to, 
      _value, 
      empty); // solium-disable-line indentation
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value,
    bytes _data
  ) public returns (bool)
  {
    require(_value <= allowed[_from][msg.sender]);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    if (isContract(_to)) {
      return transferToContract(
        _from, 
        _to, 
        _value, 
        _data);  // solium-disable-line indentation
    } else {
      return transferToAddress(
        _from, 
        _to, 
        _value, 
        _data); // solium-disable-line indentation
    }
  }

  function transfer(address _to, uint256 _value, bytes _data) public returns (bool success) {
    if (isContract(_to)) {
      return transferToContract(
        msg.sender,
        _to,
        _value,
        _data); // solium-disable-line indentation
    } else {
      return transferToAddress(
        msg.sender,
        _to,
        _value,
        _data); // solium-disable-line indentation
    }
  }

  function transfer(address _to, uint256 _value) public returns (bool success) {
    bytes memory empty;
    return transfer(_to, _value, empty);
  }

  function isContract(address _addr) internal view returns (bool) {
    uint256 length;
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      //retrieve the size of the code on target address, this needs assembly
      length := extcodesize(_addr)
    }  // solium-disable-line indentation
    return (length>0);
  }

  function moveTokens(address _from, address _to, uint256 _value) internal returns (bool success) {
    if (balanceOf(_from) < _value) {
      revert();
    }
    balances[_from] = balanceOf(_from).sub(_value);
    balances[_to] = balanceOf(_to).add(_value);

    return true;
  }

  function transferToAddress(
    address _from,
    address _to,
    uint256 _value,
    bytes _data
  ) internal returns (bool success) 
  {
    require(moveTokens(_from, _to, _value));
    emit Transfer(_from, _to, _value);
    emit Transfer(_from, _to, _value, _data); // solium-disable-line arg-overflow
    return true;
  }
  
  //function that is called when transaction target is a contract
  function transferToContract(
    address _from,
    address _to,
    uint256 _value,
    bytes _data
  ) internal returns (bool success) 
  {
    require(moveTokens(_from, _to, _value));
    IERC223Receiver(_to).tokenFallback(_from, _value, _data);
    emit Transfer(_from, _to, _value);
    emit Transfer(_from, _to, _value, _data); // solium-disable-line arg-overflow
    return true;
  }
}