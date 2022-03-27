// SPDX-License-Identifier: MIT
// Optimization: 1500
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingRewards {
  IERC20 public stakingToken;

  uint public rewardPerToken;

  uint public _totalSupply;
  mapping(address => uint) public _balances;
  mapping(address => uint) public _rewardsTally;

  constructor(address _stakingToken) {
    stakingToken = IERC20(_stakingToken);
  }

  function distribute(uint reward) public {
    if (_totalSupply != 0) {
      rewardPerToken = rewardPerToken + reward * 1e18 / _totalSupply;
    }
  }

  /**
    Calculate earned for given account
   */
  function earned(address account) public view returns (uint) {
    return _balances[account] * rewardPerToken / 1e18 - _rewardsTally[account];
  }

  /**
    Stake
   */
  function stake(uint _amount) external {
    _totalSupply += _amount;
    _balances[msg.sender] += _amount;
    _rewardsTally[msg.sender] = _rewardsTally[msg.sender] + rewardPerToken * _amount / 1e18;
    stakingToken.transferFrom(msg.sender, address(this), _amount);
  }

  /**
    See how many tokens each user can unstake
    Calculate the amount for unstake = balance + earned
   */
  function calcUnstake(address account) public view returns (uint) {
    return _balances[account] + earned(account);
  }

  /**
    Unstake (would be a plus if caller can unstake part of stake)
    Unstake given amount
   */
  function unstake(uint _amount) external {
    _totalSupply -= _amount;
    _balances[msg.sender] -= _amount;
    _rewardsTally[msg.sender] = _rewardsTally[msg.sender] - rewardPerToken * _amount / 1e18;
    stakingToken.transfer(msg.sender, _amount);
  }

  /**
    Get(claim) reward 
   */
  function getReward() external {
    uint reward = earned(msg.sender);
    _rewardsTally[msg.sender] = _balances[msg.sender] * rewardPerToken / 1e18;
    stakingToken.transfer(msg.sender, reward);
  }
}