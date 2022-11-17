pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT
import 'hardhat/console.sol';
import './ExampleExternalContract.sol';

contract Staker {
  ExampleExternalContract public exampleExternalContract;

  mapping(address => uint256) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 30 seconds;
  bool public openForWithdraw = false;

  event Stake(address, uint256);
  event Received(address, uint256);
  event Withdraw(address, uint256);

  constructor(address exampleExternalContractAddress) {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  modifier notCompleted() {
    require(!exampleExternalContract.completed(), 'el contrato ah sido completado');
    _;
  }

  // TODO: Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable notCompleted {
    require(block.timestamp < deadline, 'deathline complete');
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  // TODO: After some `deadline` allow anyone to call an `execute()` function
  //  It should call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public payable notCompleted {
    require(block.timestamp > deadline, 'deathline not complete');
    if (address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      openForWithdraw = true;
    }
  }

  // TODO: if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw() public payable {
    require(block.timestamp > deadline, 'deathline not complete');
    require(openForWithdraw, 'dont open for withdraw');
    uint256 userBalance = balances[msg.sender];
    // check if the user has balance to withdraw
    require(userBalance > 0, "You don't have balance to withdraw");
    // reset the balance of the user
    balances[msg.sender] = 0;
    (bool sent, ) = msg.sender.call{value: userBalance}('');
    require(sent, 'Failed withdraw');
    emit Withdraw(msg.sender, balances[msg.sender]);
  }

  // TODO: Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    if (block.timestamp >= deadline) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }

  // TODO: Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    this.stake();
  }
}
