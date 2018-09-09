pragma solidity ^0.4.24;
import "./SmartToken.sol";


contract SmartMultichainToken is SmartToken {
  event BlockchainExchange(
    address indexed from, 
    uint256 value, 
    uint256 indexed newNetwork, 
    bytes32 adr
  );

  constructor(uint256 _cap) public SmartToken(_cap) {}
  /// @dev Function to burn tokens and rise event for burn tokens in another network
  /// @param _amount The amount of tokens that will burn
  /// @param _network The index of target network.
  /// @param _adr The address in new network
  function blockchainExchange(
    uint256 _amount, 
    uint256 _network, 
    bytes32 _adr
  ) public {
    burn(_amount);
    cap.sub(_amount);
    emit BlockchainExchange(msg.sender, _amount, _network, _adr);
  }

  /// @dev Function to burn allowed tokens from special address and rise event for burn tokens in another network
  /// @param _from The address of holder
  /// @param _amount The amount of tokens that will burn
  /// @param _network The index of target network.
  /// @param _adr The address in new network
  function blockchainExchangeFrom(
    address _from,
    uint256 _amount, 
    uint256 _network, 
    bytes32 _adr
  ) public {
    require(_amount <= allowed[_from][msg.sender]);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
    _burn(_from, _amount);
    emit BlockchainExchange(msg.sender, _amount, _network, _adr);
  }
}