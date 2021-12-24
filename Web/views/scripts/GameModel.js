class GameModel{

  constructor(gameDate, gameNickname, gameFBLabel){
    this.gameDate = gameDate;
    this.gameNickname = gameNickname;
    this.gameFBLabel = gameFBLabel;
  }

}

class PuckModel{
  constructor(x, y, shotType, period, newSeq){
    this.x = x;
    this.y = y;
    this.shotType = shotType;
    this.period = period;
    this.newSeq = newSeq;
  }
}
