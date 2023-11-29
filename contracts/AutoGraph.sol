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
        uint tokenBalance;
    }

    struct Car {
        uint256 id;
        string model;
        address currentOwner;
        uint256 retailPrice;
        CarOwner[] owners;
        ServiceRecord[] records;
    }

    struct ServiceRecord {
        uint256 carId;
        uint256 date;
        string serviceDetails;
    }

    // Modifiers
    modifier onlyCarOwner() {
        require(keccak256(abi.encodePacked(carOwners[msg.sender].name)) != keccak256(abi.encodePacked("")), "Caller is not a registered car owner");
        _;
    }

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

    function registerDealership(address newDealership, uint256 mintAmount) public onlyAdmin {
        isDealership[newDealership] = true;
         _mint(newDealership, mintAmount);
    }

    function registerThirdPartyAuditor(address newAuditor, uint256 mintAmount) public onlyAdmin {
        isThirdPartyAuditor[newAuditor] = true;
        _mint(newAuditor, mintAmount);
    }

    function registerServiceCenter(address newServiceCenter, uint256 mintAmount) public onlyAdmin {
        isServiceCenter[newServiceCenter] = true;
        _mint(newServiceCenter, mintAmount);
    }

    function registerOwner(address newOwner, string memory name, uint256 mintAmount) public onlyAdmin {
        CarOwner storage owner = carOwners[newOwner];
        owner.name = name;
        _mint(newOwner, mintAmount);
    }

    // Dealership Functions
    function registerCar(uint256 carId, string memory model, uint256 retailPrice) public onlyDealership {
        require(carRegistry[carId].id == 0, "Car ID already in use");
        Car storage newCar = carRegistry[carId];
        newCar.id = carId;
        newCar.model = model;
        newCar.currentOwner = address(0);
        newCar.retailPrice = retailPrice;
    }

    function registerCarOwner(uint256 carId, address owner) public payable {
        uint256 requiredTokenAmount = 1000 * (10 ** uint256(decimals()));
        uint256 discountThreshold = 5000 * (10 ** uint256(decimals())); 
        require(balanceOf(owner) >= requiredTokenAmount, "Insufficient token balance to purchase car");

        uint256 retailPrice = carRegistry[carId].retailPrice;
        if (balanceOf(owner) > discountThreshold) {
            retailPrice -= 500 wei;
        }
        
        require(msg.value == retailPrice, "Paid amount is not exact");

        carRegistry[carId].currentOwner = owner;
    }

    // Service Center functions
    function performMaintenance(uint256 carId, string memory maintenance) public onlyServiceCenter {
        uint256 requiredTokenAmount = 1000 * (10 ** uint256(decimals()));
        require(balanceOf(carRegistry[carId].currentOwner) >= requiredTokenAmount, "Insufficient token balance to service car");
        
        carRegistry[carId].records.push(ServiceRecord({
            carId: carId,
            date: block.timestamp,
            serviceDetails: maintenance
        }));
        
        _mint(carRegistry[carId].currentOwner, 500 * (10 ** uint256(decimals()))); 

        emit CarServiced(carId, block.timestamp, maintenance);
    }

    // Third Party Auditor
    function repairCarFromAccident(uint256 carId, string memory serviceDetails, address perpetrator, uint256 tokenBurnAmount) public onlyThirdPartyAuditor {
        carRegistry[carId].records.push(ServiceRecord({
            carId: carId,
            date: block.timestamp,
            serviceDetails: serviceDetails
        }));

        _burn(perpetrator, tokenBurnAmount * (10 ** uint256(decimals())));

        emit CarServiced(carId, block.timestamp, serviceDetails);
    }

    function burnTokenFromParty(address perpetrator, uint256 tokenBurnAmount) public onlyThirdPartyAuditor {
        _burn(perpetrator, tokenBurnAmount * (10 ** uint256(decimals())));
    }

    // Public
    function getPartyBalance(address partyAddress) public view returns (uint256) {
        return balanceOf(partyAddress);
    }
}
