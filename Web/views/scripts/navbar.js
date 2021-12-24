var loginReference = document.getElementById("loginlink");
var acctSettingsReference = document.getElementById("acctlink");

var navItems = document.querySelectorAll("a.navListItem");
navItems.forEach(function(item){
  item.addEventListener("click",function(event){
    var target = event.target || event.srcElement;
    console.log(target);
    if(target.innerText === "Home"){
      if(firebase.auth().currentUser){
        firebase.auth().currentUser.getIdToken(/* forceRefresh */ true).then(function(idToken) {
          document.location.href = "/?token=" + idToken;
        }).catch(function(error) {
          // Handle error
        });
      }
      else document.location.href = "/";
    }
    else if(target.innerText === "Single Shot Tracker"){
      document.location.href = "/singleshot";
    }
    else if(target.innerText === "Shot Tracker (Game)"){
      if(firebase.auth().currentUser){
        firebase.auth().currentUser.getIdToken(/* forceRefresh */ true).then(function(idToken) {
          document.location.href = "/gameselect?token=" + idToken;
        }).catch(function(error) {
          // Handle error
          document.location.href = "/gameselect";
        });
      }
      else document.location.href = "/gameselect";
    }
    else if(target.innerText === "Account Settings"){
      if(firebase.auth().currentUser){
        firebase.auth().currentUser.getIdToken(/* forceRefresh */ true).then(function(idToken) {
          document.location.href = "/account?token=" + idToken;
        }).catch(function(error) {
          // Handle error
          document.location.href = "/account";
        });
      }
      else document.location.href = "/account";
    }
    else if(target.innerText === "Login"){
      document.location.href = "/login";
    }


  });
});

function checkResponsive() {
  var x = document.getElementById("myTopnav");
  if (x.className === "topnav") {
    x.className += " responsive";
  } else {
    x.className = "topnav";
  }
}
