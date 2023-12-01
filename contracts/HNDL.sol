// SPDX-License-Identifier: MIT
// Project: HNDL - Decentralized Handle System on Bitcoin
// Copyright (c) 2023 Study Bitcoin, https://x.com/studybitco
// Version: 1.0.55
// Developed by: Founder & CXO - Jvar Vsev, https://x.com/jvarvsev
// Contributors: 
//   - Founder & CEO - Cordy Joseph, https://x.com/cordyjos 
//   - Founder & CTO - Olusegun Samson, https://x.com/watchman_crypt
// Contact: admin@studybitco.in
// Date: October 31, 2023

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./StringUtil.sol";
import "./Whitelist.sol"; 

contract HNDL is Ownable, ERC721 {
    
    address private feeRecipient;
    Whitelist private whitelistContract;
    
    uint256 private immutable ONE_YEAR_IN_SECONDS = 365 days;
    uint256 private immutable MAX_CHARACTER_LENGTH = 18;
    uint256 private immutable MINIMUM_CHARACTER_COUNT = 1;

    bytes private constant HANDLE_SUFFIX = hex"e282bf"; // ".₿" in UTF-8 encoding
    uint256 private fees;
    uint256 private _totalSupply;
    uint256 public contractDeploymentTime; // Deployment time proxy
    uint256 immutable HALVING_PERIOD = 252288000; // Approximately 8 years in seconds

    // Structs
    struct Handle {
        uint256 tokenId;
        uint256 expirationTimestamp;
        address parentOwner;
        uint256 subhandleCount;
        mapping(string => Subhandle) subhandles;
        uint256 registrationYears;
        string bitcoinAddress;
    }

    struct Subhandle {
        uint256 tokenId;
        address owner;
        uint256 expirationTimestamp;
        bool requested;
        uint256 registrationYears;
        string bitcoinAddress;
    }

    struct HandleInfo {
        uint256 tokenId;
        address owner;
        uint256 expirationTimestamp;
        uint256 subhandleCount;
        string bitcoinAddress;
    }

    struct SubhandleInfo {
        uint256 tokenId;
        address owner;
        uint256 expirationTimestamp;
        address parentHandleOwner;
        string bitcoinAddress;
    }

    struct ParentHandle {
        address parentOwner;
        bool permissionEnabled;
    }

    // Mappings
    mapping(string => Handle) private handles;
    mapping(uint256 => string) private handleNames;
    mapping(address => mapping(string => ParentHandle)) private parentHandleOwners;
    mapping(string => uint256) private tokenIds;
    mapping(uint256 => uint256) private parentTokenIds;
    mapping(uint256 => address) private parentOwners;
    mapping(address => uint256) private whitelistedMints;
    mapping(address => uint256) private freeWhitelistMints;
    mapping(address => uint256) private paidWhitelistMints;
    mapping(address => uint256) private feeBalances;

    // Events
    event HandleRegistered(
        address indexed owner,
        string handleName,
        uint256 expirationTimestamp,
        uint256 indexed tokenId
    );

    event HandleRenewed(
        address renewedBy,
        address indexed owner,
        string handleName,
        uint256 newExpirationTimestamp,
        uint256 indexed tokenId
    );

    event SubhandleRegistered(
        address indexed owner,
        string subhandleName,
        string parentHandleName,
        address parentOwner,
        uint256 expirationTimestamp,
        uint256 indexed tokenId
    );

    event SubhandleRenewed(
        address renewedBy,
        address indexed owner,
        string subhandleName,
        string parentHandleName,
        address indexed parentOwner,
        uint256 newExpirationTimestamp,
        uint256 indexed tokenId
    );

    event SubhandlePermissionToggled(
        address indexed owner,
        string parentHandleName,
        bool permissionEnabled,
        uint256 indexed tokenId
    );

    event HandleTransferred(
        address indexed previousOwner,
        string handleOrSubhandleName,
        address indexed newOwner,
        uint256 indexed tokenId
    );

    event HandleBurned(
        address indexed owner, 
        string handleName,
        uint256 indexed tokenId
    );

    event SubhandleBurned(
        address indexed owner, 
        string subhandleName,
        uint256 indexed tokenId
    );

    event BtcAddressHandleSet(
        address indexed setter,
        string handleName,
        string bitcoinAddress,
        uint256 indexed tokenId
    );

    event BtcAddressSubhandleSet(
        address indexed setter,
        string subhandleName,
        string bitcoinAddress,
        uint256 indexed tokenId
    );

    mapping(uint256 => uint256) private handleFees;
    mapping(uint256 => uint256) private subhandleFees;
    
    constructor(address _feeRecipient, address _whitelistAddress) Ownable() ERC721("HNDL", ".\xE2\x82\xBF") {

        feeRecipient = _feeRecipient;
        whitelistContract = Whitelist(_whitelistAddress);
        contractDeploymentTime = block.timestamp; // Set the deployment timestamp

        // Initialize handle fees for character counts 1 to 4
        handleFees[1] = 1000000000000000000 wei;
        handleFees[2] = 250000000000000000 wei;
        handleFees[3] = 15000000000000000 wei;
        handleFees[4] = 5000000000000000 wei;

        // Initialize subhandle fees for character counts 1 to 4
        subhandleFees[1] = 500000000000000000 wei;
        subhandleFees[2] = 125000000000000000 wei;
        subhandleFees[3] = 7500000000000000 wei;
        subhandleFees[4] = 2500000000000000 wei;

        // Initialize handle and subhandle fees for character counts 5 to 14
        for (uint256 i = 5; i <= 14; i++) {
            handleFees[i] = 200000000000000 wei;
            subhandleFees[i] = 200000000000000 wei;
        }

        // Initialize handle and subhandle fees for character counts 15 to 18
        for (uint256 i = 15; i <= 18; i++) {
            handleFees[i] = 290000000000 wei;
            subhandleFees[i] = 290000000000 wei;
        }
    }

    function calculateFee(uint256 characterCount, uint256 registrationYears, bool isSubhandle) internal view returns (uint256) {
        require(characterCount >= MINIMUM_CHARACTER_COUNT && characterCount <= MAX_CHARACTER_LENGTH, "Invalid character count");

        uint256 timeElapsed = block.timestamp - contractDeploymentTime;
        uint256 halvingCount = timeElapsed / HALVING_PERIOD; // Approximately 8 years

        // Reset the cycle back to 1 after the 9th cycle
        uint256 currentCycle = (halvingCount % 9) + 1;

        uint256 fee = isSubhandle ? subhandleFees[characterCount] : handleFees[characterCount];
        fee = fee * registrationYears;

        // Adjust the fee based on the current cycle
        fee = fee / (2 ** (currentCycle - 1)); // Subtract 1 to start from cycle 1

        return fee;
    }

    function calculateHandleFee(uint256 characterCount, uint256 registrationYears) public view returns (uint256) {
        return calculateFee(characterCount, registrationYears, false);
    }

    function calculateSubhandleFee(uint256 characterCount, uint256 registrationYears) public view returns (uint256) {
        return calculateFee(characterCount, registrationYears, true);
    }

    function updateFeeRecipient(address newFeeRecipient) external onlyOwner {
        require(newFeeRecipient != address(0), "Invalid address");
        feeRecipient = newFeeRecipient;
    }

    modifier validHandleName(string memory handleName) {
        require(
            !StringUtil.hasConsecutiveHyphens(handleName) || StringUtil.hasValidPrefix(handleName),
            
            "Handle cannot contain consecutive hyphens"
        );
        _;
    }

    modifier validHyphenAndDot(string memory handleName) {
        require(
            !(StringUtil.hasHyphenBeforeDot(handleName) || StringUtil.countDots(handleName) > 1),
            "Handle cannot start or end with a hyphen or dot"
            
        );
        _;
    }

    modifier noDot(string memory _handle) {
        require(!StringUtil.containsSpecialCharacters(_handle, "."), "Handle cannot contain '.'");

        _;
    }

    modifier validMainPart(string memory handleName) {
        bytes memory handleBytes = bytes(handleName);

        // Regular expression pattern to match only alphanumeric characters, hyphens, and dot (.)
        bytes memory allowedPattern = abi.encodePacked("0123456789abcdefghijklmnopqrstuvwxyz-."); 

        require(handleBytes.length > 0, "Handle name must not be empty");

        // Check for consecutive dots
        for (uint256 i = 1; i < handleBytes.length; i++) {
            require(!(handleBytes[i] == '.' && handleBytes[i - 1] == '.'), "Handle cannot contain consecutive dots");
        }

        for (uint256 i = 0; i < handleBytes.length; i++) {
            bytes1 character = handleBytes[i];
            bool isAllowedCharacter = false;
            for (uint256 j = 0; j < allowedPattern.length; j++) {
                if (character == allowedPattern[j]) {
                    isAllowedCharacter = true;
                    break;
                }
            }
            require(isAllowedCharacter, "Invalid character in handle name");
        }

        // Check if the handle starts or ends with a hyphen or dot
        require(handleBytes[0] != '-' && handleBytes[0] != '.' && handleBytes[handleBytes.length - 1] != '-' && handleBytes[handleBytes.length - 1] != '.', "Handle cannot start or end with a hyphen or dot");

        _;
    }

    function toggleSubhandlePermission(string memory parentHandleName) external payable {
        require(bytes(parentHandleName).length > 0, "Invalid parent handle name");

        string memory parentHandleWithSuffix = string(abi.encodePacked(parentHandleName, ".", string(HANDLE_SUFFIX)));

        Handle storage parentHandle = handles[parentHandleWithSuffix];
        require(parentHandle.tokenId != 0, "Parent handle not registered");
        require(msg.sender == parentHandle.parentOwner, "Only the parent handle owner can toggle permission");

        ParentHandle storage parentPermissions = parentHandleOwners[msg.sender][parentHandleWithSuffix];

        if (!parentPermissions.permissionEnabled) {
            // Charge a fee of 2.9 * 10^15 wei (2900000000000000 wei) to enable
            require(msg.value == 2900000000000000 wei, "Invalid fee amount");

            // Transfer the fee to the feeRecipient
            payable(feeRecipient).transfer(msg.value);
        }

        parentPermissions.permissionEnabled = !parentPermissions.permissionEnabled; // Toggle permission

        uint256 tokenId = parentHandle.tokenId;

        // Emit the event with the parent handle name including the suffix
        emit SubhandlePermissionToggled(
            msg.sender,
            parentHandleWithSuffix,
            parentPermissions.permissionEnabled,
            tokenId
        );
    }

    function isPermissionEnabled(string memory parentHandleName, address parentOwner) internal view returns (bool) {
        ParentHandle storage parentPermissions = parentHandleOwners[parentOwner][parentHandleName];
        return parentPermissions.permissionEnabled;
    }

    function isSubhandlePermissionEnabled(string memory parentHandleName) external view returns (bool) {
        require(bytes(parentHandleName).length > 0, "Invalid parent handle name");

        string memory parentHandleWithSuffix = string(abi.encodePacked(parentHandleName, ".", string(HANDLE_SUFFIX)));

        Handle storage parentHandle = handles[parentHandleWithSuffix];
        require(parentHandle.tokenId != 0, "Parent handle not registered");

        ParentHandle storage parentPermissions = parentHandleOwners[parentHandle.parentOwner][parentHandleWithSuffix];
        return parentPermissions.permissionEnabled;
    }

    modifier onlyParentOwner(uint256 tokenId) {
        require(msg.sender == parentOwners[tokenId], "Not handle owner");
        _;
    }

    // Function to withdraw handle fees by parent owner
    function withdrawHandleFees(uint256 tokenId) public onlyParentOwner(tokenId) {
        // Transfer handle fees to owner
        payable(parentOwners[tokenId]).transfer(handleFees[tokenId]);
    }

    function isWhitelisted(address account) public view returns (bool) {
        return whitelistContract.isWhitelisted(account);
    }

    function burnHandle(uint256 tokenId) internal {
        string memory handleWithSuffix = handleNames[tokenId];
        Handle storage handle = handles[handleWithSuffix];

        require(handle.tokenId != 0, "Handle not registered");
        require(handle.expirationTimestamp <= block.timestamp, "Handle is not expired");
        
        address owner = ownerOf(tokenId);
        require(owner == handle.parentOwner, "Only parent owner can burn expired handle");

        // Burn the token
        _burn(tokenId);

        emit HandleBurned(owner, handleWithSuffix, tokenId);
    }

    function burnSubhandle(string memory subhandleAndParent) internal {
        (string memory subhandleName, string memory parentHandleName) = StringUtil.splitCombinedHandleName(subhandleAndParent);
        string memory parentHandleWithSuffix = string(abi.encodePacked(parentHandleName, ".", string(HANDLE_SUFFIX)));
        Subhandle storage subhandle = handles[parentHandleWithSuffix].subhandles[subhandleName];

        require(subhandle.tokenId != 0, "Subhandle not registered");
        require(subhandle.expirationTimestamp <= block.timestamp, "Subhandle is not expired");

        address owner = ownerOf(subhandle.tokenId);
        require(owner == subhandle.owner, "Only subhandle owner can burn expired subhandle");

        // Burn the token
        _burn(subhandle.tokenId);

        string memory subhandleWithSuffix = string(abi.encodePacked(subhandleName, ".", parentHandleWithSuffix));
        emit SubhandleBurned(owner, subhandleWithSuffix, subhandle.tokenId);
    }

    function mintHandle(
        string memory handleName,
        uint256 registrationYears
    ) external payable noDot(handleName) validMainPart(handleName) validHandleName(handleName) {
        // Check if the handle with suffix is already registered
        string memory parentHandleWithSuffix = string(abi.encodePacked(handleName, ".", string(HANDLE_SUFFIX)));
        Handle storage handle = handles[parentHandleWithSuffix];
        
        bool isExpired = (handle.tokenId != 0 && handle.expirationTimestamp <= block.timestamp);
        
        if (handle.tokenId == 0 || isExpired) {
            uint256 characterCount = bytes(handleName).length; // Calculate the character count
            uint256 registrationFee = calculateHandleFee(characterCount, registrationYears); // Calculate the registration fee

            // Check if the user is whitelisted
            bool isWhitelistedUser = whitelistContract.isWhitelisted(msg.sender);

            // Check for free mint eligibility
            if (isWhitelistedUser && registrationYears == 1 && characterCount >= 4 && freeWhitelistMints[msg.sender] < 3) {
                // Mint free handle
                freeWhitelistMints[msg.sender]++;
            } else if (msg.value >= registrationFee) {
                // Mint paid handle
                paidWhitelistMints[msg.sender]++;
            } else {
                revert("Insufficient registration fee or not eligible for free mint");
            }

            // Burn expired handle if applicable
            if (isExpired) {
                burnHandle(handle.tokenId); // Burn the expired token
            }

            // Generate a new token ID for the claimed handle
            uint256 tokenId = _totalSupply + 1;
            _totalSupply += 1;
            _mint(msg.sender, tokenId);

            Handle storage newHandle = handles[parentHandleWithSuffix];
            newHandle.tokenId = tokenId;
            newHandle.expirationTimestamp = block.timestamp + (ONE_YEAR_IN_SECONDS * registrationYears);
            newHandle.parentOwner = msg.sender;
            newHandle.registrationYears = registrationYears;

            handleNames[tokenId] = parentHandleWithSuffix;
            tokenIds[parentHandleWithSuffix] = tokenId;

            // Handle payment if it's a paid mint
            if (!isWhitelistedUser) {
                // Transfer the registration fee directly to the feeRecipient address
                payable(feeRecipient).transfer(msg.value);
            }

            emit HandleRegistered(
                msg.sender,
                parentHandleWithSuffix,
                newHandle.expirationTimestamp,
                tokenId
            );

            // Check if the handle was expired and claimed
            if (isExpired) {

            }
        } else {
            revert("Handle already registered and not expired");
        }
    }

    function mintSubhandle(
        string memory subhandleAndParent,
        uint256 registrationYears
    ) external payable validMainPart(subhandleAndParent) validHyphenAndDot(subhandleAndParent) {
        string memory subhandleName = StringUtil.subhandlePart(subhandleAndParent);

        string memory parentHandleWithSuffix = string(abi.encodePacked(StringUtil.parentPart(subhandleAndParent), ".", string(HANDLE_SUFFIX)));
        Handle storage parentHandle = handles[parentHandleWithSuffix];
        Subhandle storage subhandle = parentHandle.subhandles[subhandleName];

        bool isParentExpired = (parentHandle.expirationTimestamp <= block.timestamp);
        bool isSubhandleExpired = (subhandle.tokenId != 0 && subhandle.expirationTimestamp <= block.timestamp);

        require(!isParentExpired, "Parent handle is expired");
        require(subhandle.tokenId == 0 || isSubhandleExpired, "Subhandle already registered and not expired");

        uint256 characterCount = bytes(subhandleName).length;
        uint256 registrationFee = calculateSubhandleFee(characterCount, registrationYears);

        bool isParentOwner = (msg.sender == parentHandle.parentOwner);
        if (!isParentOwner) {
            require(msg.value >= registrationFee, "Insufficient registration fee");
            address payable parentOwner = payable(parentHandle.parentOwner);
            parentOwner.transfer(msg.value);
        }

        require(!subhandle.requested, "Subhandle request is pending");
        require(
            isPermissionEnabled(parentHandleWithSuffix, parentHandle.parentOwner) || isParentOwner,
            "Permission not granted"
        );

        require(
            !isParentOwner || registrationYears <= 1,
            "Maximum registration years for parent handle owner is 1"
        );

        // Burn expired subhandle if applicable
        if (isSubhandleExpired) {
            burnSubhandle(subhandleAndParent); // Burn the expired token
        }

        // Check for consecutive hyphens
        require(
            !StringUtil.hasConsecutiveHyphens(subhandleName) || StringUtil.hasValidPrefix(subhandleName),
            "Subhandle cannot contain consecutive hyphens"
        );

        // Generate a new token ID for the claimed subhandle
        uint256 tokenId = _totalSupply + 1;
        _totalSupply += 1;
        _mint(msg.sender, tokenId);

        subhandle.tokenId = tokenId;
        subhandle.owner = msg.sender;
        subhandle.requested = false;
        subhandle.expirationTimestamp = block.timestamp + (ONE_YEAR_IN_SECONDS * registrationYears);
        subhandle.registrationYears = registrationYears;

        parentHandle.subhandleCount += 1;

        string memory subhandleWithSuffix = string(abi.encodePacked(subhandleName, ".", parentHandleWithSuffix));
        handleNames[tokenId] = subhandleWithSuffix;
        tokenIds[subhandleWithSuffix] = tokenId;

        uint256 expirationTimestamp = subhandle.expirationTimestamp;
        emit SubhandleRegistered(
            msg.sender,
            subhandleWithSuffix,
            parentHandleWithSuffix,
            parentHandle.parentOwner,
            expirationTimestamp,
            tokenId
        );
    }

    function renewHandle(string memory handleName, uint256 additionalYears) external payable { 
        string memory parentHandleWithSuffix = string(abi.encodePacked(handleName, ".", string(HANDLE_SUFFIX)));
        
        uint256 characterCount = bytes(handleName).length;
        uint256 renewalFee = calculateHandleFee(characterCount, additionalYears);
        require(msg.value >= renewalFee, "Insufficient fee");

        Handle storage handle = handles[parentHandleWithSuffix];
        require(handle.tokenId != 0, "Handle not registered");

        // Check if the parent handle is expired
        require(handle.expirationTimestamp > block.timestamp, "Handle has expired, claim this handle using the mint function.");

        // Update expiration
        handle.expirationTimestamp += additionalYears * ONE_YEAR_IN_SECONDS;

        // Transfer fee
        payable(feeRecipient).transfer(msg.value);

        uint256 tokenId = handle.tokenId;

        // Emit event
        emit HandleRenewed(
            msg.sender, //renewedBy
            ownerOf(handle.tokenId),
            parentHandleWithSuffix,
            handle.expirationTimestamp,
            tokenId
        );
    }

    function renewSubhandle(
        string memory subhandleAndParent,
        uint256 additionalYears
    ) external payable {
        require(additionalYears > 0, "Invalid additional years");

        // Similar to the original code, get subhandle and parent handle names
        string memory subhandleName = StringUtil.subhandlePart(subhandleAndParent);
        string memory parentHandleWithSuffix = string(abi.encodePacked(StringUtil.parentPart(subhandleAndParent), ".", string(HANDLE_SUFFIX)));

        // Check if subhandle and parent handle names are valid
        require(bytes(subhandleName).length > 0 && bytes(parentHandleWithSuffix).length > 0, "Invalid subhandle and parent handle");
        require(handles[parentHandleWithSuffix].tokenId != 0, "Parent handle not registered");

        // Get the subhandle struct
        Subhandle storage subhandle = handles[parentHandleWithSuffix].subhandles[subhandleName];
        require(subhandle.tokenId != 0, "Subhandle not registered");

        // Check if the subhandle is expired
        require(subhandle.expirationTimestamp > block.timestamp, "Subhandle has expired, claim this subhandle using the mint function");

        // Calculate the renewal fee for the entire renewal period
        uint256 characterCount = bytes(subhandleName).length;
        uint256 renewalFee = calculateSubhandleFee(characterCount, additionalYears);

        // Check if the caller is not the owner of the parent handle
        bool isParentOwner = (msg.sender == handles[parentHandleWithSuffix].parentOwner);
        if (!isParentOwner) {
            require(msg.value >= renewalFee, "Insufficient renewal fee");

            // Transfer the total renewal fee to the parent handle owner
            address payable parentOwner = payable(handles[parentHandleWithSuffix].parentOwner);
            parentOwner.transfer(msg.value);
        }

        require(
            !isParentOwner || additionalYears <= 1,
            "Maximum renewal years for parent handle owner is 1"
        );

        // Extend the expiration timestamp of the subhandle for the entire renewal period
        subhandle.expirationTimestamp += ONE_YEAR_IN_SECONDS * additionalYears;

        uint256 tokenId = subhandle.tokenId;

        // Update handle and subhandle name mappings with suffix
        string memory subhandleWithSuffix = string(abi.encodePacked(subhandleName, ".", parentHandleWithSuffix));
        handleNames[subhandle.tokenId] = subhandleWithSuffix;
        tokenIds[subhandleWithSuffix] = subhandle.tokenId;
        tokenIds[subhandleWithSuffix] = tokenId;

        emit SubhandleRenewed(
            msg.sender, //renewedBy
            ownerOf(subhandle.tokenId),
            subhandleWithSuffix,
            parentHandleWithSuffix,
            handles[parentHandleWithSuffix].parentOwner,
            subhandle.expirationTimestamp,
            tokenId
        );
    }

    function setBitcoinAddressForHandle(string memory handleName, string memory bitcoinAddress) external {

        address sender = msg.sender;

        // Form the full handle name with suffix
        string memory handleWithSuffix = string(abi.encodePacked(handleName, ".", string(HANDLE_SUFFIX)));

        // Access the handle struct
        Handle storage handle = handles[handleWithSuffix];

        // Validate handle existence
        require(handle.tokenId != 0, "Handle does not exist");

        // Validate ownership
        require(sender == ownerOf(handle.tokenId), "Only the current owner can set the Bitcoin address");

        // Check handle expiration
        require(handle.expirationTimestamp > block.timestamp, "Handle has expired");

        // Update the Bitcoin address for the handle
        handle.bitcoinAddress = bitcoinAddress;

        // Emit an event to reflect the update
        string memory parentHandleWithSuffix = string(abi.encodePacked(handleName, ".", string(HANDLE_SUFFIX)));
        uint256 tokenId = handle.tokenId;
        emit BtcAddressHandleSet(sender, parentHandleWithSuffix, bitcoinAddress, tokenId);
    }

    function setBitcoinAddressForSubhandle(string memory subhandleAndParent, string memory bitcoinAddress) external {

        string memory parentHandleWithSuffix = string(abi.encodePacked(StringUtil.parentPart(subhandleAndParent), ".", string(HANDLE_SUFFIX)));
        string memory subhandleName = StringUtil.subhandlePart(subhandleAndParent);

        // Validate parent handle existence
        require(handles[parentHandleWithSuffix].tokenId != 0, "Parent handle does not exist");

        // Validate subhandle existence and expiration
        Subhandle storage subhandle = handles[parentHandleWithSuffix].subhandles[subhandleName];
        require(subhandle.tokenId != 0, "Subhandle does not exist");
        require(subhandle.expirationTimestamp > block.timestamp, "Subhandle has expired");

        // Validate ownership
        require(msg.sender == ownerOf(subhandle.tokenId), "You must be the owner of the subhandle to set the Bitcoin address");

        subhandle.bitcoinAddress = bitcoinAddress;
        string memory subhandleWithSuffix = string(abi.encodePacked(subhandleName, ".", parentHandleWithSuffix));
        uint256 tokenId = subhandle.tokenId;

        emit BtcAddressSubhandleSet(msg.sender, subhandleWithSuffix, bitcoinAddress, tokenId);
    }

   enum TransferType {
        PARENT,
        SUBHANDLE
    }

    function safeTransferFrom( 
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        TransferType transferType;

        if (parentTokenIds[tokenId] != 0) {
            transferType = TransferType.SUBHANDLE;
        } else {
            transferType = TransferType.PARENT;
        }

        if (transferType == TransferType.PARENT) {
            Handle storage handle = handles[handleNames[tokenId]];
            address currentOwner = handle.parentOwner;
            require(currentOwner != to, "New owner is same as current owner");
            handle.parentOwner = to;

            emit HandleTransferred(
                from,
                handleNames[tokenId],
                to,
                tokenId
            );
        } else if (transferType == TransferType.SUBHANDLE) {
            Subhandle storage subhandle = handles[handleNames[parentTokenIds[tokenId]]].subhandles[StringUtil.subhandlePart(handleNames[tokenId])];
            address currentOwner = subhandle.owner;
            require(currentOwner != to, "New owner is same as current owner");
            subhandle.owner = to;

            emit HandleTransferred(
                subhandle.owner, 
                StringUtil.subhandlePart(handleNames[tokenId]),
                to,
                tokenId
            );

        }

        super.safeTransferFrom(from, to, tokenId, _data);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        TransferType transferType;

        if (parentTokenIds[tokenId] != 0) {
            transferType = TransferType.SUBHANDLE;
        } else {
            transferType = TransferType.PARENT;
        }

        if (transferType == TransferType.PARENT) {
            Handle storage handle = handles[handleNames[tokenId]];
            address currentOwner = handle.parentOwner;
            require(currentOwner != to, "New owner is same as current owner");
            handle.parentOwner = to;

            emit HandleTransferred(
                from,
                handleNames[tokenId],
                to,
                tokenId
            );
        } else if (transferType == TransferType.SUBHANDLE) {
            Subhandle storage subhandle = handles[handleNames[parentTokenIds[tokenId]]].subhandles[StringUtil.subhandlePart(handleNames[tokenId])];
            address currentOwner = subhandle.owner;
            require(currentOwner != to, "New owner is same as current owner");
            subhandle.owner = to;

            emit HandleTransferred(
                subhandle.owner,
                StringUtil.subhandlePart(handleNames[tokenId]),
                to,
                tokenId
            );
        }

        super.transferFrom(from, to, tokenId);
    }

    function getHandleInfo(string memory handleName) external view returns (HandleInfo memory) {
        string memory parentHandleWithSuffix = string(abi.encodePacked(handleName, ".", string(HANDLE_SUFFIX)));
        Handle storage handle = handles[parentHandleWithSuffix];
        
        require(handle.tokenId != 0, "Handle token does not exist");
        
        address currentOwner = ownerOf(handle.tokenId);
        
        return HandleInfo(
            handle.tokenId,
            currentOwner,
            handle.expirationTimestamp,
            handle.subhandleCount,
            handle.bitcoinAddress
        );
    }

    function getSubhandleInfo(string memory subhandleAndParent) external view returns (SubhandleInfo memory) {
        (string memory subhandleName, string memory parentHandleName) = StringUtil.splitCombinedHandleName(subhandleAndParent);
        string memory parentHandleWithSuffix = string(abi.encodePacked(parentHandleName, ".", string(HANDLE_SUFFIX)));
        Subhandle storage subhandle = handles[parentHandleWithSuffix].subhandles[subhandleName];
        
        require(subhandle.tokenId != 0, "Subhandle token does not exist");
        
        address subhandleOwner = ownerOf(subhandle.tokenId);
        address parentHandleOwner = ownerOf(handles[parentHandleWithSuffix].tokenId);

        return SubhandleInfo(
            subhandle.tokenId,
            subhandleOwner,
            subhandle.expirationTimestamp,
            parentHandleOwner,
            subhandle.bitcoinAddress
        );
    }

}
