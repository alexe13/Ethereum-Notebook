import "../stylesheets/app.css";
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'
import notebook_artifacts from '../../build/contracts/Notebook.json'

var Notebook = contract(notebook_artifacts);

var accounts;
var account;


window.App = {
  start: function() {
    var self = this;

    // Bootstrap the MetaCoin abstraction for Use.
    Notebook.setProvider(web3.currentProvider);

    // Get the initial account balance so it can be displayed.
    web3.eth.getAccounts(function(err, accs) {
      if (err != null) {
        alert("There was an error fetching your accounts.");
        return;
      }

      if (accs.length == 0) {
        alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
        return;
      }

      accounts = accs;
      account = accounts[0];

      self.refreshNotes();
    });
  },

   setStatus: function(message) {
    var status = document.getElementById("status");
    status.innerHTML = message;
  },

  refreshNotes : function() {
    var self = this;
    var Promise = require('bluebird');
    Notebook.deployed().then(function(instance) {
      return instance.getNumberOfNotes.call({from:account});
    }).then(function (value) {
      var numberOfNotes = value.valueOf();
      console.log('from refresh ' + numberOfNotes);

      var notesList = document.getElementById("notes");
      notesList.innerHTML = "";

      var notes = [];
      var i = 0;
      while (i < numberOfNotes-1) {
        Notebook.deployed().then(function(instance) {
          return instance.getNote.call(i, {from: account}).then(function (value) {
            var note = value.valueOf();
            console.log('note value from array ' + note);
            notesList.innerHTML += self.createNotesHtml(note);
          });
        });
        i++;
      }
    });
  },

   addNote : function() {
    var self = this;
    var text = document.getElementById("note_text").value;

    Notebook.deployed().then(function(instance) {
    return instance.addNote(text, {from:account});
    }).then(function() {
    self.refreshNotes();
    }).catch(function (e) {
      console.log(e);
     });
  },

  createNotesHtml : function(noteItem) {
    console.log('creating html');
    var notesHtml =
      "<br/>"
    + "<div class=\"note-item\">"
    +   "<p class=\"text-left\">" + noteItem[0] + "</p>"
    +   "<p class=\"text-right\">"
    +     "<button class=\"btn btn-default\" onClick=\"completeTodo("+noteItem[1].valueOf()+")\">Изменить</button>"
    +     "<button class=\"btn btn-default\" onClick=\"deleteTodo("+noteItem[1].valueOf()+")\">Удалить</button>"
    +   "</p>"
    + "</div>";
    return notesHtml;
  },

  sendCoin: function() {
    var self = this;

    var amount = parseInt(document.getElementById("amount").value);
    var receiver = document.getElementById("receiver").value;

    this.setStatus("Initiating transaction... (please wait)");

    var meta;
    MetaCoin.deployed().then(function(instance) {
      meta = instance;
      return meta.sendCoin(receiver, amount, {from: account});
    }).then(function() {
      self.setStatus("Transaction complete!");
      self.refreshBalance();
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error sending coin; see log.");
    });
  }
};

window.addEventListener('load', function() {
  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    console.warn("Using web3 detected from external source. If you find that your accounts don't appear or you have 0 MetaCoin, ensure you've configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask")
    // Use Mist/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider);
  } else {
    console.warn("No web3 detected. Falling back to http://localhost:8545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  }

  App.start();
});

