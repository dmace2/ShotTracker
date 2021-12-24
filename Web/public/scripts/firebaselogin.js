var signInButton = document.getElementById("loginbutton");
var googleOAuthButton = document.getElementById("googlebutton");
var signUpButton = document.getElementById("signupbutton");
var userDataWritten = false;



signInButton.addEventListener("click", login);
function login(){

  var userEmail = document.getElementById("name").value;
  var userPass = document.getElementById("pass").value;

  firebase.auth().signInWithEmailAndPassword(userEmail, userPass).then(function(result){
    sendTokenToServer();
  }).catch(function(error) {
    // Handle Errors here.
    var errorCode = error.code;
    var errorMessage = error.message;
    // sendTokenToServer();
    window.alert("Error : " + errorMessage);

    // ...
  });

}


signUpButton.addEventListener("click", signup);
function signup(){
  var userEmail = document.getElementById("regname").value;
  var userPass = document.getElementById("regpass").value;
  var confirmPass = document.getElementById("reregpass").value;
  var passwordsMatch = userPass.localeCompare(confirmPass);
  if(passwordsMatch == 0){
    firebase.auth().createUserWithEmailAndPassword(userEmail, userPass).then(function(result){
      var user = firebase.auth().currentUser;
      var email_id = user.email;
      sendTokenToServer();
      // changePages("toShotTracking"); //change this to shot tracking part when I create a page
    }).catch(function(error) {
      // Handle Errors here.
      var errorCode = error.code;
      var errorMessage = error.message;
      // ...
      window.alert("Error : " + errorMessage);
    });
  }
  else window.alert("Error :  Passwords do not match.")
}


googleOAuthButton.addEventListener("click", googleOAuth);
function googleOAuth(){
  base_provider = new firebase.auth.GoogleAuthProvider();
  firebase.auth().signInWithPopup(base_provider).then(function(result){
    sendTokenToServer();

    //changePages("toShotTracking"); //change this to shot tracking part when I create a page
  }).catch(function(error){
    var errorCode = error.code;
    var errorMessage = error.message;
    // ...
    window.alert("Error : " + errorMessage);

  });

}



function writeUserData(userId, email) {
  var database = firebase.database();
  let userRef = database.ref('users');
  userRef.child(userId).set(email);
  let gameRef = database.ref('games/lastGameClickedList/' + userId);
  gameRef.child("lastSelectedGame").set("None",function(error){
    if(error){

    }
    else {
      console.log("data written successfully");
      // window.location.replace('index.html');
    }
  });
}

function sendTokenToServer(){
  firebase.auth().currentUser.getIdToken(/* forceRefresh */ true).then(function(idToken) {
    // Send token to your backend via HTTPS
    // ...
    console.log(idToken+"\n");
    console.log(window.location.pathname);
    if(!(window.location.pathname === "/login")){
      window.location.replace(window.location.pathname + '?token='+idToken); //redirect to correct page afterwards
    }
    else window.location.replace("/?token="+idToken);

  }).catch(function(error) {
    // Handle error
  });
}
