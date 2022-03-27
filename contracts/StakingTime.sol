// SPDX-License-Identifier: MIT
// Optimization: 1500
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingTime {
  IERC20 public stakingToken;

  uint public rewardRate = 100;
  uint public lastUpdateTime;
  uint public rewardPerTokenStored;

  mapping(address => uint) public userRewardPerTokenPaid;
  mapping(address => uint) public rewards;

  uint private _totalSupply;
  mapping(address => uint) private _balances;

  constructor(address _stakingToken) {
    stakingToken = IERC20(_stakingToken);
  }

  function rewardPerToken() public view returns (uint) {
    if (_totalSupply == 0) {
      return rewardPerTokenStored;
    }
    return
      rewardPerTokenStored +
      (((block.timestamp - lastUpdateTime) * rewardRate * 1e18) / _totalSupply);
  }

  /**
    Calculate earned for given account
   */
  function earned(address account) public view returns (uint) {
    return
      ((_balances[account] *
        (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18) +
      rewards[account];
  }

  /**
    Modifier to update reward for given account
   */
  modifier updateReward(address account) {
    rewardPerTokenStored = rewardPerToken();
    lastUpdateTime = block.timestamp;

    rewards[account] = earned(account);
    userRewardPerTokenPaid[account] = rewardPerTokenStored;
    _;
  }

  /**
    Stake
   */
  function stake(uint _amount) external updateReward(msg.sender) {
    _totalSupply += _amount;
    _balances[msg.sender] += _amount;
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
  function unstake(uint _amount) external updateReward(msg.sender) {
    _totalSupply -= _amount;
    _balances[msg.sender] -= _amount;
    stakingToken.transfer(msg.sender, _amount);
  }

  /**
    Get(claim) reward 
   */
  function getReward() external updateReward(msg.sender) {
    uint reward = rewards[msg.sender];
    rewards[msg.sender] = 0;
    stakingToken.transfer(msg.sender, reward);
  }
}