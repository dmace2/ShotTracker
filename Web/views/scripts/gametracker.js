var outcomeButtons = document.querySelectorAll("button.outcome");
var viewerButtons = document.querySelectorAll("button.view");
var pickerOptions = document.getElementsByTagName('option');
var selector =  document.getElementById("periodSelect");
var canvas = document.getElementById('c');
var ctx = canvas.getContext('2d');
var colorList;

var currentPucks = [];
var gameToGetData;
var database = firebase.database();
var shotPlacedSinceDataLoad = false;
var middleOfNet;
var r;

onLoad();

var trackShowButton = document.getElementById("trackShow");
trackShowButton.onclick = function(event){ //change between view shots UI and track shots UI
  ctx.clearRect(0,0,canvas.width,canvas.height);
  var sequenceListReference = document.getElementById("sequenceHolders");
  while (sequenceListReference.hasChildNodes()) {
      sequenceListReference.removeChild(sequenceListReference.firstChild);
   }
  var target;
  if(event.target.tagName === "I"){
    target = event.target.parentNode;
  }
  else target = event.target; //protects against if icon clicked
  var buttonName = target.innerText;
  if(buttonName === "View Shot Progressions"){ //right before click
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    var button = document.getElementById("trackShow");
    button.innerHTML = "<i id='trackerIcon' class='fas fa-crosshairs'></i>Track Shot Progressions";
    var selectorRow = document.createElement("option");
    selectorRow.value = "All";
    selectorRow.innerText = "All";
    selector.appendChild(selectorRow);
    document.getElementById("showShots").style.display="inherit";
    document.getElementById("trackShots").style.display="none";
  }
  else if(buttonName === "Track Shot Progressions"){ //right before click
    var button = document.getElementById("trackShow");
    button.innerHTML = "<i id='trackerIcon' class='fas fa-chart-line'></i>View Shot Progressions"
    //"<i class='fas fa-chart-line'></i>View Shot Progressions";
    var allButton = selector.children[selector.children.length - 1];
    allButton.parentNode.removeChild(allButton);
    document.getElementById("trackShots").style.display="inherit";
    document.getElementById("showShots").style.display="none";
  }
}


function onLoad(){
  var width = window.innerWidth;
  var height = window.innerHeight;

  var width = window.innerWidth;
  var height = window.innerHeight;
  document.getElementById("contentBox").style.width = (.75*width) .toString() + "px";

  canvas.width = .5*width - 20;
  canvas.height = 760/860*canvas.width;
  canvas.style.marginLeft = "10px";
  document.getElementById("sequences").style.width = (.25*width - 20).toString() + "px";
  document.getElementById("sequences").style.marginRight = "10px";
  let rect = document.getElementById("seqTop").getBoundingClientRect();
  var titleHeight = rect.bottom - rect.top + 34;
  console.log(titleHeight);
  document.getElementById("sequenceHolders").style.maxHeight = (canvas.height-titleHeight) + "px";

  middleOfNet = {
    x: canvas.width/2,
    y: (0.7953) * canvas.height
  };
  r = 10/860 * canvas.width;
  getCorrectGame();
  addOutcomeEventListeners();
  addViewerEventListeners();
}

window.addEventListener("resize",function(){
  var width = window.innerWidth;
  var height = window.innerHeight;

  canvas.width = .5*width - 20;
  canvas.height = 760/860*canvas.width;
  canvas.style.marginLeft = "10px";
  document.getElementById("sequences").style.width = (.25*width - 20).toString() + "px";
  document.getElementById("sequences").style.marginRight = "10px";

  document.getElementById("contentBox").style.width = (.75*width) .toString() + "px";

  middleOfNet = {
    x: canvas.width/2,
    y: (0.7953) * canvas.height
  };
  r = 10/860 * canvas.width;
  let rect = document.getElementById("seqTop").getBoundingClientRect();
  var titleHeight = rect.bottom - rect.top + 34;
  console.log(titleHeight);
  document.getElementById("sequenceHolders").style.maxHeight = (canvas.height-titleHeight) + "px";
});


