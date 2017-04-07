pragma solidity ^0.4.2;


contract Notebook {

    address owner;

    //mappings for addresses with two levels of access
    mapping (address => bool) readOnlyRegistry;
    mapping (address => bool) fullAccessRegistry;

    function isReadOnlyUser(address _addr) constant returns (bool) {
        return readOnlyRegistry[_addr];
    }

    function isFullAccessUser(address _addr) constant returns (bool) {
        return fullAccessRegistry[_addr];
    }


    //modifier restriction for read only users
    modifier readOnly(address _addr) {
        if (_addr == owner) {
            _;
        }
        else if (isReadOnlyUser(_addr)) {
            _;
        }
        else throw;
    }

    //modifier restriction for full access users
    modifier fullAccess(address _addr) {
        if (_addr == owner) {
            _;
        }
        else if (isFullAccessUser(_addr)) {
            _;
        }
        else throw;
    }

    //add address eligible for read operations
    function addReadOnlyUser(address _addr) fullAccess(msg.sender) {

        readOnlyRegistry[_addr] = true;
    }

    //add address eligible for all operations
    function addFullAccessUser(address _addr) fullAccess(msg.sender) {

        readOnlyRegistry[_addr] = true;
        fullAccessRegistry[_addr] = true;
    }


    function checkUser(address _addr) constant returns (string result) {

        if (isFullAccessUser(_addr)) {
            return "Full Access";
        }
        else if (isReadOnlyUser(_addr)) {
            return "Read Only";
        }
        else return "This user has no access";

    }


    //set owner in a constructor
    function Notebook() {
        owner = msg.sender;
    }



    //our list of notes
    bytes32[] notes;

    

    //---------CRUD operations with notes----------
    
    function getNumberOfNotes() readOnly(msg.sender) constant returns (uint){
        return notes.length;
    }

    function addNote(bytes32 text) fullAccess(msg.sender) returns (bool success)  {
        notes.push(text);
        return true;
    }

    function deleteNote(uint index) fullAccess(msg.sender) returns (bool success) {
        if (index < 0 || index >= notes.length) return false;

        for (uint i = index; i < notes.length-1; i++) {
            notes[i] = notes[i+1];
        }

        delete notes[notes.length-1];
        notes.length--;
        return true;

        if (notes.length < 0) notes.length = 0;
    }

    function editNote(uint index, bytes32 text) fullAccess(msg.sender) returns (bool success) {
        if (index < 0 || index >= notes.length) return false;

        notes[index] = text;
        return true;
    }

    function getAllNotes() readOnly(msg.sender) constant returns(bytes32[]) {
        return notes;
  }

}
