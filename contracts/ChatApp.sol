//SPDX-License-Identifier: MIT
pragma solidity >=0.4.5 <0.9.0;

/*
Documentation Manual:
1. ERH: Error Handling
2. CK: Check condition
3. 

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

    // CK: Whether the user already exist
    function checkUserExists(address _pubkey) public view returns (bool) {
        // return bytes(userList[_pubkey].name).length > 0; // this code may cost more gas
        return userList[_pubkey].isExists;
    }

    // CREATE: new user account
    function createAccount(string calldata _name) external {
        // whthere it is a new user or an existing user
        require(
            checkUserExists(msg.sender) == false,
            "User already exists, sign in to your account"
        );
        // ERH: empty names
        require(
            bytes(_name).length > 0,
            "Username must contain atleast 2 characters"
        );

        userList[msg.sender].name = _name;
    }

    // GET username
    function getUserName(address _pubkey)
        external
        view
        returns (string memory)
    {
        // whether the address exists or not
        require(
            checkUserExists(_pubkey) == true,
            "User dont' belongs to the contract, register now!!"
        );

        return userList[_pubkey].name;
    }

    // ADD friends to friendlist
    function addFriend(address friend_key, string calldata name) external {
        // already a user or not
        require(checkUserExists(msg.sender), "Create an account first");
        // CK: whether or not friend_key has account
        require(checkUserExists(friend_key), "User is not registerd yet");
        // CK: the friend already exists in the friendlist
        require(
            checkAlreadyFriend(msg.sender, friend_key) == false,
            "These users are already friends"
        );
        require(msg.sender != friend_key, "Can't add yourself as a friend");

        // CK: friend request approval
        require(isFriendRequestAccepted(msg.sender, friend_key, name) == true, "The friend request is denied");
        // user adding a friend into friendlist
        _addFriend(msg.sender, friend_key, name);
        // friend need to add up user as friend into friendlist
        _addFriend(friend_key, msg.sender, userList[msg.sender].name);
    }

    function checkAlreadyFriend() {}
    function isFriendRequestAccepted returns(bool){}
    function _addFriend();
}
