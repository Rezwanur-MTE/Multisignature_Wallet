// SPDX-License-Identifier :GPL-3.0
pragma solidity >=0.8.2< 0.9.0 ;

contract Multisig {
   address[] public owners;
   uint public numconfirmRequired;

   struct Transaction {
       address to;
       uint value;
       bool executed;
   }

   mapping(uint=>mapping(address=>bool)) isConfirmed;
   Transaction[] public transactions;

   event Transactionsubmitted(uint transactionID, address sender, address receiver, uint amount);
   event TransactionConfirmed(uint transactionID);

   constructor(address[] memory _owners, uint _numconfirmRequired){
       require(_owners.length>1,"Owners required must be greater than 1");
       require(_numconfirmRequired>0 && numconfirmRequired<=_owners.length, "Number of confirmation does not match ");

       for(uint i=0; i<_owners.length;i++){
           require(_owners[i]!=address(0)," Invalid Owner");
           owners.push(_owners[i]);

       }
       numconfirmRequired=_numconfirmRequired;

   }

   function submitTransaction(address _to) public payable {   // this function only submit the address to whome ether will be transfer, this function does not send ether in real 

       require(_to!=address(0)," Invalid receiver address");
       require(msg.value>0," Transfer amount must be greater then 0 ");

       uint transactionID= transactions.length;
       transactions.push(Transaction({to:_to, value:msg.value,executed: false }));
       emit Transactionsubmitted( transactionID, msg.sender,_to, msg.value);

   }

   function confiremTransaction(uint _transactionID) public {
       require(_transactionID<transactions.length,"Invalid transaction ID");
       require(!isConfirmed[_transactionID][msg.sender]," Transaction is already confirmed");
       isConfirmed[_transactionID][msg.sender]=true;  // isConfired is a nested mapping, so two key is required there, so two thired brakets.
       emit TransactionConfirmed(_transactionID);
       
       if(isTransactionConfirmed(_transactionID)){
           executeTransaction(_transactionID);
       }

   }
    function executeTransaction(uint _transactionID) public payable {   // private and internal function cannot be payable 

              require(_transactionID<transactions.length,"Invalid Transaction ID");
              require(!transactions[_transactionID].executed,"Transaction is already executed ");
             (bool success,) = transactions[_transactionID].to.call{value: transactions[_transactionID].value}("");
              require(success,"Transaction Execution Failed!");
              transactions[_transactionID].executed=true;
}


   function isTransactionConfirmed(uint transactionID) internal view returns(bool){
       require(transactionID<transactions.length," Invalid transaction ID");
       uint confirmationCount; // initially Zero

       for(uint i=0; i<owners.length;i++){

           if(isConfirmed[transactionID][owners[i]]){
               confirmationCount++;
           }

       }

       return confirmationCount>= numconfirmRequired;

   }

}