function addOutcomeEventListeners(){ //add event listeners to outcome buttons
  outcomeButtons.forEach(button => {
    button.addEventListener("click", function (evt){ //add shot
      var shotTypePerButton = evt.target.id;
      if(shotPlacedSinceDataLoad){
        currentPucks[currentPucks.length - 1].shotType = shotTypePerButton;
        var newSequenceReboundTest = true;
        var period = "Period = " + document.getElementById("periodSelect").value;
        if(shotTypePerButton == "Same Sequence"){
          var puckToAddBack = currentPucks.slice(-1);
          //remove last element
          currentPucks.pop();

          newSequenceReboundTest = false;
          firebase.auth().onAuthStateChanged(function(user){
            if(user){
              uid = user.uid;
              var period = "Period = " + document.getElementById("periodSelect").value;
              //append middle of net locally
              let posRel = convertToRelative(middleOfNet);
              var puckModel = new PuckModel(posRel.x,posRel.y,shotTypePerButton,period,false);
              currentPucks.push(puckModel);
              //append middle of net fb
              firebase.database().ref('games').child(uid).child(gameToGetData + "/data").child(currentPucks.length - 1).update({
                x: puckModel.x,
                y: puckModel.y,
                shotType: puckModel.shotType,
                period: puckModel.period,
                newSequenceBool: puckModel.newSeq
              });
              //append last back locally
              currentPucks.push(puckToAddBack[0]);
              //add last to fb
              firebase.database().ref('games').child(uid).child(gameToGetData + "/data").child(currentPucks.length - 1).set({
                x: puckToAddBack[0].x,
                y: puckToAddBack[0].y,
                shotType: puckToAddBack[0].shotType,
                period: puckToAddBack[0].period,
                newSequenceBool: puckToAddBack[0].newSeq
              });
            }
          });
        }
        else{
          currentPucks[currentPucks.length - 1].shotType = shotTypePerButton;
          currentPucks[currentPucks.length - 1].newSeq = true;

          firebase.auth().onAuthStateChanged(function(user){
            if(user){
              uid = user.uid;
              firebase.database().ref('games').child(uid).child(gameToGetData + "/data").child(currentPucks.length - 1).update({
                shotType: shotTypePerButton,
                newSequenceBool: true
              });
            }
          });
        }
      }
      else{
        alert("Error. You must place a puck first!"); //must have clicked on canvas first
      }
        console.log(currentPucks);
    });
  });
}

function addViewerEventListeners(){ //add event listeners to outcome buttons
  viewerButtons.forEach(button => {
    button.addEventListener("click", function (evt){ //add shot
      var shotTypePerButton = evt.target.id;
      ctx.clearRect(0,0,canvas.width,canvas.height);
      var period = document.getElementById("periodSelect").value;
      var sequencesSortedByPeriod;
      var splitIntoSequences = split(currentPucks);
      if(period === "All"){
        sequencesSortedByPeriod = splitIntoSequences;
      }
      else sequencesSortedByPeriod = sortByPrd(splitIntoSequences,"Period = " + period);
      var sequencesSortedByType = sortByType(sequencesSortedByPeriod,shotTypePerButton);
      console.log(sequencesSortedByType);
      displaySequences(sequencesSortedByType);
    });
  });
}

