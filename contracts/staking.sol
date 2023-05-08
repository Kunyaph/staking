// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./USDT.sol";
import "./kunyastoken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingContract is Ownable {
    USDT public usdtToken;
    KunyasToken public kunya;

    uint256 public totalStaked;
    uint256 public rewardPercentage;

    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public lastClaimedTime;

    mapping(address => bool) public whitelist;

    event TokensStaked(address indexed account, uint256 amount);
    event TokensClaimed(address indexed account, uint256 amount);
    event TokensWithdrawn(address indexed account, uint256 amount);
    event TokensAirdropped(address indexed account, uint256 amount);

    constructor(address _usdtToken, address _kunya) {
        usdtToken = USDT(_usdtToken);
        kunya = KunyasToken(_kunya);
        rewardPercentage = 10; // 10% reward
    }

    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "Not whitelisted");
        _;
    }

    function addToWhitelist(address account) external onlyOwner {
        whitelist[account] = true;
    }

    function removeFromWhitelist(address account) external onlyOwner {
        whitelist[account] = false;
    }

    function buyToken(uint256 usdtAmount) external {
        require(usdtAmount > 0, "Invalid USDT amount");

        // Transfer USDT from sender to contract
        usdtToken.transferFrom(msg.sender, address(this), usdtAmount);

        // Calculate amount of tokens to mint based on usdtAmount
        uint256 tokenAmount = usdtAmount; // 1 USDT = 1 KUNYA TOKEN

        // Mint tokens to sender
        kunya.mint(msg.sender, tokenAmount);

        // Stake the minted tokens
        stake(tokenAmount);
    }

    function stake(uint256 amount) public {
        require(amount > 0, "Invalid amount");

        // Transfer tokens from sender to contract
        kunya.transferFrom(msg.sender, address(this), amount);

        // Update staked balance
        stakedBalance[msg.sender] += amount;
        totalStaked += amount;

        // Update last claimed time
        lastClaimedTime[msg.sender] = block.timestamp;

        emit TokensStaked(msg.sender, amount);
    }

    function claim() public {
        uint256 reward = calculateReward(msg.sender);

        require(reward > 0, "No rewards to claim");
        
        // Transfer reward tokens to sender
        kunya.transfer(msg.sender, reward);

        // Update last claimed time
        lastClaimedTime[msg.sender] = block.timestamp;

        emit TokensClaimed(msg.sender, reward);
    }

    function withdraw() external {
        uint256 stakedAmount = stakedBalance[msg.sender];

        require(stakedAmount > 0, "No tokens to withdraw");

        // Transfer staked tokens to sender
        kunya.transfer(msg.sender, stakedAmount);

        // Update staked balance
        stakedBalance[msg.sender] = 0;
        totalStaked -= stakedAmount;

        emit TokensWithdrawn(msg.sender, stakedAmount);
    }

    function airdropTokens(address[] calldata recipients, uint256 amount) external onlyOwner {
        require(amount > 0, "Invalid amount");

        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            kunya.mint(recipient, amount);
            emit TokensAirdropped(recipient, amount);
        }
    }

    function calculateReward(address account) internal view returns (uint256) {
        uint256 stakedAmount = stakedBalance[account];
        uint256 lastClaimTime = lastClaimedTime[account];
        uint256 currentTime = block.timestamp;

        uint256 timeDifference = currentTime - lastClaimTime;

        uint256 reward = (stakedAmount * rewardPercentage * timeDifference) / (100 * 1 days);

        return reward;
    }
}