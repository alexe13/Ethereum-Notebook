pragma solidity ^0.4.2;


contract Notebook {

    address owner;
    uint numberOfNotes;


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
        numberOfNotes = notes.length;
    }


    //basic structure for notes
    struct Note {
    bytes32 value;
    uint id;
    }


    //our list of notes
    Note[] notes;

    

    //---------CRUD operations with notes----------

    function getNumberOfNotes() readOnly(msg.sender) constant returns(uint number) {
        return notes.length;
    }

    function addNote(bytes32 text) fullAccess(msg.sender) returns (bool success)  {
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

    function editNote(uint index, bytes32 text) fullAccess(msg.sender) returns (bool success) {
        if (index < 0 || index >= notes.length) return false;

        notes[index].value = text;
        return true;
    }

    function getAllNotes() constant returns(bytes32[], uint[]) {
    uint length = notes.length;

    bytes32[] memory values = new bytes32[](length);
    uint[] memory ids = new uint[](length);

    for (uint i = 0; i < length; i++) {
      Note memory currentNote;
      currentNote = notes[i];

      values[i] = currentNote.value;
      ids[i] = currentNote.id;
    }

    return (values, ids);
  }

}