function displaySequences(sequences){
  var sequenceListReference = document.getElementById("sequenceHolders");
  while (sequenceListReference.hasChildNodes()) {
      sequenceListReference.removeChild(sequenceListReference.firstChild);
   }
  for(i = 0; i < sequences.length; i++){
    var color = generateColor(sequences.length,i);
    //add div with color
    var sequenceListReference = document.getElementById("sequenceHolders");
    var tempSequence = document.createElement("a");
    tempSequence.innerHTML = "Sequence #"+(i+1) ;//<i style='float: right'class='colorIcon fas fa-square'></i>";
    var tempColor = document.createElement("i");
    tempColor.className = "colorIcon fas fa-square";

    tempColor.style.color = "#"+color;
    tempColor.style.float = "right";
    tempSequence.appendChild(tempColor);
    sequenceListReference.appendChild(tempSequence);



    let singleSeq = sequences[i];
    var j = 0;
    for(j=0;j < singleSeq.length - 1;j++){
      var start = convertToAbsolute({x:singleSeq[j].x,y:singleSeq[j].y});
      var end = convertToAbsolute({x:singleSeq[j+1].x,y:singleSeq[j+1].y});
      ctx.beginPath();
      ctx.moveTo(start.x,start.y);
      ctx.lineTo(end.x,end.y);
      ctx.lineWidth = 5;
      if(singleSeq[j+1].shotType === "Skate"){
        ctx.setLineDash([18, 4]);
      }
      else if(singleSeq[j+1].shotType === "Same Sequence"){
        ctx.setLineDash([6,4]);
      }
      else   ctx.setLineDash([]);
      ctx.strokeStyle = "#" + color;
      ctx.stroke();
      ctx.closePath();
      if(j==0){
        ctx.beginPath();
        ctx.arc(start.x,start.y,r,0,Math.PI*2,false);
        ctx.fillStyle="#FFFFFF";
        ctx.closePath();
        ctx.fill();
      }
      else{
        ctx.beginPath();
        ctx.arc(start.x,start.y,r,0,Math.PI*2,false);
        ctx.fillStyle="#000000";
        ctx.closePath();
        ctx.fill();
      }
      ctx.beginPath();
      ctx.arc(end.x,end.y,r,0,Math.PI*2,false);
      ctx.fillStyle="#000000";
      ctx.closePath();
      ctx.fill();

    }

  }
}

function generateColor(listLength,spotInListWanted){
  colorList = new Rainbow();
  colorList.setNumberRange(0,listLength);
  var color = colorList.colourAt(spotInListWanted);
  return color//Math.floor(Math.random()*16777215).toString(16);
}

function split(toSearch){
  var sequencesByPeriod = [];
  var endOfLastSequence = -1;
  for(i=0; i < toSearch.length; i++){

    if(toSearch[i].newSeq == true){
      let tempSequence = toSearch.slice(endOfLastSequence + 1,i+1);
      endOfLastSequence = i;
      sequencesByPeriod.push(tempSequence)
      endOfLastSequence = i;
    }
  }
  return sequencesByPeriod;
}

function sortByType(toSearch,type){
  var sequencesByType = [];
  for(i=0; i < toSearch.length; i++){
    if(toSearch[i][toSearch[i].length-1].shotType === type){
      sequencesByType.push(toSearch[i])
    }
  }
  return sequencesByType;

}

function sortByPrd(toSearch,period){
  var sequencesByType = [];
  for(i=0; i < toSearch.length; i++){
    if(toSearch[i][toSearch[i].length-1].period === period){
      sequencesByType.push(toSearch[i])
    }
  }
  return sequencesByType;

}



function getCorrectGame(){ //get the game to add shots to
  firebase.auth().onAuthStateChanged(function(user){
    if(user){
      uid = user.uid;
      var gameRef = database.ref('games');
      //get the game to get
      gameRef.child("lastGameClickedList/" + uid).once('value').then(function(snapshot){
        snapshot.forEach(function(childSnapshot){
          var childData = childSnapshot.val();
          gameToGetData = childData;
          gameRef.child(uid + "/" + gameToGetData + "/data").once("value").then(function(snapshot) { //this is a promise, so it is asynchronous
            snapshot.forEach(function(childSnapshot) {
              var puckChild = childSnapshot.val();
              var puckModel = new PuckModel(puckChild.x, puckChild.y,puckChild.shotType,puckChild.period, puckChild.newSequenceBool);
              currentPucks.push(puckModel);

            });//snapshot end
          }); //get data end (end of promise)
        }); //outer snapshot end
      }); //outer get data end
    } //log in check end

  }); //auth check end
}

//Get Mouse Position
function getMousePos(canvas, evt) {
  var rect = canvas.getBoundingClientRect();
  return {
    x: evt.clientX - rect.left,
    y: evt.clientY - rect.top
  };
}

