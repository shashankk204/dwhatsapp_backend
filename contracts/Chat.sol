// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;




contract chat
{
    enum MessageType {
        text,photo,video
    }

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
        MessageType TypeOFMessage;
    }


    mapping (bytes32=>bool) private  NameTaken;
    mapping (address=>User) private  ActiveUsers;
    mapping (bytes32=>Message[]) private  Allchat;
    
    
    event NewMessage(address indexed sender,address indexed receiver);


    function CheckUser(address _UserPUBKey) public view returns(bool)
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
        
        require(CheckUser(msg.sender)==false,"user already exists");
        require(NameTaken[keccak256(abi.encodePacked(_UserName))]==false,"name Already taken");
        


        ActiveUsers[msg.sender].UserPUBKey=msg.sender;
        ActiveUsers[msg.sender].UserName=_UserName;
        NameTaken[keccak256(abi.encodePacked(_UserName))]=true;


    }
    
    function Addfriend(address _NewFriendPUBKey) external 
    {
        
        require(CheckUser(msg.sender)==true && CheckUser(_NewFriendPUBKey)==true,"No user found");
        require(_NewFriendPUBKey!=msg.sender,"can't be friend to self");
        require(CheckFriend(_NewFriendPUBKey)==false,"already a friend");



        ActiveUsers[msg.sender].FriendList.push(_NewFriendPUBKey);
        ActiveUsers[_NewFriendPUBKey].FriendList.push(msg.sender);
    }

    function CheckFriend(address _Isfriend) private view returns(bool) 
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
    

    function SendMessage(string calldata _Message,address _Friend,MessageType _type) external 
    {
        require(CheckUser(msg.sender)==true && CheckUser(_Friend)==true,"No accound found");
        require(CheckFriend(_Friend)==true,"add to friend Fisrt");
        
        
        Allchat[KeyHash(msg.sender,_Friend)].push(Message(_Message,msg.sender,_Friend,_type));
        emit NewMessage(msg.sender, _Friend);
    }

    function KeyHash(address key1,address key2) private pure returns(bytes32)
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
    function GetMessage(address _FriendPUBKey) public view  returns(Message[] memory) 
    {
        require(CheckUser(msg.sender)==true && CheckUser(_FriendPUBKey)==true,"No accound found");
        require(CheckFriend(_FriendPUBKey)==true,"add to friend Fisrt");

        return Allchat[KeyHash(msg.sender,_FriendPUBKey)];
    }
    function GetUserName(address _User) view public returns(string memory)
    {
        require(CheckUser(_User),"No user Found");
        
        
        return  ActiveUsers[_User].UserName;
    }
    
}

