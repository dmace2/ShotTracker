var gamesClassList = [];
var addGameReference = document.getElementById("creategame");
var deleteButtonList;
var cellList;
var numNewDiv = 0;

firebase.auth().onAuthStateChanged(function(user){
  if(user){
    getCurrentFBGames();
  }
  else{
    alert("You are not logged in! Please log in!");
    window.location.replace('/login');
  }

}); //auth check end



function getCurrentFBGames(){
  firebase.auth().onAuthStateChanged(function(user){
    if(user){
      uid = user.uid;

      //gets current games
      var database = firebase.database();
      var gameRef = database.ref('games');
      gameRef.child(uid).once("value").then(function(snapshot) { //this is a promise, so it is asynchronous
        snapshot.forEach(function(childSnapshot) {
          var childData = childSnapshot.val();
          addGameLocally(childData.gameNickname,childData.gameDate, childData.gameFBLabel); //create a local div here
          var gameModel = new GameModel(childData.gameDate, childData.gameNickname, childData.gameFBLabel);
          gamesClassList.push(gameModel); //append to an array of games

        });//snapshot end
        getCurrentDeleteButtons(); //add event listeners to all buttons
        getCurrentCells();
      }); //get data end (end of promise)

    } //log in check end

  }); //auth check end

}



function addGameLocally(title,date,fblabel){
  var tableLoc = document.getElementById("table");
  var tableRow = document.createElement("div");
  tableRow.className = "row clickable " + fblabel;
  tableRow.id = numNewDiv;
  var tablecellTitle = document.createElement("div");
  tablecellTitle.className="cell";
  tablecellTitle.dataTitle="Game Title";
  tablecellTitle.innerHTML = title;

  var tablecellDate = document.createElement("div");
  tablecellDate.className="cell";
  tablecellDate.dataTitle="Game Date";
  tablecellDate.innerHTML = date;

  var tablecellDelete = document.createElement("div");
  tablecellDelete.className="cell deleteButton";
  var innerDeleteButton = document.createElement("i");
  innerDeleteButton.id = numNewDiv;
  innerDeleteButton.className = "fa fa-trash-o delete";
  tablecellDelete.appendChild(innerDeleteButton);



  tableRow.appendChild(tablecellTitle);
  tableRow.appendChild(tablecellDate);
  tableRow.appendChild(tablecellDelete);
  tableLoc.appendChild(tableRow);

  numNewDiv += 1;
}


addGameReference.addEventListener("click",addGameFirebase);
function addGameFirebase(){
  var gameTitle;
  var gameDate;

  gameTitle = prompt("Please enter a title:", "Default Game Title");
  if (gameTitle != null || gameTitle != "Default Game Title" || gameTitle != "") {
    var utc = new Date().toJSON();
    var longDate = utc.slice(0,19)+"Z";
    var gameDate = longDate.slice(0,10);
    addGameLocally(gameTitle, gameDate,longDate); //create a local div
    var gameModel = new GameModel(gameDate, gameTitle, longDate); //make a new model for list
    gamesClassList.push(gameModel); //append to an array of games

    firebase.auth().onAuthStateChanged(function(user){
      if(user){
        uid = user.uid;
        firebase.database().ref('games').child(uid).child(longDate).set({
          gameDate: gameDate,
          gameFBLabel: longDate,
          gameNickname: gameTitle
        });
      }//user check end
      deleteButtonList = document.querySelectorAll("i.fa.fa-trash-o.delete"); //gets all icons on page //refresh my delete button list since I removed an old row
      addButtonEventListeners(deleteButtonList[deleteButtonList.length - 1]); //gets all icons on page //refresh my delete button list since I added a new row
      cellList = document.querySelectorAll("div.clickable"); //gets all icons on page //refresh my delete button list since I removed an old row
      addCellEventListener(cellList[cellList.length - 1]);
    }); //auth check end

  } //if not null check
}

function removeGameFirebase(toBeDeleted){
  var dateToBeRemoved = gamesClassList[toBeDeleted].gameFBLabel;
  firebase.auth().onAuthStateChanged(function(user){if(user){
    firebase.database().ref('games').child(user.uid).child(dateToBeRemoved).remove(); //remove data from fb
    var numGames = gamesClassList.length;
    var tempArray = []
    for(i = 0; i < numGames; i += 1){
      if(i == toBeDeleted){
        continue;
      }
      tempArray.push(gamesClassList[i]);
    }
    gamesClassList = tempArray;
  }});

}


function removeGame(row){ //the problem is the id's don't change when you remove a row, so i need a dif way to check the row
var toBeDeleted;
var trashCans = document.getElementsByClassName('fa-trash-o'); //gets all rows
for(i = 0; i < trashCans.length; i++){ //iterate through games
  if(trashCans[i].id == row.id){ //check if equal
    toBeDeleted = i;
    break;
  }
}
var tableRows = document.getElementsByClassName('clickable'); //gets all rows
var element = tableRows[toBeDeleted]; //row to be deleted
element.remove(); //removes element from page

removeGameFirebase(toBeDeleted);
}

function getCurrentDeleteButtons(){
  deleteButtonList = document.querySelectorAll("i.fa.fa-trash-o.delete"); //gets all icons on page
  deleteButtonList.forEach( btn => {
    addButtonEventListeners(btn);
  });
}
function addButtonEventListeners(btn){
  btn.addEventListener('click', function(event){
    var target = event.target || event.srcElement; //gets target button
    removeGame(target);
  });
}

function getCurrentCells(){
  cellList = document.querySelectorAll("div.clickable");
  cellList.forEach (cell => {
    addCellEventListener(cell);
  });
}
function addCellEventListener(cell){
  cell.addEventListener("click", function(event){
    var target = event.target || event.srcElement; //gets target button
    if(target.className != "cell deleteButton"){
      selectAGame(target);
    }
  })
}

function selectAGame(target){
  if(target.className != "fa fa-trash-o delete"){
    var row = target.parentNode;
    var gameFBLabelClicked = row.className.slice(14,34);
    let uid = firebase.auth().currentUser.uid;
    var database = firebase.database();
    let lastSelectedRef = database.ref('games/lastGameClickedList/' + uid);
    lastSelectedRef.child("lastSelectedGame").set(gameFBLabelClicked,function(error){
      if(error){

      }
      else {
        console.log("data written successfully");
        sendTokenToServer();
      }
    });
  }
}

function sendTokenToServer(){
  firebase.auth().currentUser.getIdToken(/* forceRefresh */ true).then(function(idToken) {
    // Send token to your backend via HTTPS
    // ...
    document.location.href = "/fbshot?token=" + idToken;

  }).catch(function(error) {
    // Handle error
  });
}
