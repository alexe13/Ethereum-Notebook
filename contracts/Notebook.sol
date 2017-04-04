pragma solidity ^0.4.2;


contract Notebook {

    address owner;

//basic structure for users authentificated to view and edit notes
    struct TrustedUser {
    bytes32 name;
    address addr;
    }

//mapping to check if address is trusted
    mapping (address => bool) isReadOnlyUser;
    mapping (address => bool) isFullAccessUser;


    //list of trusted users with two levels of access
    TrustedUser[] readOnlyUsers;
    TrustedUser[] fullAccessUsers;

    //modifier restriction for read only users
    modifier readOnly(address _addr) {
        if (_addr == owner) {
            _;
        }
        else if (isReadOnlyUser[_addr]) {
            _;
        }
        else throw;
    }

    //modifier restriction for full access users
    modifier fullAccess(address _addr) {
        if (_addr == owner) {
            _;
        }
        else if (isFullAccessUser[_addr]) {
            _;
        }
        else throw;
    }


    //set owner in a constructor
    function Notebook() {
        owner = msg.sender;
    }


    //basic structure for notes
    struct Note {
    string value;
    uint id;
    }


    //our list of notes
    Note[] notes;

    uint numberOfNotes = 0;

    function addNote(string text) fullAccess(msg.sender) returns (bool success)  {
        notes.push(Note(text, numberOfNotes));
        numberOfNotes = notes.length;
        return true;
    }

    function deleteNote(uint index) fullAccess(msg.sender) returns (bool success) {
        if (index < 0 || index >= notes.length) return;

        for (uint i = index; i < notes.length; i++) {
            notes[i] = notes[i+1];
        }

        notes.length--;
        return true;

        if (notes.length < 0) notes.length = 0;
    }

    function editNote(uint index, string text) fullAccess(msg.sender) returns (bool success) {
        if (index < 0 || index >= notes.length) return;

        notes[index].value = text;
    }

    function getNote(uint index) readOnly(msg.sender) constant returns (string, uint) {
        Note thisNote = notes[index];
        return (thisNote.value, thisNote.id);
    }

    function addReadOnlyUser(bytes32 _name, address _addr) fullAccess(msg.sender) {
        TrustedUser memory newUser;

        newUser.name = _name;
        newUser.addr = _addr;

        readOnlyUsers.push(newUser);
        isReadOnlyUser[_addr] = true;
    }

    function addFullAccessUser(bytes32 _name, address _addr) fullAccess(msg.sender) {
        TrustedUser memory newUser;

        newUser.name = _name;
        newUser.addr = _addr;

        readOnlyUsers.push(newUser);
        fullAccessUsers.push(newUser);
        isReadOnlyUser[_addr] = true;
        isFullAccessUser[_addr] = true;
    }

    function checkTrustedUser(address _addr) constant returns (bytes result) {

        if (isReadOnlyUser[_addr]) {
            return "Read Only";
        }
        else if (isFullAccessUser[_addr]) {
            return "Full Access";
        }
        else return "This user has no access";

    }

}
