// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Faucet {
  // The owner is used to change the amount transfered
  address public owner;
  // 1 eth
  uint256 public amountAllowed = 1000000000000000000;

  //mapping to keep track of requested tokens
  mapping(address => uint) public lockTime;

  //constructor to set the owner
  constructor() payable {
    owner = msg.sender;
  }

  // allow receiving payments
  receive() external payable {}

  modifier onlyOwner {
    require(msg.sender == owner, "Only owner can call this function.");
    _;
  }

  //function to change the owner.  Only the owner of the contract can call this function
  function setOwner(address newOwner) public onlyOwner {
    owner = newOwner;
  }

  //function to set the amount allowable to be claimed. Only the owner can call this function
  function setAmountallowed(uint newAmountAllowed) public onlyOwner {
    amountAllowed = newAmountAllowed;
  }

  //function to send tokens from faucet to an address
  function transfer(address payable _requestor) public payable {
    require(block.timestamp > lockTime[msg.sender], "lock time has not expired. Please try again later");

    // This would be an improvement but it doesn't work at the moment
    //require(address(this).balance > amountAllowed, "Not enough funds in the faucet. Please donate");

    (bool sent, ) = _requestor.call{value: amountAllowed}("");
    require(sent, "Failed to send Ether");

    lockTime[msg.sender] = block.timestamp + 1 days;
  }
}

