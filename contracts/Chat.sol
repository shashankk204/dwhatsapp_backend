// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;


import "hardhat/console.sol";


contract chat
{
    // struct Friend
    // {
    //     string FriendName;
    //     address FriendPUBkey;
    // }
    struct User 
    {
        string UserName;
        address UserPUBKey;
        address[] FriendList;
    }
    struct Message
    {
        string Text;
        address sender;
        address receiver;
    }
    mapping (bytes32=>bool) internal NameTaken;
    mapping (address=>User) public ActiveUsers;
    mapping (bytes32=>Message[]) internal Allchat; 
    
    function CheckUser(address _UserPUBKey) internal view returns(bool)
    {
        if(ActiveUsers[_UserPUBKey].UserPUBKey==0x0000000000000000000000000000000000000000)
        {
            return false;           
        }
        else 
        {
            return true;
        }
    }

    function CreateNewUser(string calldata _UserName) external 
    {
        if(CheckUser(msg.sender)==true)
        {
            console.log("user already exists");
            revert();
        }
        if(NameTaken[keccak256(abi.encodePacked(_UserName))]==true)
        {
            console.log("name Already taken");
            revert();
        }
        ActiveUsers[msg.sender].UserPUBKey=msg.sender;
        ActiveUsers[msg.sender].UserName=_UserName;
        NameTaken[keccak256(abi.encodePacked(_UserName))]=true;


    }
    function Addfriend(address _NewFriendPUBKey) external 
    {
        if(CheckUser(msg.sender)==false || CheckUser(_NewFriendPUBKey)==false)
        {
            console.log("No user found");
            revert();
        }
        if(_NewFriendPUBKey==msg.sender)
        {
            console.log("can't be friend to self");
            revert();
        }
        // for(uint i=0;i<ActiveUsers[msg.sender].FriendList.length;i++)
        // {
        //     if(ActiveUsers[msg.sender].FriendList[i]==_NewFriendPUBKey)
        //     {
        //         console.log("already a friend");
        //         revert();
        //     }
        // }
        if(CheckFriend(_NewFriendPUBKey)==true)
        {
            console.log("already a friend");
            revert();
        }

        ActiveUsers[msg.sender].FriendList.push(_NewFriendPUBKey);
        ActiveUsers[_NewFriendPUBKey].FriendList.push(msg.sender);
    }

    function CheckFriend(address _Isfriend) internal view returns(bool) 
    {
        
        for(uint i=0;i<ActiveUsers[msg.sender].FriendList.length;i++)
        {
            if(ActiveUsers[msg.sender].FriendList[i]==_Isfriend)
            {
                return true;
            }
            
        }
        return false;
    }

    function allfriend() external view  returns(address[] memory)
    {
        return ActiveUsers[msg.sender].FriendList;
    }
    

    function SendMessage(string calldata _Message,address _Friend) external 
    {
        if(CheckUser(msg.sender)==false || CheckUser(_Friend)==false)
        {
            console.log("No accound found");
        }
        if(CheckFriend(_Friend)==false)
        {
            console.log("add to friend Fisrt");
            revert();
        }
        Allchat[KeyHash(msg.sender,_Friend)].push(Message(_Message,msg.sender,_Friend));
    }

    function KeyHash(address key1,address key2) internal pure returns(bytes32)
    {
        if(key1>key2)
        {
            return keccak256(abi.encodePacked(key2,key1));
        }
        else 
        {
            return keccak256(abi.encodePacked(key1,key2));
        }

    }
    function GetMessage(address _FriendPUBKey) public view returns(Message[] memory) 
    {
        if(CheckUser(msg.sender)==false || CheckUser(_FriendPUBKey)==false)
        {
            console.log("No accound found");
            revert();
        }
        if(CheckFriend(_FriendPUBKey)==false)
        {
            console.log("add to friend Fisrt");
            revert();
        }
        return Allchat[KeyHash(msg.sender,_FriendPUBKey)];
    }
}