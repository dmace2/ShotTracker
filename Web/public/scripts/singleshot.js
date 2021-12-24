var canvas = document.getElementById("c");
var ctx = canvas.getContext('2d');

var middleOfNet;
var lastPuckPos;

var whichThingPlaced = 1; //1 if puck, -1 if goalie;
var lastShotDist;
var tWidth;
var tHeight;
var lastWViewable;

var r; //= 10/860*canvas.width;


onLoad();


//Get Mouse Position
function getMousePos(canvas, evt) {
  var rect = canvas.getBoundingClientRect();
  return {
    x: evt.clientX - rect.left,
    y: evt.clientY - rect.top
  };
}

function onLoad(){
  canvas = document.getElementById("c");
  var width = window.innerWidth;
  var height = window.innerHeight;

  canvas.width = .5*width - 20;
  canvas.height = 760/860*canvas.width;
  canvas.style.display = "block";
  canvas.style.marginLeft = "auto";
  canvas.style.marginRight = "auto";

  middleOfNet = {
    x: canvas.width/2,
    y: (0.8533) * canvas.height
  };
  r = 10/860*canvas.width;
}

window.addEventListener("resize",function(){
  var width = window.innerWidth;
  var height = window.innerHeight;

  canvas.width = .5*width - 20;
  canvas.height = 760/860*canvas.width;
  canvas.style.display = "block";
  canvas.style.marginLeft = "auto";
  canvas.style.marginRight = "auto";
  middleOfNet = {
    x: canvas.width/2,
    y: (0.8533) * canvas.height
  };
  r = 10/860*canvas.width;
});

canvas.addEventListener("click", function (evt) {
  var mousePos = getMousePos(canvas, evt);
  console.log("Goal Line = " + middleOfNet.y);
  console.log(mousePos);
  if(whichThingPlaced == 1){
    console.log("puck")
    lastPuckPos = mousePos;
    drawPuck(mousePos);
    calcPuckNums(mousePos);
  }
  else{
    console.log("goalie")
    drawGoalie(mousePos);
    calcGoalieNums(mousePos);

  }
  whichThingPlaced *= -1;
});


//puck functions
function shotDist(pos){
  var hconstant;
  let wconstant = 86 / canvas.width;
  if(pos.y >= middleOfNet.y){hconstant = 120 / canvas.height;}
  else {hconstant = 65 / (middleOfNet.y);} //in front of net vs behind net
  tWidth = Math.abs(pos.x - middleOfNet.x) * wconstant; //convert from px to ft
  tHeight = Math.abs(middleOfNet.y - pos.y) * hconstant;
  let dist = Math.hypot(tWidth, tHeight); //distance
  lastShotDist = dist; //makes accessible for the amount decrease for goalie numbers
  return dist
}

function wViewableNet(pos){
  let widthViewable = 6 * Math.cos(Math.atan(tWidth/tHeight));
  lastWViewable = widthViewable;
  return widthViewable;
}

function calcPuckNums(position){
  let dist = shotDist(position);
  var wViewNet;
  if(position.y < middleOfNet.y){
    wViewNet = wViewableNet(position);
  }
  else wViewNet = 0.0; //checks to see if behind net for amount of net viewable

  let truncatedDist = Math.floor(dist); //distance with no decimal
  let truncWidth = parseFloat(wViewNet.toFixed(1));
  setPuckNumbers(truncatedDist, truncWidth);
}

function setPuckNumbers(shotDist, widthViewableNet){
  let shotDistText = document.getElementById('shotLength');
  shotDistText.innerHTML = shotDist + " ft"

  let widthViewableText = document.getElementById("widthViewable");
  widthViewableText.innerHTML = widthViewableNet + " ft"
}

function drawPuck(pos){
ctx.clearRect(0, 0, canvas.width, canvas.height);
  var img = new Image();
  img.style.objectFit = "contain";
  img.onload = function() {
    ctx.drawImage(img, pos.x - r, pos.y - r, 2*r, 2*r);
    ctx.stroke();
  };
  img.src = 'assets/puck.png';
}



//goalie functions
function drawGoalie(pos){
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  drawPuck(lastPuckPos);
  var img = new Image();
  img.style.objectFit = "contain";
  img.onload = function() {
    ctx.drawImage(img, pos.x - r, pos.y - 1.4*r, 2*r, 2.9*r);
    ctx.stroke();
  };
  img.src = 'assets/goaliemask.png';
}

function calcGoalieNums(position){
  let goalieDistance = goalieDist(position);
  let gBlockW = goalieBlockWidth(position,goalieDistance);
  let roundedBlockW = parseFloat(gBlockW.toFixed(1));
  let gBlockH = goalieBlockHeight(position, goalieDistance);
  let roundedBlockH = parseFloat(gBlockH.toFixed(1));

  let gWDec = decreaseWidth(position,gBlockW,goalieDistance);
  let roundedDecreaseWidth = parseFloat(gWDec.toFixed(1));
  let gHDec = decreaseHeight();
  let roundedDecreaseHeight = parseFloat(gHDec.toFixed(1));

  setGoalieNumbers(roundedBlockW, roundedBlockH, roundedDecreaseWidth, roundedDecreaseHeight);

}

function goalieDist(pos){
  var hconstant;
  let wconstant = 86 / canvas.width;
  if(pos.y >= middleOfNet.y){hconstant = 120 / canvas.height;}
  else {hconstant = 65 / (middleOfNet.y);} //in front of net vs behind net
  gWidth = Math.abs(pos.x - middleOfNet.x) * wconstant; //convert from px to ft
  gHeight = Math.abs(middleOfNet.y - pos.y) * hconstant;
  let dist = Math.hypot(gWidth, gHeight); //distance
  return dist
}

function goalieBlockWidth(pos,gDist){
  let blockingWidth = lastWViewable * (lastShotDist-gDist)/lastShotDist - 3 * Math.sin(Math.atan(tWidth/tHeight));
  return blockingWidth

}

function goalieBlockHeight(pos,gDist){
  let blockingHeight = 4 * (lastShotDist - gDist) / lastShotDist;
  return blockingHeight;
}

function decreaseWidth(pos,blockWidth,goalieDist){
  let widthDecrease = (lastWViewable - blockWidth) / (goalieDist - 3 * Math.sin(Math.atan(tWidth/tHeight))) * 12;
  return widthDecrease;
}

function decreaseHeight(){
  let heightDecrease = (4 - 4 * (lastShotDist - 1)/lastShotDist) * 12;
  return heightDecrease;
}


function setGoalieNumbers(blockingWidth, blockingHeight, widthDecrease, heightDecrease){
  let widthText = document.getElementById('goalBlockWidth');
  let heightText = document.getElementById('goalBlockHeight');
  let wDecText = document.getElementById('decreaseWidthInches');
  let hDecText = document.getElementById('decreaseHeightInches');

  widthText.innerHTML = blockingWidth + " ft";
  heightText.innerHTML = blockingHeight + " ft";
  wDecText.innerHTML = widthDecrease + " in";
  hDecText.innerHTML = heightDecrease + " in";
}
