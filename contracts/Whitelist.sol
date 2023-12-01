// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Whitelist is Ownable {
    mapping(address => bool) public whitelist;

    event AddressAddedToWhitelist(address indexed account);
    event AddressRemovedFromWhitelist(address indexed account);

    function addAddressesToWhitelist(
        address account1,
        address account2,
        address account3,
        address account4,
        address account5,
        address account6,
        address account7,
        address account8,
        address account9,
        address account10
    ) external onlyOwner {
        addToWhitelist(account1);
        addToWhitelist(account2);
        addToWhitelist(account3);
        addToWhitelist(account4);
        addToWhitelist(account5);
        addToWhitelist(account6);
        addToWhitelist(account7);
        addToWhitelist(account8);
        addToWhitelist(account9);
        addToWhitelist(account10);
    }

    function addToWhitelist(address account) public onlyOwner {
        whitelist[account] = true;
        emit AddressAddedToWhitelist(account);
    }

    function removeFromWhitelist(address account) external onlyOwner {
        delete whitelist[account];
        emit AddressRemovedFromWhitelist(account);
    }

    function isWhitelisted(address account) public view returns (bool) {
        return whitelist[account];
    }
}
