pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT

import '@openzeppelin/contracts/access/Ownable.sol';
import './YourToken.sol';

contract Vendor is Ownable {
  YourToken public yourToken;
  uint256 public constant tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);
  event Withdraw(address buyer, uint256 amountOfEth);
  event Sold(address buyer, uint256 amountOfEth);

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable {
    require(msg.value > 0, 'Send ETH to buy some tokens');
    uint256 amountToBuy = msg.value * tokensPerEth;
    // check if the Vendor Contract has enough amount of tokens for the transaction
    uint256 vendorBalance = yourToken.balanceOf(address(this));
    require(vendorBalance >= amountToBuy, 'Vendor contract has not enough tokens in its balance');
    // Transfer token to the msg.sender
    bool sent = yourToken.transfer(msg.sender, amountToBuy);
    require(sent, 'Failed to transfer token to user');
    // emit the event
    emit BuyTokens(msg.sender, msg.value, amountToBuy);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() public payable onlyOwner {
    uint256 vendorBalance = address(this).balance;
    require(vendorBalance > 0, 'Owner has not balance to withdraw');
    (bool sent, ) = msg.sender.call{value: vendorBalance}('');
    require(sent, 'Failed withdraw');
    emit Withdraw(msg.sender, msg.value);
    return;
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint256 tokenAmountToSell) public {
    // Check that the requested amount of tokens to sell is more than 0
    require(tokenAmountToSell > 0, 'Specify an amount of token greater than zero');

    // Check that the user's token balance is enough to do the swap
    uint256 userBalance = yourToken.balanceOf(msg.sender);
    require(userBalance >= tokenAmountToSell, 'Your balance is lower than the amount of tokens you want to sell');

    // Check that the Vendor's balance is enough to do the swap
    uint256 amountOfETHToTransfer = tokenAmountToSell / tokensPerEth;
    uint256 ownerETHBalance = address(this).balance;
    require(ownerETHBalance >= amountOfETHToTransfer, 'Vendor has not enough funds to accept the sell request');

    bool sent = yourToken.transferFrom(msg.sender, address(this), tokenAmountToSell);
    require(sent, 'Failed to transfer tokens from user to vendor');

    (sent, ) = msg.sender.call{value: amountOfETHToTransfer}('');
    require(sent, 'Failed to send ETH to the user');
  }
}
