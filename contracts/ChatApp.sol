//SPDX-License-Identifier: MIT
pragma solidity >=0.4.5 <0.9.0;

/*
Documentation Manual:
1. ERH: Error Handling
2. CK: Check condition
* master user: who will create account = msg.sender
 */

/* structs  */
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

    struct AllUserStruck {
        string name;
        address accountAddress;
    }

    // array of type 'AllUserStruck' struct type
    AllUserStruck[] getAllUsers;

    mapping(address => user) userList;
    mapping(bytes32 => message[]) allMessages;

    //* friend request list
    // here stores all user who makes request as friend
    mapping(address => user[]) FriendRequestList;

    //* friend list
    // every request that accpted will become friend
    mapping(address => friend[]) addedFriend;

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

        getAllUsers.push(AllUserStruck(_name, msg.sender));
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
        require(
            isFriendRequestAccepted(msg.sender, friend_key) == true,
            "The friend request is denied"
        );

        // user adding a friend into friendlist
        _addFriend(msg.sender, friend_key, name);
        // friend need to add up user as friend into friendlist
        _addFriend(friend_key, msg.sender, userList[msg.sender].name);
    }

    // CHECK friend is already exists in the friendlist
    //* Way 01
    function checkAlreadyFriend(address user_key, address friend_key)
        internal
        view
        returns (bool)
    {
        // Cache the length of both user_key and friend_key
        uint256 len1 = userList[user_key].friendList.length;
        uint256 len2 = userList[friend_key].friendList.length;

        // compares lengths to determine which list is shorter
        // iterate through shorter loop will optimize gas cost
        if (len1 > len2) {
            (user_key, friend_key) = (friend_key, user_key);
        }

        for (uint256 i = 0; i < len1; i++) {
            if (userList[user_key].friendList[i].pubkey == friend_key) {
                return true;
            }
        }

        return false;
    }

    //* Way 02
    /*     function checkAlreadyFriend(address user_key, address friend_key) internal view returns (bool) {
                friend[] memory friends = userList[user_key].friendList;
                uint256 len = friends.length;

                for (uint256 i = 0; i < len; i++) {
                    if (friends[i].pubkey == friend_key) {
                        return true;
                    }
                }

                return false;
            } */

    // CHECK whether friend request accepted or not
    // priviledged to friend; friend can either reject or approve the friend request

    /*     function isFriendRequestAccepted(
            address _friendAddress,
            address _userAddress
        ) public returns (bool) {

            uint256 AddedFriendList = addedFriend[_friendAddress].length;

            for(uint256 i = 0; i <; i++)  {
                if(addedFriend[_userAddress].pubkey == _userAddress) return true;
            }
            else false;
        }
    */

    // function that will add a friend
    function _addFriend(
        address me,
        address friend_key,
        string memory name
    ) internal {
        friend memory newFriend = friend(friend_key, name);
        userList[me].friendList.push(newFriend);
    }

    function getMyFriendList() external view returns (friend[] memory) {
        return userList[msg.sender].friendList;
    }

    function _getChatCode(address pubkey1, address pubkey2)
        internal
        pure
        returns (bytes32)
    {
        if (pubkey1 < pubkey2) {
            return keccak256(abi.encodePacked(pubkey1, pubkey2));
        } else return keccak256((abi.encodePacked(pubkey1, pubkey2)));
    }

    // following function will let user send messages to others users
    function sendMessage(address friend_key, string calldata _msg) external {
        // the master user must be existed
        require(checkUserExists(msg.sender), "Create an account first");

        // CK: whether the friend exists
        require(checkUserExists(friend_key), "User not yet registered");

        // CK: whether they already friend or not
        // no reason to send friend requests if already are friends
        require(checkAlreadyFriend(msg.sender, friend_key));

        // chatCode requires to store messages
        bytes32 chatCode = _getChatCode(msg.sender, friend_key);

        // message we want to send
        message memory newMsg = message(msg.sender, block.timestamp);

        // storing all the messages
        allMessages[chatCode].push(newMsg);
    }

    // Read messages
    function readMessage(address friend_key)
        external
        view
        returns (message[] memory)
    {
        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        return allMessages[chatCode];
    }

    // function that can fetch all registered users
    function getAllAppUser() public view returns (AllUserStruck[] memory) {
        return getAllUsers;
    }
}
