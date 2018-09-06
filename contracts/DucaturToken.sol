pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/token/BasicToken.sol';
import 'openzeppelin-solidity/contracts/token/Ownable.sol';
import 'openzeppelin-solidity/contracts/token/MintableToken.sol';
import 'openzeppelin-solidity/contracts/token/BurnableToken.sol';
import 'openzeppelin-solidity/contracts/token/PausableToken.sol';

contract BlackList is Ownable, BasicToken {
    function getBlackListStatus(address _maker) external constant returns (bool) {
        return isBlackListed[_maker];
    }

    mapping (address => bool) public isBlackListed;
    
    function addBlackList (address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
        AddedBlackList(_evilUser);
    }

    function removeBlackList (address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
        RemovedBlackList(_clearedUser);
    }

    function destroyBlackFunds (address _blackListedUser) public onlyOwner {
        require(isBlackListed[_blackListedUser]);
        uint dirtyFunds = balanceOf(_blackListedUser);
        balances[_blackListedUser] = 0;
        _totalSupply = _totalSupply.sub(dirtyFunds);
        DestroyedBlackFunds(_blackListedUser, dirtyFunds);
    }

    event DestroyedBlackFunds(address _blackListedUser, uint _balance);

    event AddedBlackList(address _user);

    event RemovedBlackList(address _user);

}

/**
 * @title Ducatur ERC223 compatible token
 * @dev Mintable Burnable Pausable token with a token cap, crosschain exchange and ERC223 functions support.
 */
contract Ducatur223Token is MintableToken, BurnableToken, PausableToken, BlackList {

  string public constant name = "Ducatur Token";
  string public constant symbol = "DUCAT";
  uint8 public constant decimals = 18;
  uint256 public cap;
  address public oracle;
  event BlockchainExchange(
    address indexed from, 
    uint256 value, 
    int newNetwork, 
    bytes32 adr
  );

  constructor(uint256 _cap, address _oracle) public {
    require(_cap > 0);
    cap = _cap.mul(10 ** uint256(decimals));
    oracle = _oracle;
  }

  /**
   * @dev Throws if called by any account other than the oracle.
   */
  modifier onlyOracle() {
    require(msg.sender == oracle);
    _;
  }
  
  /**
   * @dev Function to change oracle
   * @param _oracle The address of new oracle.
   */  
  function changeOracle(address _oracle) external onlyOwner {
      oracle = _oracle;
  }
  
  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    onlyOracle
    whenNotPaused
    canMint
    public
    returns (bool)
  {
    _amount = _amount*10**uint256(decimals);
    require(totalSupply_.add(_amount) <= cap);
    return super.mint(_to, _amount);
  }
  
  /**
  * @dev Function to burn tokens and rise event for burn tokens in another network
  * @param _amount The address that will receive the minted tokens.
  * @param _network The amount of tokens to mint.
  * @param _adr The address in new network
  */
  function blockchainExchange(
    uint256 _amount, 
    int _network, 
    bytes32 _adr
  ) public {
    burn(_amount);
    cap.sub(_amount);
    emit BlockchainExchange(msg.sender, _amount, _network, _adr);
  }

  // Add ERC223 methods
  event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
  // Function that is called when a user or another contract wants to transfer funds .
  function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
    require(!isBlackListed[msg.sender]);
    if(isContract(_to)) {
        if (balanceOf(msg.sender) < _value) revert();
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    else {
        return transferToAddress(_to, _value, _data);
    }
  
  }

  // Function that is called when a user or another contract wants to transfer funds .
  function transfer(address _to, uint _value, bytes _data) public returns (bool success) {
    require(!isBlackListed[msg.sender]);
    if(isContract(_to)) {
        return transferToContract(_to, _value, _data);
    }
    else {
        return transferToAddress(_to, _value, _data);
    }
}
  
  // Standard function transfer similar to ERC20 transfer with no _data .
  // Added due to backwards compatibility reasons .
  function transfer(address _to, uint _value) public returns (bool success) {
    require(!isBlackListed[msg.sender]);
    //standard function transfer similar to ERC20 transfer with no _data
    //added due to backwards compatibility reasons
    bytes memory empty;
    if(isContract(_to)) {
        return transferToContract(_to, _value, empty);
    }
    else {
        return transferToAddress(_to, _value, empty);
    }
  }

  function transferFrom(address _from, address _to, uint _value) public whenNotPaused  {
    require(!isBlackListed[msg.sender]);
    return super.transferFrom(_from, _to, _value);
  }

  //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
  function isContract(address _addr) private view returns (bool is_contract) {
    uint length;
    assembly {
      //retrieve the size of the code on target address, this needs assembly
      length := extcodesize(_addr)
    }
    return (length>0);
  }

  //function that is called when transaction target is an address
  function transferToAddress(address _to, uint _value, bytes _data) whenNotPaused private returns (bool success) {
    if (balanceOf(msg.sender) < _value) revert();
    balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
    balances[_to] = safeAdd(balanceOf(_to), _value);
    emit Transfer(msg.sender, _to, _value, _data);
    return true;
  }
  
  //function that is called when transaction target is a contract
  function transferToContract(address _to, uint _value, bytes _data) whenNotPaused private returns (bool success) {
    if (balanceOf(msg.sender) < _value) revert();
    balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
    balances[_to] = safeAdd(balanceOf(_to), _value);
    ContractReceiver receiver = ContractReceiver(_to);
    receiver.tokenFallback(msg.sender, _value, _data);
    emit Transfer(msg.sender, _to, _value, _data);
    return true;
  }
}