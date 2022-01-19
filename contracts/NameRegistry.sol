//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract NameRegistry {
    /**
     * note name to DID list
     */
    mapping(string => address) _nameToDID;
    mapping(address => string) _DIDToName;

    event Register(string indexed name, address indexed DID);
    event Unregister(string indexed name, address indexed DID);

    /**
     * @dev register name & DID
     * @param _name user name can be any string. Duplication not allowed
     * @param _did DID address.
     */
    function register(string memory _name, address _did) public {
        require(_did != address(0x0), "Invalid zero address");
        require(_nameToDID[_name] == address(0x0), "Name already registered");

        bytes memory _didname = bytes(_DIDToName[_did]);
        require(_didname.length == 0, "DID already registered");

        _nameToDID[_name] = _did;
        _DIDToName[_did] = _name;

        emit Register(_name, _did);
    }

    /**
     * @dev unregister name
     * @param _name user name. Must be registered before
     */
    function unregister(string memory _name) public {
        require(_nameToDID[_name] != address(0x0), "Unregistered name");
        
        address did = _nameToDID[_name];
        delete _DIDToName[did];
        delete _nameToDID[_name];

        emit Unregister(_name, did);
    }

    /**
     * @dev Find did for name
     * @param _name user name. Must be registered
     * @return DID address of user
     */
    function findDid(string memory _name) external view returns(address) {
        require(_nameToDID[_name] != address(0x0), "Unregistered name");
        return _nameToDID[_name];
    }

    /**
     * @dev Find name of DID
     * @param _did Must be registered before.
     * @return name
     */
    function findName(address _did) external view returns(string memory) {
        bytes memory _name = bytes(_DIDToName[_did]);
        require(_name.length != 0, "Unregistered DID");
        return _DIDToName[_did];
    }

}