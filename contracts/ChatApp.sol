//SPDX-License-Identifier: MIT
pragma solidity >=0.4.5 <0.9.0;

/* 
Documentation Manual:

 */
contract chatApp {
    // 'user' struct
    struct user {
        string name;
        friend[] friendList;
        bool isExists;
    }

    // 'friend' struct
    struct friend {
        address pubkey;
        string name;
    }

    struct message {
        address msgSender;
        uint256 timestamp;
    }

    mapping(address => user) userList;
    mapping(bytes32 => message[]) allMessages;

    // CHECK: Whether the user already exist
    function checkUserExists(address _pubkey) public view returns (bool) {
        // return bytes(userList[_pubkey].name).length > 0; // this code may cost more gas
        return userList[_pubkey].isExists;
    }

    // CREATE: new user account
    function createAccount(string calldata name) external {
        // whthere it is a new user or an existing user
        require(
            checkUserExists(msg.sender) == false,
            "User already exists, sign in to your account"
        );
        // ERROR HANDLING: empty names
    }
}
