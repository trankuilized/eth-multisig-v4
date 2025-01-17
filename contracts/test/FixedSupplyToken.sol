// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.10;

// ----------------------------------------------------------------------------------------------
// Sample fixed supply token contract
// Enjoy. (c) BokkyPooBah 2017. The MIT Licence.
// ----------------------------------------------------------------------------------------------

// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/issues/20
abstract contract IERC20 {
  // Get the total token supply
  function totalSupply() external virtual view returns (uint256);

  // Get the account balance of another account with address _owner
  function balanceOf(address _owner) external virtual returns (uint256 balance);

  // Send _value amount of tokens to address _to
  function transfer(address _to, uint256 _value)
    external
    virtual
    returns (bool success);

  // Send _value amount of tokens from address _from to address _to
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  ) external virtual returns (bool success);

  // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
  // If this function is called again it overwrites the current allowance with _value.
  // this function is required for some DEX functionality
  function approve(address _spender, uint256 _value)
    external
    virtual
    returns (bool success);

  // Returns the amount which _spender is still allowed to withdraw from _owner
  function allowance(address _owner, address _spender)
    external
    virtual
    view
    returns (uint256 remaining);

  // Triggered when tokens are transferred.
  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  // Triggered whenever approve(address _spender, uint256 _value) is called.
  event Approval(
    address indexed _owner,
    address indexed _spender,
    uint256 _value
  );
}

contract FixedSupplyToken is IERC20 {
  string public constant symbol = 'FIXED';
  string public constant name = 'Example Fixed Supply Token';
  uint8 public constant decimals = 18;
  uint256 public constant _totalSupply = 1000000;

  // Owner of this contract
  address public owner;

  // Balances for each account
  mapping(address => uint256) public balances;

  // Owner of account approves the transfer of an amount to another account
  mapping(address => mapping(address => uint256)) public allowed;

  // Functions with this modifier can only be executed by the owner
  modifier onlyOwner() {
    if (msg.sender != owner) {
      revert('Not owner');
    }
    _;
  }

  // Constructor
  constructor() {
    owner = msg.sender;
    balances[owner] = _totalSupply;
  }

  function totalSupply() external override pure returns (uint256) {
    return _totalSupply;
  }

  // What is the balance of a particular account?
  function balanceOf(address _owner)
    external
    override
    view
    returns (uint256 balance)
  {
    return balances[_owner];
  }

  // Transfer the balance from owner's account to another account
  function transfer(address _to, uint256 _amount)
    external
    override
    returns (bool success)
  {
    if (
      balances[msg.sender] >= _amount &&
      _amount > 0 &&
      balances[_to] + _amount > balances[_to]
    ) {
      balances[msg.sender] -= _amount;
      balances[_to] += _amount;
      emit Transfer(msg.sender, _to, _amount);
      return true;
    } else {
      return false;
    }
  }

  // Send _value amount of tokens from address _from to address _to
  // The transferFrom method is used for a withdraw workflow, allowing contracts to send
  // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
  // fees in sub-currencies; the command should fail unless the _from account has
  // deliberately authorized the sender of the message via some mechanism; we propose
  // these standardized APIs for approval:
  function transferFrom(
    address _from,
    address _to,
    uint256 _amount
  ) external override returns (bool success) {
    if (
      balances[_from] >= _amount &&
      allowed[_from][msg.sender] >= _amount &&
      _amount > 0 &&
      balances[_to] + _amount > balances[_to]
    ) {
      balances[_from] -= _amount;
      allowed[_from][msg.sender] -= _amount;
      balances[_to] += _amount;
      emit Transfer(_from, _to, _amount);
      return true;
    } else {
      return false;
    }
  }

  // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
  // If this function is called again it overwrites the current allowance with _value.
  function approve(address _spender, uint256 _amount)
    external
    override
    returns (bool success)
  {
    allowed[msg.sender][_spender] = _amount;
    emit Approval(msg.sender, _spender, _amount);
    return true;
  }

  function allowance(address _owner, address _spender)
    external
    override
    view
    returns (uint256 remaining)
  {
    return allowed[_owner][_spender];
  }
}
