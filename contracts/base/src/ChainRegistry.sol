// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BountyPool {
    struct Bounty {
        string description;
        uint256 totalPool;
        address[] contributors;
        uint256[] contributions;
        address hunter;
        bool claimed;
    }

    mapping(uint256 => Bounty) public bounties;
    uint256 public bountyCount;

    event BountyCreated(uint256 indexed bountyId, string description);
    event ContributionAdded(uint256 indexed bountyId, address indexed contributor, uint256 amount);
    event BountyClaimed(uint256 indexed bountyId, address indexed hunter);

    error BountyAlreadyClaimed();

    function createBounty(string memory description) external payable returns (uint256) {
        uint256 bountyId = bountyCount++;
        Bounty storage bounty = bounties[bountyId];
        bounty.description = description;
        bounty.totalPool = msg.value;
        bounty.contributors.push(msg.sender);
        bounty.contributions.push(msg.value);
        emit BountyCreated(bountyId, description);
        return bountyId;
    }

    function contribute(uint256 bountyId) external payable {
        Bounty storage bounty = bounties[bountyId];
        bounty.totalPool += msg.value;
        bounty.contributors.push(msg.sender);
        bounty.contributions.push(msg.value);
        emit ContributionAdded(bountyId, msg.sender, msg.value);
    }

    function claimBounty(uint256 bountyId, address hunter) external {
        Bounty storage bounty = bounties[bountyId];
        if (bounty.claimed) revert BountyAlreadyClaimed();
        bounty.hunter = hunter;
        bounty.claimed = true;
        emit BountyClaimed(bountyId, hunter);
    }

    function getBountyContributors(uint256 bountyId) external view returns (address[] memory, uint256[] memory) {
        return (bounties[bountyId].contributors, bounties[bountyId].contributions);
    }
}
