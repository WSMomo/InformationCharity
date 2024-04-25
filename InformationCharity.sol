// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract InformationCharity {
    // struct declaration
    struct Donation {
        uint256 value;
        uint256 numberOfDonations;
    }

    struct DonationWithAddresses {
        address donatorAddres;
        uint256 value;
        uint256 numberOfDonations;
    }

    // information about donators
    mapping(address => Donation) private donations;
    address[] private donorAddresses;
    DonationWithAddresses[] donationWithAddresses;

    // variables initialization
    uint256 public totalDonors = 0;
    uint256 public totalAmount = 0;
    bool public isEnded = false;

    // variables initialized at start
    uint256 public goal;
    address payable public owner;

    constructor(uint256 _goal) {
        owner = payable(msg.sender);
        goal = _goal * 1 ether;
    }

    // check if the donation amount is valid
    modifier isValidAmount() {
        require(msg.value > 0, "Donation amount must be greater than zero");
        _;
    }

    // check if the campaign is active
    modifier campaignIsActive() {
        require(!isEnded, "This campaign is ended.");
        _;
    }

    // check if the request address is owner
    modifier isOwner() {
        require(msg.sender == owner, "You must be the owner");
        _;
    }

    // make the donation and save the donators data
    // if the campaign goal is reached end the campaign
    function donate() public payable isValidAmount campaignIsActive {
        totalAmount += msg.value;
        updateDonators(msg.sender, msg.value);
        automaticEndCampaign();
    }

    // update the donators info
    function updateDonators(address sender, uint256 value) private {
        totalDonors++;
        if (donations[sender].value == 0) {
            donations[sender] = Donation(value, 1);
            donorAddresses.push(sender);
        } else {
            donations[sender].value += value;
            donations[sender].numberOfDonations++;
        }
    }

    // check if the goal is reached and return the relative string
    function checkGoalReached() public view returns (string memory) {
        string memory message;
        if (totalAmount == goal) {
            message = "Goal Achivied";
            return message;
        } else if (totalAmount < goal) {
            uint256 missingAmount = goal - totalAmount;
            if (missingAmount % 1 ether == 0) {
                message = string(
                    abi.encodePacked(
                        "Goal Not Achieved. We need other ",
                        toString(missingAmount / 1 ether),
                        " ether."
                    )
                );
            } else {
                uint256 missingWei = missingAmount % 1 ether;
                uint256 missingEth = missingAmount / 1 ether;
                message = string(
                    abi.encodePacked(
                        "Goal Not Achieved. We need about ",
                        toString(missingEth),
                        " ether and ",
                        toString(missingWei),
                        " wei"
                    )
                );
            }

            return message;
        } else {
            uint256 extraAmount = totalAmount - goal;
            if (extraAmount % 1 ether == 0) {
                message = string(
                    abi.encodePacked(
                        "Goal Exceeded. We have extra ",
                        toString((totalAmount - goal) / 1 ether),
                        " ether"
                    )
                );
            } else {
                uint256 extraWei = extraAmount % 1 ether;
                uint256 extraEth = extraAmount / 1 ether;
                message = string(
                    abi.encodePacked(
                        "Goal Exceeded. We have extra ",
                        toString(extraEth),
                        " ether and ",
                        toString(extraWei),
                        " wei"
                    )
                );
            }
            return message;
        }
    }

    // consent ONLY to the owner to withdraw and close the campaign
    function withdraw() public isOwner {
        owner.transfer(totalAmount);
        isEnded = true;
    }

    // close the campaign automatically if the goal is reached
    function automaticEndCampaign() private {
        if (totalAmount >= goal) {
            isEnded = true;
        }
    }

    // close the campaign ONLY if the sender is the owner
    function endCampaign() public isOwner {
        isEnded = true;
    }

    // conver an uint to a string
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + (value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    // return an array with the donators info
    function getDonations() public returns (DonationWithAddresses[] memory) {
        uint256 totalDonorsLength = donorAddresses.length;

        for (uint256 i = 0; i < totalDonorsLength; i++) {
            DonationWithAddresses memory newDonation;
            newDonation.donatorAddres = donorAddresses[i];
            newDonation.value = donations[donorAddresses[i]].value;
            newDonation.numberOfDonations = donations[donorAddresses[i]]
                .numberOfDonations;

            donationWithAddresses.push(newDonation);
        }

        return donationWithAddresses;
    }
}
