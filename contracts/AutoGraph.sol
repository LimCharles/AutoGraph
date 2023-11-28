// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.8/contracts/token/ERC20/ERC20.sol";

contract AutoGraph is ERC20 {
    // Basic token mechanics
    mapping(uint256 => Car) public carRegistry;    
    mapping(address => CarOwner) public carOwners;
    mapping(address => bool) public isServiceCenter;
    mapping(address => bool) public isDealership;
    mapping(address => bool) public isThirdPartyAuditor;
    mapping(address => bool) public isAdmin;

    // Structs to store car and service data
    struct CarOwner {
        string name;
    }

    struct Car {
        uint256 id;
        string model;
        address currentOwner;
        CarOwner[] owners;
        ServiceRecord[] records;
    }

    struct ServiceRecord {
        uint256 carId;
        uint256 date;
        string serviceDetails;
    }

    // Modifiers
    modifier onlyServiceCenter() {
        require(isServiceCenter[msg.sender], "Caller is not a registered service center");
        _;
    }

    modifier onlyDealership() {
        require(isDealership[msg.sender], "Caller is not a registered dealership");
        _;
    }

    modifier onlyThirdPartyAuditor() {
        require(isThirdPartyAuditor[msg.sender], "Caller is not a registered third party auditor");
        _;
    }

    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "Caller is not an admin");
        _;
    }

    // Events
    event CarPurchased(address buyer, uint256 carId);
    event CarServiced(uint256 carId, uint256 date, string serviceDetails);

    // Constructor
    constructor()  ERC20("AutoGraph", "AGT") {
        isAdmin[msg.sender] = true;
    }

    // Admin Functions
    function registerAdmin(address newAdmin, uint256 mintAmount) public onlyAdmin {
        isAdmin[newAdmin] = true;
        _mint(newAdmin, mintAmount);
    }

    function registerDealership(address newDealership) public onlyAdmin {
        isDealership[newDealership] = true;
    }

    function registerThirdPartyAuditor(address newAuditor) public onlyAdmin {
        isThirdPartyAuditor[newAuditor] = true;
    }

    function registerServiceCenter(address newServiceCenter) public onlyAdmin {
        isServiceCenter[newServiceCenter] = true;
    }

    function registerOwner(address newOwner, string memory name) public onlyAdmin {
        CarOwner storage owner = carOwners[newOwner];
        owner.name = name;
    }

    // Dealership Functions
    function registerCar(uint carId, string memory model) public onlyDealership {
        Car storage newCar = carRegistry[carId];
        newCar.id = carId;
        newCar.model = model;
        newCar.currentOwner = address(0);
    }

    function registerOwner(uint carId, address owner) public onlyDealership {
        carRegistry[carId].currentOwner = owner;
    }

    // Consumer functions

    function performMaintenance(uint256 carId) public {
        // Check if the car is owned by the sender
        // Check if the car is not denied service
        // Deduct tokens and record service
    }

    // Service Center functions
    function repairCarAndAddToBlockchain(uint256 carId, string memory serviceDetails) public {
        // Ensure only authorized service centers can call this
        // Add service record to the blockchain
        emit CarServiced(carId, block.timestamp, serviceDetails);
    }

    function denyServiceToLowBalance(uint256 carId) public {
        // Ensure only authorized service centers can call this
        // Update car's service denial status
    }

    // Dealership functions
    function registerCarFromManufacturer(uint256 id, string memory model) public {
        // Ensure only authorized dealerships can call this
        // Add car to registry
    }

    function grantDiscount(address consumer, uint256 discountAmount) public {
        // Check dealership's balance
        // Apply discount to consumer's token balance
    }

    function sellCarToConsumer(uint256 carId, address consumer) public {
        // Check consumer's token balance
        // Transfer car ownership and deduct tokens
        emit CarPurchased(consumer, carId);
    }

    // Additional functions like transferring tokens, authorizing dealerships and service centers, etc.
}
