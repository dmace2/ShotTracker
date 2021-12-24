var nameReference = document.getElementById("username");
var imgReference = document.getElementById("userimg");
var emailReference = document.getElementById("useremail");
var logOutButton = document.getElementById("logoutbutton");



var fbname, fbemail, fbimage;


firebase.auth().onAuthStateChanged(function(user){
  if(user){
    fbname = user.displayName;
    nameReference.innerHTML = fbname;
    fbemail = user.email;
    emailReference.innerHTML = fbemail;
    fbimage = user.photoURL;
    console.log(fbimage);
    if(fbimage == null){
      fbimage = "http://chittagongit.com/images/default-user-icon/default-user-icon-8.jpg";

    }
    imgReference.src = fbimage;



  }



  else console.log("no current user");
});


logOutButton.addEventListener("click", function(){
  firebase.auth().signOut();
  firebase.auth().onAuthStateChanged(function(user){
    if(user){
      window.alert("Error. Please Try Again.");
    }
    else {
      window.alert("You have been successfully logged out.");
      window.location.replace('/');
    }
  });
});
