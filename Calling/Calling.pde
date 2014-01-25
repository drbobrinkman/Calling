//Run using Sketch->Present in Processing, to get fullscreen
//Play with XBox controller, using ControllerMate to create virtual mouse
import ddf.minim.*; //Minim is the audio package for processing
import processing.video.*;

Movie myMovie;
Minim minim;
AudioPlayer birds1;
AudioPlayer[] bells = new AudioPlayer[11];
int currentBell = 0;

//Constants
static float speedMax=20.0;
static float speedMin=1.0;
static int timePerBlock = 4000; //in millis

//Main game variables
int state;
int startMilli;

int lastSuccess;

int lastMouseX;
int lastMouseY;



mouseTrail[] mTrails = null;
int nextMTrail = 0;
int lastTrailMilli=0;

PImage maskImg;
PImage[] brickImgs;

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
  
  maskImg = loadImage("mask.png");
  brickImgs = new PImage[12];
  brickImgs[0] = loadImage("bricks_0.png");
  brickImgs[1] = loadImage("bricks_1.png");
  brickImgs[2] = loadImage("bricks_2.png");
  brickImgs[3] = loadImage("bricks_3.png");
  brickImgs[4] = loadImage("bricks_4.png");
  brickImgs[5] = loadImage("bricks_5.png");
  brickImgs[6] = loadImage("bricks_6.png");
  brickImgs[7] = loadImage("bricks_7.png");
  brickImgs[8] = loadImage("bricks_8.png");
  brickImgs[9] = loadImage("bricks_9.png");
  brickImgs[10] = loadImage("bricks_10.png");
  brickImgs[11] = loadImage("bricks_11.png");
  
  makeTowerParts();
  
  startMilli = millis();
  lastTrailMilli = millis();

  // we pass this to Minim so that it can load files from the data directory
  minim = new Minim(this);
 
 // loadFile will look in all the same places as loadImage does.
  // this means you can find files that are in the data folder and the 
  // sketch folder. you can also pass an absolute path, or a URL.
  birds1 = minim.loadFile("birdsChirping1.mp3");
  bells[0] = minim.loadFile("bell_0.wav");
  bells[1] = minim.loadFile("bell_1.wav");
  bells[2] = minim.loadFile("bell_2.wav");
  bells[3] = minim.loadFile("bell_3.wav");
  bells[4] = minim.loadFile("bell_4.wav");
  bells[5] = minim.loadFile("bell_5.wav");
  bells[6] = minim.loadFile("bell_6.wav");
  bells[7] = minim.loadFile("bell_7.wav");
  bells[8] = minim.loadFile("bell_8.wav");
  bells[9] = minim.loadFile("bell_9.wav");
  bells[10] = minim.loadFile("bell_10.wav");
  
  // play the file from start to finish.
  // if you want to play the file again, 
  // you need to call rewind() first.
  birds1.rewind();
  myMovie = new Movie(this, "leavesfalling.mp4"); //sets myMovie to the leaves falling video
  myMovie.noLoop(); //makes the video not loop
  myMovie.play();   //sets the video up to play

  //Play until end of movie
  birds1.loop();
}

void makeTowerParts(){
  mTowerParts = new towerPart[108];
  int xstart=634;
  int ystart=234;
  int xextent = 704;
 
  int x=xstart;
  int y=ystart;
  int w = (xextent-xstart)/2;
  int h = 20;
  int vpadding = -7;
  int hpadding = 0;
  for(int i=0; i<54; i++){
    if(x+w > xextent){
      x = xstart;
      y = y + h + vpadding;
    }
    mTowerParts[i] = new towerPart(x,y,w,h,brickImgs[(int)random(0,6)]);
    x = x + w + hpadding;
  }
  xextent = xextent + (xextent-xstart);
  xstart = 704;
  x=xstart;
  y=ystart;
  for(int i=54; i<108; i++){
    if(x+w > xextent){
      x = xstart;
      y = y + h + vpadding;
    }
    mTowerParts[i] = new towerPart(x,y,w,h,brickImgs[(int)random(6,12)]);
    x = x + w + hpadding;
  }
  
  for(int i=0;i<mTowerParts.length; i++){
    towerPart t = mTowerParts[i];
    int index = (int)random(i,mTowerParts.length);
    mTowerParts[i] = mTowerParts[index];
    mTowerParts[index] = t;
  }
}

class towerPart {
  towerPart(){x=y=w=h=0;img=null;}
  towerPart(int ix, int iy, int iw, int ih,PImage iimg){
    x=ix;
    y=iy;
    w=iw;
    h=ih;
    img = iimg;
  }
  
  int x;
  int y;
  int w;
  int h;
  PImage img;
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
    background(0);
    
    println(mouseX +", " + mouseY);
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
         bells[currentBell].rewind();
         bells[currentBell].play();
         currentBell = (currentBell+1)%bells.length;
       }
    
    for(int i=0;i<mTowerParts.length;i++){
      
      if((i+1)*timePerBlock < millis() - startMilli || i < lastSuccess){
        //If the block's time has passed, draw it solid.
        tint(255,0,0); //Red is done
        image(mTowerParts[i].img,mTowerParts[i].x,mTowerParts[i].y,mTowerParts[i].w,mTowerParts[i].h);
      } else if ((i+1)*timePerBlock < millis()+timePerBlock - startMilli){
        //Time almost up
        int millisTil = i*timePerBlock - (millis()-startMilli);
        tint(255,128,0);
        image(mTowerParts[i].img,mTowerParts[i].x,mTowerParts[i].y,mTowerParts[i].w,mTowerParts[i].h);
      } else if ((i+1)*timePerBlock < millis()+2*timePerBlock - startMilli){
        //Time just starting
        int millisTil = i*timePerBlock - (millis()-startMilli);
        tint(0,255,0);
        image(mTowerParts[i].img,mTowerParts[i].x,mTowerParts[i].y,mTowerParts[i].w,mTowerParts[i].h);
      }else {
        //Do nothing
      }
      
    }
    
    for(int i=0;i<mTrails.length;i++){
      if(mTrails[i] != null){
        noStroke();
        fill(mTrails[i].c);
        ellipse(mTrails[i].x-1,mTrails[i].y-1,2,2);
      }
    }
    
    /*
    image(maskImg,800-518-10,10);
    stroke(0);
    fill(0);
    rect(0,0,800-518-10,600);
    rect(0,0,800,10);
    rect(790,0,10,600);*/
  
  
  if(state == 0){
    playVideo(myMovie); //Call this method to play the movie
  } 
}

void playVideo(Movie myMovie){
  float totalSeconds = myMovie.duration();               //Movie length in seconds     
  float timeLeft = myMovie.duration() - myMovie.time();  //Seconds left in the movie
  float time;                                            //used in calculating the faderate
  boolean fadingOut = false;
  float trans = 255;
  
  if(timeLeft < 5){   //If there are 5 seconds left in the movie, then begin to fade out
    trans = 255*timeLeft/5;
  }
  
  if(timeLeft < 0.01){
    birds1.pause();
  }

  tint(255,255,255,trans);     //Tints the current frame
  image(myMovie,0,0);                     //Displays the current frame
}

void movieEvent(Movie m) {
  m.read();                              //reads in the next frame
}


