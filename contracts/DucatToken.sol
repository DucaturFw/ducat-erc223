pragma solidity ^0.4.24;
import "./SmartMultichainToken.sol";
import "./Blacklist.sol";
import "./TransferTokenPolicy.sol";
import "openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";


contract DucatToken is TransferTokenPolicy, SmartMultichainToken, Blacklist, DetailedERC20 {
  uint256 private precision = 4; 
  constructor() public
    DetailedERC20(
      "Ducat",
      "DUCAT",
      uint8(precision)
    )
    SmartMultichainToken(
      7 * 10 ** (9 + precision) // 7 billion with decimals
    )
   {
   }

  function _allowTransfer(address _from, address _to, uint256) internal returns(bool) {
    return !isBlacklisted(_from) && !isBlacklisted(_to);
  }
}