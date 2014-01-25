//Run using Sketch->Present in Processing, to get fullscreen
//Play with XBox controller, using ControllerMate to create virtual mouse

//Main game variables
int state;
int startMilli;

int lastSuccess;

static int timePerBlock = 5000; //in millis
towerPart[] mTowerParts = null;

void setup() {
  //Projector native resolution in 800x600
  size(800,600);
  frameRate(60); //Projector can do 120, but don't bother
  background(0);
  
  state = 0;
  lastSuccess = 0;
  
  makeTowerParts();
  
  startMilli = millis();
}

void makeTowerParts(){
  mTowerParts = new towerPart[300];
  int x=0;
  int y=0;
  int w = 45;
  int h = 20;
  int padding = 5;
  for(int i=0; i<mTowerParts.length; i++){
    if(x+w >= width){
      x = 0;
      y = y + h + padding;
    }
    mTowerParts[i] = new towerPart(x,y,w,h);
    x = x + w + padding;
  }
  
  for(int i=0;i<mTowerParts.length; i++){
    towerPart t = mTowerParts[i];
    int index = (int)random(i,mTowerParts.length);
    mTowerParts[i] = mTowerParts[index];
    mTowerParts[index] = t;
  }
}

class towerPart {
  towerPart(){x=y=w=h=0;}
  towerPart(int ix, int iy, int iw, int ih){
    x=ix;
    y=iy;
    w=iw;
    h=ih;
  }
  
  int x;
  int y;
  int w;
  int h;
};

void draw() {
  background(0);
  
  if((millis()-startMilli) > lastSuccess*timePerBlock){
    //failed
    startMilli = millis();
    lastSuccess = 0;
  }
  
  //Got the brick in time
  if(mTowerParts[lastSuccess].x <= mouseX &&
     mouseX < mTowerParts[lastSuccess].x + mTowerParts[lastSuccess].w &&
     mTowerParts[lastSuccess].y <= mouseY &&
     mouseY < mTowerParts[lastSuccess].y + mTowerParts[lastSuccess].h){
       lastSuccess++;
     }
  
  for(int i=0;i<mTowerParts.length;i++){
    if(i*timePerBlock < millis() - startMilli){
      //If the block's time has passed, draw it solid.
      stroke(128);
      fill(96);
    } else if (i*timePerBlock < millis()+timePerBlock - startMilli){
      int millisTil = i*timePerBlock - (millis()-startMilli);
      stroke(255);
      fill(255-(127*millisTil/timePerBlock));
    } else if (i*timePerBlock < millis()+2*timePerBlock - startMilli){
      int millisTil = i*timePerBlock - (millis()-startMilli);
      stroke(255*((2*timePerBlock)-millisTil)/(2*timePerBlock));
      fill(127*((2*timePerBlock)-millisTil)/(2*timePerBlock));
    }else {
      noStroke();
      noFill();
    }
    
    rect(mTowerParts[i].x,mTowerParts[i].y,mTowerParts[i].w,mTowerParts[i].h,3);
  }
}


