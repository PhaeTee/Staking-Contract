//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking {

    event Staked (address indexed user, uint256 indexed amount, uint256 stakingDuration, uint256 timestamp);
    event Withdrawn (address user, uint256 amount);

    address public usdtAddress;
    uint256 public stakingDuration;

    mapping (address user => uint256 amount ) stakedAmount;
    mapping (address user => uint256 duration) tokenStakedAt;

    constructor(address _usdtAddress, uint256 _stakingDuration) {
        usdtAddress = _usdtAddress;
        stakingDuration = _stakingDuration;
    }

    function stake (uint256 _amount, uint256 _stakingDuration, uint256 _timeStamp) external {
        require (_amount > 0, "staking amount is less than 0");
        require(IERC20(usdtAddress).balanceOf(msg.sender) >= _amount, "insuffiecient funds");

        IERC20(usdtAddress).transferFrom(msg.sender, address(this), _amount);

        stakedAmount [msg.sender] += _amount;

        tokenStakedAt [msg.sender] = block.timestamp;

        emit Staked (msg.sender, _amount, _stakingDuration, _timeStamp);
        }

    function withdraw (uint256 _amount) external {
        stakedAmount[msg.sender] = stakedAmount[msg.sender] - _amount;
        require(block.timestamp >= tokenStakedAt [msg.sender] + stakingDuration, "Staking duration not reached");
        require(stakedAmount [msg.sender]>0,"no stakes");

        IERC20(usdtAddress).transfer(msg.sender, stakedAmount[msg.sender]);

        emit Withdrawn(msg.sender, stakedAmount[msg.sender]);
    }

    function getUserStake () external view returns (uint) {
        return stakedAmount [msg.sender];
}
}