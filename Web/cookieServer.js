var cookieSession = require('cookie-session')
var express = require("express");
var admin = require("firebase-admin");
var path  = require("path");
var serviceAccount = require("./shottracker-715c1-firebase-adminsdk-nxns2-f8e8f84a37.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://shottracker-715c1.firebaseio.com"
});

var app = express();

var port = process.env.PORT || 5000;

app.use(express.static(__dirname + '/public'));

function loginCheck(req,res,next){
  var token = req.query.token;
  if(token === undefined){ //if not given a token, force them to login
    res.sendFile(__dirname + "/public/login.html");
  }
  // idToken comes from the client app
  else{
    admin.auth().verifyIdToken(token).then(function(decodedToken) {
      var uid = decodedToken.uid;
        next(); //login was successful, render account settings page
    }).catch(function(error) {
      console.log(error);
      app.use(express.static(__dirname + '/public'));
      res.sendFile(__dirname + "/public/login.html");
      // Handle error
    });
  }
}

function loginCheckHome(req,res,next){
  var token = req.query.token;
  if(token === undefined){ //if not given a token, force them to login
    app.use(express.static(__dirname + '/public'));
    res.sendFile(__dirname + "/public/home.html");
  }
  // idToken comes from the client app
  else{
    admin.auth().verifyIdToken(token).then(function(decodedToken) {
      var uid = decodedToken.uid;
        next(); //login was successful, render account settings page
    }).catch(function(error) {
      console.log(error);
      app.use(express.static(__dirname + '/public'));
      res.sendFile(__dirname + "/public/home.html");
      // Handle error
    });
  }
}

function cookieCheck(req,res,next){

}

app.get("/", loginCheckHome, function(req,res){
  app.use(express.static(__dirname + '/views'));
  res.sendFile(__dirname + "/views/home.html");
});

app.get("/login", function(req,res){
  app.use(express.static(__dirname + '/public'));
  res.sendFile(__dirname + "/public/login.html");
});

app.get("/account",loginCheck, function(req,res){
  app.use(express.static(__dirname + '/views'));
  res.sendFile(__dirname + "/views/accountsettings.html");
});

app.get("/singleshot", function(req,res){
  app.use(express.static(__dirname + '/public'));
  res.sendFile(__dirname + "/public/singleshot.html");
});

app.get("/gameselect",loginCheck, function(req,res){
  app.use(express.static(__dirname + '/views'));
  res.sendFile(__dirname + "/views/shottracker.html");
});

app.get("/fbshot",loginCheck, function(req,res){
  app.use(express.static(__dirname + '/views'));
  res.sendFile(__dirname + "/views/fbshottracker.html");
});

app.listen(port,function(){
    console.log("app running on port " + port);
})