canvas.addEventListener("click", function (evt) { //canvas clicked --> draw puck, save to fb and local (along the way, check if double click)
  if(trackShow.innerText === "View Shot Progressions"){
    var mousePos = getMousePos(canvas, evt);
    console.log(mousePos);
    shotPlacedSinceDataLoad = true;

    var period = "Period = " + document.getElementById("periodSelect").value;
    var type;
    if(currentPucks.length > 0){
      var lastShot = currentPucks[currentPucks.length - 1];
      lastShotPos = convertToAbsolute({x:lastShot.x,y:lastShot.y});
      if(shotPlacedSinceDataLoad && (mousePos.x < lastShotPos.x + 5 && mousePos.x > lastShotPos.x - 5)  && (mousePos.y < lastShotPos.y + 5 && mousePos.y < lastShotPos.y + 5)  ){
        type = "Skate";
        currentPucks[currentPucks.length - 1].shotType = "Skate";
        //edit in firebase
        firebase.auth().onAuthStateChanged(function(user){
          if(user){
            uid = user.uid;
            firebase.database().ref('games').child(uid).child(gameToGetData + "/data").child(currentPucks.length - 1).update({
              shotType: "Skate"
            }); //is this right?
          }
        });
      }
      else{
        type = "Pass";
        drawPuck(mousePos,'assets/puck.png');
        var relativePosition = convertToRelative(mousePos)
        var puckModel = new PuckModel(relativePosition.x,relativePosition.y,type,period,false);
        currentPucks.push(puckModel);
        firebase.auth().onAuthStateChanged(function(user){
          if(user){
            uid = user.uid;
            firebase.database().ref('games').child(uid).child(gameToGetData + "/data").child(currentPucks.length - 1).set({
              x: puckModel.x,
              y: puckModel.y,
              shotType: puckModel.shotType,
              period: puckModel.period,
              newSequenceBool: puckModel.newSeq
            }); //is this right?
          }
        });
      }
    }
    else{
      type = "Pass";
      drawPuck(mousePos,'assets/puck.png');
      var relativePosition = convertToRelative(mousePos)
      var puckModel = new PuckModel(relativePosition.x,relativePosition.y,type,period,false);
      currentPucks.push(puckModel);
      firebase.auth().onAuthStateChanged(function(user){
        if(user){
          uid = user.uid;
          firebase.database().ref('games').child(uid).child(gameToGetData + "/data").child(currentPucks.length - 1).set({
            x: puckModel.x,
            y: puckModel.y,
            shotType: puckModel.shotType,
            period: puckModel.period,
            newSequenceBool: puckModel.newSeq
          }); //is this right?
        }
      });
    }
  }
});

function drawPuck(pos,image){ //draw locally
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  var img = new Image();
  img.style.objectFit = "contain";
  img.onload = function() {
    ctx.drawImage(img, pos.x - r, pos.y - r, r*2, r*2);
  };
  img.src = image;//'assets/puck.png';
}

function convertToAbsolute(pos){ //convert to abs positioning
  return {
    x: pos.x * canvas.width,
    y: pos.y * canvas.height
  };
}

function convertToRelative(pos){ //convert to rel positioning
  return {
    x: pos.x / canvas.width,
    y: pos.y / canvas.height
  };
}

document.getElementById('undo').addEventListener('click',function(evt){ //remove from fb
  firebase.auth().onAuthStateChanged(function(user){
    if(user){
      uid = user.uid;
      database.ref('games').child(user.uid).child(gameToGetData).child("data").child(currentPucks.length - 1).remove(); //remove data from fb
      currentPucks.pop();
      let absLastPuckPos = convertToAbsolute({x: currentPucks[currentPucks.length - 1].x,y:currentPucks[currentPucks.length - 1].y});
      drawPuck(absLastPuckPos,'assets/puck.png');
    }
  });

});

document.getElementById('dead').addEventListener('click',function(evt){ //remove from fb
  var upperBoundDeleteLoop = 0;
  for(i=currentPucks.length - 1; i >= 0; i--){
    if(currentPucks[i].newSeq == false){
      firebase.auth().onAuthStateChanged(function(user){
        if(user){
          uid = user.uid;
          database.ref('games').child(user.uid).child(gameToGetData).child("data").child(currentPucks.length - 1).remove(); //remove data from fb
          currentPucks.pop();
        }
      });
      continue;
    }
    else{
      upperBoundDeleteLoop = i;
      break;
    }

  }

});
