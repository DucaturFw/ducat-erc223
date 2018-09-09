pragma solidity ^0.4.24;
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";


contract Blacklist is BurnableToken, Ownable {
  mapping (address => bool) public blacklist;

  event DestroyedBlackFunds(address _blackListedUser, uint _balance);
  event AddedBlackList(address _user);
  event RemovedBlackList(address _user);

  function isBlacklisted(address _maker) public view returns (bool) {
    return blacklist[_maker];
  }

  function addBlackList(address _evilUser) public onlyOwner {
    blacklist[_evilUser] = true;
    emit AddedBlackList(_evilUser);
  }

  function removeBlackList(address _clearedUser) public onlyOwner {
    blacklist[_clearedUser] = false;
    emit RemovedBlackList(_clearedUser);
  }

  function destroyBlackFunds(address _blackListedUser) public onlyOwner {
    require(blacklist[_blackListedUser], "User isn't blacklisted");
    uint dirtyFunds = balanceOf(_blackListedUser);
    _burn(_blackListedUser, dirtyFunds);
    emit DestroyedBlackFunds(_blackListedUser, dirtyFunds);
  }
}