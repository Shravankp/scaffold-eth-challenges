// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Staker {
  
  using SafeMath for uint;

  uint public deadline;
  mapping(address => uint) public balances;
  uint256 public constant threshold = 1 ether;
  ExampleExternalContract public exampleExternalContract;
  bool public openForWithdraw = true;

  event Stake(address,uint256);

  modifier notCompleted {
    require(!exampleExternalContract.completed(), "the contract completed");
    _;
  }

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
      deadline = block.timestamp + 72 hours;
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable notCompleted {
    balances[msg.sender] += msg.value;
    emit Stake(address(msg.sender), msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public notCompleted {
    console.log("deadline :", deadline, "block time: ", block.timestamp);
    require(deadline <= block.timestamp, "deadline not met");
    if (address(this).balance >= threshold){
      exampleExternalContract.complete{value: address(this).balance}();
      openForWithdraw = false;
    }
  }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  // Add a `withdraw()` function to let users withdraw their balance
  function withdraw() public notCompleted {
    require(openForWithdraw, "threshold has been met, your amount is locked");
    uint amount = balances[msg.sender];
    balances[msg.sender] = 0;
    payable(address(msg.sender)).transfer(amount);
  }

  // Add a `timeLeft()` view function that returns the deadline left before the deadline for the frontend
  function timeLeft() public view returns (uint) {
    if (deadline <= block.timestamp) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable{
    stake();
  }

}
