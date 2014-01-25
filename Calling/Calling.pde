//Run using Sketch->Present in Processing, to get fullscreen
//Play with XBox controller, using ControllerMate to create virtual mouse

//Main game variables
int state;
int startMilli;

int lastSuccess;

int lastMouseX;
int lastMouseY;

float speedMax=30.0;
float speedMin=1.0;

mouseTrail[] mTrails = null;
int nextMTrail = 0;
int lastTrailMilli=0;

PImage maskImg;
PImage brickImg;

class mouseTrail{
  mouseTrail(){x=y=0;c=color(0);}
  mouseTrail(int ix, int iy, color ic){
    x = ix;
    y = iy;
    c = ic;
  }
  
  int x;
  int y;
  color c;
}

static int timePerBlock = 5000; //in millis
towerPart[] mTowerParts = null;

void setup() {
  //Projector native resolution in 800x600
  size(800,600);
  frameRate(60); //Projector can do 120, but don't bother
  background(0);
  
  state = 0;
  lastSuccess = 0;
  lastMouseX = mouseX;
  lastMouseY = mouseY;
  mTrails = new mouseTrail[10];
  
  makeTowerParts();
  
  startMilli = millis();
  lastTrailMilli = millis();
  
  maskImg = loadImage("mask.png");
  brickImg = loadImage("bricks.png");
}

void makeTowerParts(){
  mTowerParts = new towerPart[100];
  int x=0;
  int y=0;
  int w = 45;
  int h = 20;
  int padding = 5;
  for(int i=0; i<mTowerParts.length; i++){
    if(x+w >= width/3){
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

void doFail(){
  if(lastSuccess != 0){
    for(int i=0;i<mTowerParts.length; i++){
      towerPart t = mTowerParts[i];
      int index = (int)random(i,mTowerParts.length);
      mTowerParts[i] = mTowerParts[index];
      mTowerParts[index] = t;
    }
  }
  lastSuccess = 0;
  startMilli = millis();
}

void draw() {
  background(255);
  
  if(millis() - lastTrailMilli > 100){
    lastTrailMilli = millis();
    float mouseDist = sqrt((mouseX-lastMouseX)*(mouseX-lastMouseX) +
                           (mouseY-lastMouseY)*(mouseY-lastMouseY));  
    float proportion = (mouseDist - speedMin)/(speedMax-speedMin);
    
    if(proportion > 0.9){
      //TOO FAST
      doFail();
    }
    
    color c = color(0,255,0);
    if(proportion > 0.6){
      c = color(255,128,0);
    } else if(proportion > 0.8){
      c = color(255,0,0);
    }
    
    mTrails[nextMTrail] = new mouseTrail(mouseX,mouseY,c);
    nextMTrail = (nextMTrail+1)%mTrails.length;
    lastMouseX = mouseX;
    lastMouseY = mouseY;
  }
  
  if((millis()-startMilli) > (1+lastSuccess)*timePerBlock){
    //failed
    doFail();
  }
  
  //Got the brick in time
  if(mTowerParts[lastSuccess].x <= mouseX &&
     mouseX < mTowerParts[lastSuccess].x + mTowerParts[lastSuccess].w &&
     mTowerParts[lastSuccess].y <= mouseY &&
     mouseY < mTowerParts[lastSuccess].y + mTowerParts[lastSuccess].h){
       lastSuccess++;
     }
  
  for(int i=0;i<mTowerParts.length;i++){
    if((i+1)*timePerBlock < millis() - startMilli || i < lastSuccess){
      //If the block's time has passed, draw it solid.
      stroke(128);
      fill(128,0,0); //Red is done
    } else if ((i+1)*timePerBlock < millis()+timePerBlock - startMilli){
      //Time almost up
      int millisTil = i*timePerBlock - (millis()-startMilli);
      stroke(128);
      fill(128,64,0);
    } else if ((i+1)*timePerBlock < millis()+2*timePerBlock - startMilli){
      //Time just starting
      int millisTil = i*timePerBlock - (millis()-startMilli);
      stroke(128);
      fill(0,128,0);
    }else {
      noStroke();
      noFill();
    }
    rect(mTowerParts[i].x,mTowerParts[i].y,mTowerParts[i].w,mTowerParts[i].h,3);
  }
  
  for(int i=0;i<mTrails.length;i++){
    if(mTrails[i] != null){
      noStroke();
      fill(mTrails[i].c);
      ellipse(mTrails[i].x-1,mTrails[i].y-1,2,2);
    }
  }
  
  image(maskImg,800-518-10,10);
  stroke(0);
  fill(0);
  rect(0,0,800-518-10,600);
  rect(0,0,800,10);
  rect(790,0,10,600);
}


