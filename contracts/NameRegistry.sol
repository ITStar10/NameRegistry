//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NameRegistry is ReentrancyGuard {
    /**
     * note list to keep username & DIDs
     * _nameInfoList : username => UserNameInfo
     * _DIDToName : DID address => username
     */
    mapping(string => UserNameInfo) private _nameInfoList;
    mapping(address => string) private _DIDToName;

    /** note user need to fund ether to register. Will get  back when unregister.*/
    uint256 private constant REGISTER_COST = 0.01 ether;
    
    /** @dev Info of username */
    struct UserNameInfo {
        address owner;
        address dID;
        uint256 fund;
    }

    event Register(string indexed name, address indexed DID);
    event Unregister(string indexed name, address indexed DID);

    // Function to receive Ether. msg.data must be empty
    // receive() external payable {}

    // // Fallback function is called when msg.data is not empty
    // fallback() external payable {}

    /**
     * @dev register name & DID
     * @param _name user name can be any string. Duplication not allowed
     * @param _did DID address.
     */
    function register(string memory _name, address _did) public payable {
        require(msg.value >= REGISTER_COST, "Insufficient fund");
        require(_did != address(0x0), "Invalid zero address");
        require(_nameInfoList[_name].dID == address(0x0), "Name already registered");

        bytes memory _didname = bytes(_DIDToName[_did]);
        require(_didname.length == 0, "DID already registered");

        _nameInfoList[_name] = UserNameInfo(
            msg.sender,
            _did,
            msg.value
        );
        _DIDToName[_did] = _name;

        emit Register(_name, _did);
    }

    /**
     * @dev unregister name
     * @param _name user name. Must be registered before
     */
    function unregister(string memory _name) public payable nonReentrant {
        UserNameInfo memory info = _nameInfoList[_name];

        require(info.dID != address(0x0), "Unregistered name");
        require(info.owner == msg.sender, "Not a owner");
        
        delete _DIDToName[info.dID];
        delete _nameInfoList[_name];

        if (info.fund > 0) {
            (bool success,) = msg.sender.call{value:info.fund}(new bytes(0));
            require(success, "Sending fund back failed");
        }
        
        emit Unregister(_name, info.dID);
    }

    /**
     * @dev Find did for name
     * @param _name user name. Must be registered
     * @return DID address of user
     */
    function findDid(string memory _name) external view returns(address) {
        UserNameInfo storage info = _nameInfoList[_name];
        require(info.dID != address(0x0), "Unregistered name");
        require(info.owner == msg.sender, "Not a owner");
        return info.dID;
    }

    /**
     * @dev Find name of DID
     * @param _did Must be registered before.
     * @return name
     */
    function findName(address _did) external view returns(string memory) {
        bytes memory _name = bytes(_DIDToName[_did]);
        require(_name.length != 0, "Unregistered DID");
        UserNameInfo storage info = _nameInfoList[_DIDToName[_did]];
        require(info.owner == msg.sender, "Not a owner");
        return _DIDToName[_did];
    }

}