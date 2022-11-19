pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import './YourToken.sol';

contract Vendor is Ownable {
  YourToken public yourToken;
  uint256 public constant tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable {
    uint256 amountOfEth = msg.value / tokensPerEth;
    yourToken.transfer(msg.sender, amountOfEth);
    emit BuyTokens(msg.sender, amountOfEth, msg.value);
  }
  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() payable public {
    return;
  }
  // ToDo: create a sellTokens() function:
}
