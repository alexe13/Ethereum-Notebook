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
        notes.push(Note("All systems go!", 0));
    }


    //basic structure for notes
    struct Note {
    string value;
    uint id;
    }


    //our list of notes
    Note[] notes;

    uint numberOfNotes = 0;

    //---------CRUD operations with notes----------

    function getNumberOfNotes() readOnly(msg.sender) constant returns(uint number) {
        return notes.length;
    }

    function addNote(string text) fullAccess(msg.sender) returns (bool success)  {
        notes.push(Note(text, numberOfNotes));
        numberOfNotes = notes.length;
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

    function editNote(uint index, string text) fullAccess(msg.sender) returns (bool success) {
        if (index < 0 || index >= notes.length) return false;

        notes[index].value = text;
        return true;
    }

    function getNote(uint index) readOnly(msg.sender) constant returns (string, uint) {
        if (index < 0 || index >= notes.length) throw;
        Note thisNote = notes[index];
        return (thisNote.value, thisNote.id);
    }

}

