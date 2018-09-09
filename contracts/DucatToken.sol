pragma solidity ^0.4.24;
import "./SmartMultichainToken.sol";
import "./Blacklist.sol";
import "./TransferTokenPolicy.sol";
import "openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";


contract DucatToken is TransferTokenPolicy, SmartMultichainToken, Blacklist, DetailedERC20 {
  constructor() public
    DetailedERC20(
      "Ducat",
      "DUCAT",
      uint8(18)
    )
    SmartMultichainToken(
      7 ether * 10 ** 9 // 7 billion
    )
   {
   }

  function _allowTransfer(address _from, address _to, uint256) internal returns(bool) {
    return !isBlacklisted(_from) && !isBlacklisted(_to);
  }
}