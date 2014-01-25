//Run using Sketch->Present in Processing, to get fullscreen

//Main game variables
int state;
int startMilli;

static int timePerBlock = 5000; //in millis
towerPart[] mTowerParts = null;

void setup() {
  //Projector native resolution in 800x600
  size(800,600);
  frameRate(60); //Projector can do 120, but don't bother
  background(0);
  
  state = 0;
  
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
    mTowerParts[i] = new towerPart(x,y,w,h,i*timePerBlock);
    x = x + w + padding;
  }
  
  for(int i=0;i<mTowerParts.length; i++){
    int t = mTowerParts[i].when;
    int index = (int)random(i,mTowerParts.length);
    mTowerParts[i].when = mTowerParts[index].when;
    mTowerParts[index].when = t;
  }
}

class towerPart {
  towerPart(){x=y=w=h=when=0;}
  towerPart(int ix, int iy, int iw, int ih, int iwhen){
    x=ix;
    y=iy;
    w=iw;
    h=ih;
    when=iwhen;
  }
  
  int x;
  int y;
  int w;
  int h;
  
  int when;
};

void draw() {
  for(int i=0;i<mTowerParts.length;i++){
    if(mTowerParts[i].when < millis()){
      //If the block's time has passed, draw it solid.
      stroke(128);
      fill(96);
    } else if (mTowerParts[i].when < millis()+timePerBlock){
      int millisTil = mTowerParts[i].when - millis();
      stroke(255);
      fill(255-(127*millisTil/timePerBlock));
    } else if (mTowerParts[i].when < millis()+2*timePerBlock){
      int millisTil = mTowerParts[i].when - millis();
      stroke(255*((2*timePerBlock)-millisTil)/(2*timePerBlock));
      fill(127*((2*timePerBlock)-millisTil)/(2*timePerBlock));
    }else {
      noStroke();
      noFill();
    }
    
    rect(mTowerParts[i].x,mTowerParts[i].y,mTowerParts[i].w,mTowerParts[i].h,3);
  }
}


