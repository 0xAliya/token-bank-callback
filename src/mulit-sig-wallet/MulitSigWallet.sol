// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MultiSigWallet {
  event Deposit(address indexed sender, uint256 amount);
  event Submit(uint indexed txId);
  event Approve(address indexed sender, uint indexed txId);
  event Execute(address indexed sender, uint indexed txId);
  event Revoke(address indexed sender, uint indexed txId);

  struct Transaction {
    address to;
    uint value;
    bytes data;
    bool executed;
  }

  uint256 public numConfirmationsRequired;

  mapping(address => bool) public isOwner;

  address[] public owners;

  Transaction[] public transactions;

  mapping(uint256 => mapping(address => bool)) public confirmations;

  modifier onlyOwner() {
    require(isOwner[msg.sender], "not owner");
    _;
  }

  modifier txExists(uint _txId) {
    require(_txId < transactions.length, "tx does not exist");
    _;
  }

  modifier notExecuted(uint _txId) {
    require(!transactions[_txId].executed, "tx already executed");
    _;
  }

  constructor(address[] memory _owners, uint _numConfirmationsRequired) {
    require(_owners.length > 0, "owners required");
    require(
      _numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length,
      "invalid number of required confirmations"
    );

    for (uint i = 0; i < _owners.length; i++) {
      address owner = _owners[i];

      require(owner != address(0), "invalid owner");
      require(!isOwner[owner], "owner not unique");

      isOwner[owner] = true;

      owners.push(owner);
    }

    numConfirmationsRequired = _numConfirmationsRequired;
  }

  receive() external payable {
    emit Deposit(msg.sender, msg.value);
  }

  function submit(address _to, uint _value, bytes calldata _data)
    external onlyOwner
    returns (uint transactionId)
  {
    transactionId = transactions.length;

    transactions.push(Transaction({
      to: _to,
      value: _value,
      data: _data,
      executed: false
    }));

    emit Submit(transactionId);

    return transactionId;

  }

  function approve (uint _txId) external onlyOwner txExists(_txId) notExecuted(_txId){
    confirmations[_txId][msg.sender] = true;
    emit Approve(msg.sender, _txId);  
  }

  function execute(uint _txId) external onlyOwner txExists(_txId) notExecuted(_txId){
    require(_getComfirmations(_txId) >= numConfirmationsRequired, "cannot execute tx");

    Transaction storage transaction = transactions[_txId];
    transaction.executed = true;

    (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);

    require(success, "tx failed");
    
    emit Execute(msg.sender, _txId);
  }

  function revoke(uint _txId) external onlyOwner txExists(_txId) notExecuted(_txId){
    confirmations[_txId][msg.sender] = false;
    emit Revoke(msg.sender, _txId);
  }

  function _getComfirmations(uint _txId) private view returns (uint count){
    for (uint i = 0; i < owners.length; i++) {
      if (confirmations[_txId][owners[i]]) {
        count += 1;
      }
    }
  }

} 