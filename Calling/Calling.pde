//This game was created for the Global Game Jam 2014 by 
// Daltin, Bo, Nate, and Ryan. It is released under the
// http://creativecommons.org/licenses/by-nc-sa/3.0/ license

//Run using Sketch->Present in Processing, to get fullscreen
//Play with XBox controller, using ControllerMate to create virtual mouse
import ddf.minim.*; //Minim is the audio package for processing
import processing.video.*;

Movie myMovie;
Movie myMovie2;
Movie myMovie4;
Movie myMovie6;

Minim minim;
//AudioPlayer birds1;
AudioPlayer[] bells = new AudioPlayer[11];
int currentBell = 0;
AudioPlayer soundtrack;


int[] numPiecesInLevel = {42, 32, 56,5};

ParticleSystem ps;

int maxParticles = 10;

int lastTimePunished=0;

//Constants
float speedMax=40.0;
static float speedMin=1.0;
static int baseTimePerBlock = 5000;
int timePerBlock = baseTimePerBlock; //in millis

//Main game variables
//State values:
//0: Intro movie
//1: First level
//2: Second movie
//3: Second level
//4: Third moview
//5: Third level
//6: Game won
int state;
int curMilli;
//int startMilli;

int lastSuccess;

int lastMouseX;
int lastMouseY;
int oldPartX;
int oldPartY;

float prevSpeed;

//mouseTrail[] mTrails = null;
//int nextMTrail = 0;
int lastTrailMilli=0;

PImage maskImg;
PImage[] brickImgs;
PImage level1Topper;
PImage[] btbricks;
PImage btcupola;
PImage btwindows;
PImage[] p_bricks;
PImage p_clock;
PImage p_main;

towerPart[] mTowerParts1 = null;
towerPart[] mTowerParts2 = null;
towerPart[] mTowerParts3 = null;

void setup() {
  //Projector native resolution in 800x600
  size(800,600);
  frameRate(60); //Projector can do 120, but don't bother
  background(0);
  noCursor();
  
  state = 0;
  lastSuccess = 0;
  lastMouseX = mouseX;
  lastMouseY = mouseY;
  
  ps = new ParticleSystem();
  
  level1Topper = loadImage("level1_topper.png");
  level1Topper.resize(800,600);
  maskImg = loadImage("mask.png");
  maskImg.resize(800,600);
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
  
  btbricks = new PImage[32];
  for(int i=0;i<btbricks.length;i++){
    btbricks[i] = loadImage("btbricks_" +i+".png");
  }
  btcupola = loadImage("bt_cupola.png");
  btwindows = loadImage("beta windows.png");
  
  p_bricks = new PImage[55];
  for(int i=0;i<p_bricks.length;i++){
    p_bricks[i] = loadImage("p_brick" +i+".png");
  }
  p_clock = loadImage("p_clock.png");
  p_main = loadImage("p_main.png");
  
  makeTowerParts();

  // we pass this to Minim so that it can load files from the data directory
  minim = new Minim(this);
 
 // loadFile will look in all the same places as loadImage does.
  // this means you can find files that are in the data folder and the 
  // sketch folder. you can also pass an absolute path, or a URL.
  //birds1 = minim.loadFile("birdsChirping1.mp3");
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
  soundtrack = minim.loadFile("GGJ Audio.mp3");
  
  // play the file from start to finish.
  // if you want to play the file again, 
  // you need to call rewind() first.
  
  myMovie = new Movie(this, "leavesfalling.mp4"); //sets myMovie to the leaves falling video
  myMovie.noLoop(); //makes the video not loop
  myMovie2 = new Movie(this, "snow to use.mp4");
  myMovie2.noLoop();
  myMovie4 = new Movie(this, "Stock Footage of the sun shining in a silhouetted grove of trees in Israel.mp4");
  myMovie4.noLoop();
  myMovie6 = new Movie(this, "Along The Beach Stock Footage.mp4");
  myMovie6.noLoop();
  myMovie.volume(0);
  myMovie2.volume(0);
  myMovie4.volume(0);
  myMovie6.volume(0);
  
  gameRestart();
}

void gameRestart(){
  state = 0;
  prevSpeed = 0;
  myMovie.jump(0);
  myMovie.play();   //sets the video up to play
  curMilli = millis();
  lastTrailMilli = millis();
  //Play until end of movie
  //birds1.rewind();
  //birds1.loop();
  soundtrack.rewind();
  soundtrack.loop();
}

void makeTowerParts(){
  mTowerParts1 = new towerPart[7*6];
  
  int xstart=800-185-4*32;
  int ystart=375;

  int x = xstart;
  int y = ystart;
  //When I wrote this, I had the display flipped, hence the "800-x" nonsense.
  for(int i=0; i<7; i++){
    x += 16;
    y -= 10;
    mTowerParts1[i*6+0] = new towerPart(x,y,32,20,brickImgs[(int)random(0,6)]);
    x += 3*16;
    y -= 5;
    mTowerParts1[i*6+1] = new towerPart(x,y,32,20,brickImgs[(int)random(6,12)]);
    x += 2*16;
    y +=10;
    mTowerParts1[i*6+2] = new towerPart(x,y,32,20,brickImgs[(int)random(6,12)]);
    x += 2*16;
    y += 10;
    
    x=xstart;
    y += 5;
    mTowerParts1[i*6+3] = new towerPart(x,y,32,20,brickImgs[(int)random(0,6)]);
    x += 2*16;
    y -= 10;
    mTowerParts1[i*6+4] = new towerPart(x,y,32,20,brickImgs[(int)random(0,6)]);
    x += 3*16;
    y += 5;
    mTowerParts1[i*6+5] = new towerPart(x,y,32,20,brickImgs[(int)random(6,12)]);
    y += 25;
    x = xstart;
  }
  
  for(int i=0;i<mTowerParts1.length; i++){
    towerPart t = mTowerParts1[i];
    int index = (int)random(i,mTowerParts1.length);
    mTowerParts1[i] = mTowerParts1[index];
    mTowerParts1[index] = t;
  }
  
  mTowerParts2 = new towerPart[32];
  for(int i=0;i<mTowerParts2.length;i++){
    mTowerParts2[i] = new towerPart(0,0,269,589,btbricks[i]);
  }
  for(int i=0;i<mTowerParts2.length; i++){
    towerPart t = mTowerParts2[i];
    int index = (int)random(i,mTowerParts2.length);
    mTowerParts2[i] = mTowerParts2[index];
    mTowerParts2[index] = t;
  }
  
  mTowerParts3 = new towerPart[56];
  for(int i=0;i<mTowerParts3.length-1;i++){
    mTowerParts3[i] = new towerPart(0,0,509,306,p_bricks[i]);
  }
  mTowerParts3[55] = new towerPart(0,0,509,306,p_clock);
  for(int i=0;i<mTowerParts3.length; i++){
    towerPart t = mTowerParts3[i];
    int index = (int)random(i,mTowerParts3.length-1);
    mTowerParts3[i] = mTowerParts3[index];
    mTowerParts3[index] = t;
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

void doFailTooFast(){
    if(millis() - lastTimePunished > 200){
     doFail();
    } 
}

void doFail(){
  lastSuccess = lastSuccess - 3;
  if(lastSuccess < 0) lastSuccess = 0;
  
  curMilli = millis();
  lastTimePunished = curMilli;
  prevSpeed = 0;
}

void draw() {  
    background(0);
    //println(mouseX + ", " + mouseY);
    if(lastSuccess >= numPiecesInLevel[state/2]){
      state++;
      lastSuccess = 0;
      if(state == 2){
        myMovie2.jump(0);
        myMovie2.play();
        myMovie2.volume(0);
      } else if(state == 4){
        myMovie4.jump(0);
        myMovie4.play();
        myMovie4.volume(0);
      } else if(state == 6){
        myMovie6.jump(0);
        myMovie6.play();
        myMovie6.volume(0);
      }
    }
    
    timePerBlock = baseTimePerBlock - lastSuccess*15;
    
    if(millis() - lastTrailMilli > 100){
      lastTrailMilli = millis();
      float mouseDist = sqrt((mouseX-lastMouseX)*(mouseX-lastMouseX) +
                             (mouseY-lastMouseY)*(mouseY-lastMouseY));  
      float proportion = ((mouseDist+prevSpeed)/2.0 - speedMin)/(speedMax-speedMin);
      
      if(proportion > 0.9){
        //TOO FAST
        doFailTooFast();
      }
      prevSpeed = mouseDist;
      
      color c = color(0,255,0);
      if(proportion > 0.6){
        c = color(255,128,0);
      } else if(proportion > 0.8){
        c = color(255,0,0);
      }
      
      lastMouseX = mouseX;
      lastMouseY = mouseY;
    }
    
    if((millis()-curMilli) > timePerBlock){
      //failed
      doFail();
    }
    
    if(state == 1){
      //Got the brick in time
      if(lastSuccess < mTowerParts1.length &&
         /*lastSuccess+1 < mTowerParts1.length &&*/
         ((mTowerParts1[lastSuccess].x <= mouseX &&
         mouseX < mTowerParts1[lastSuccess].x + mTowerParts1[lastSuccess].w &&
         mTowerParts1[lastSuccess].y <= mouseY &&
         mouseY < mTowerParts1[lastSuccess].y + mTowerParts1[lastSuccess].h) /*||
         (mTowerParts1[lastSuccess+1].x <= mouseX &&
         mouseX < mTowerParts1[lastSuccess+1].x + mTowerParts1[lastSuccess+1].w &&
         mTowerParts1[lastSuccess+1].y <= mouseY &&
         mouseY < mTowerParts1[lastSuccess+1].y + mTowerParts1[lastSuccess+1].h)*/)){
           lastSuccess += 1;
           bells[currentBell].rewind();
           bells[currentBell].play();
           currentBell = (currentBell+1)%bells.length;
           curMilli = millis();
         }
    } else if(state == 3){
      if(lastSuccess < mTowerParts2.length){
        //Get the pixel color at the current mouse location
        if(oldPartX < mTowerParts2[lastSuccess].w && oldPartY < mTowerParts2[lastSuccess].h){
          //Mouse is inside the picture, at least
          color c = mTowerParts2[lastSuccess].img.get(oldPartX,oldPartY);
          if(alpha(c) > 0){
           lastSuccess += 1;
           bells[currentBell].rewind();
           bells[currentBell].play();
           currentBell = (currentBell+1)%bells.length;
           curMilli = millis();
         }
        }
      }
    } else if(state == 5){
      if(lastSuccess < mTowerParts3.length){
        //Get the pixel color at the current mouse location
        if(oldPartX < mTowerParts3[lastSuccess].w && oldPartY < mTowerParts3[lastSuccess].h){
          //Mouse is inside the picture, at least
          color c = mTowerParts3[lastSuccess].img.get(oldPartX,oldPartY);
          if(alpha(c) > 0){
           lastSuccess += 1;
           bells[currentBell].rewind();
           bells[currentBell].play();
           currentBell = (currentBell+1)%bells.length;
           curMilli = millis();
         }
        }
      }
    }

  if(state >= 1){
    for(int i=0;i<mTowerParts1.length;i++){
      /*if(mTowerParts1[i] != null){
        image(mTowerParts1[i].img,mTowerParts1[i].x,mTowerParts1[i].y,mTowerParts1[i].w,mTowerParts1[i].h);
      }*/
      
      if(state > 1){
        tint(255,96,96); //Red is done
        image(mTowerParts1[i].img,mTowerParts1[i].x,mTowerParts1[i].y,mTowerParts1[i].w,mTowerParts1[i].h);
      } else if(lastSuccess == 0 && (i == 0 /*|| i == 1*/)){
        tint(64,255,64);
        image(mTowerParts1[i].img,mTowerParts1[i].x,mTowerParts1[i].y,mTowerParts1[i].w,mTowerParts1[i].h);
      } else if(i < lastSuccess){
        //If the block's time has passed, draw it solid.
        tint(255,96,96); //Red is done
        image(mTowerParts1[i].img,mTowerParts1[i].x,mTowerParts1[i].y,mTowerParts1[i].w,mTowerParts1[i].h);
      } else if ((i == lastSuccess /*|| i == lastSuccess+1*/) && millis()-curMilli < timePerBlock){
        //Time almost up
        float timeLeft = millis()-curMilli;
        float trans = 255 - 255*timeLeft/timePerBlock;
        tint(255-trans,255,64,trans);
        image(mTowerParts1[i].img,mTowerParts1[i].x,mTowerParts1[i].y,mTowerParts1[i].w,mTowerParts1[i].h);
      } else {
        //do nothing
      }
      
    }
  }
    if(state >= 3){
      for(int i=0;i<mTowerParts2.length;i++){
        /*if(mTowerParts1[i] != null){
          image(mTowerParts1[i].img,mTowerParts1[i].x,mTowerParts1[i].y,mTowerParts1[i].w,mTowerParts1[i].h);
        }*/
        
        if(state > 3){
          tint(255,96,96); //Red is done
          image(mTowerParts2[i].img,mTowerParts2[i].x,mTowerParts2[i].y,mTowerParts2[i].w,mTowerParts2[i].h);
        } else if(lastSuccess == 0 && (i == 0 /*|| i == 1*/)){
          tint(64,255,64);
          image(mTowerParts2[i].img,mTowerParts2[i].x,mTowerParts2[i].y,mTowerParts2[i].w,mTowerParts2[i].h);
        } else if(i < lastSuccess){
          //If the block's time has passed, draw it solid.
          tint(255,96,96); //Red is done
          image(mTowerParts2[i].img,mTowerParts2[i].x,mTowerParts2[i].y,mTowerParts2[i].w,mTowerParts2[i].h);
        } else if ((i == lastSuccess /*|| i == lastSuccess+1*/) && millis()-curMilli < timePerBlock){
          //Time almost up
          float timeLeft = millis()-curMilli;
          float trans = 255 - 255*timeLeft/timePerBlock;
          tint(255-trans,255,64,trans);
          image(mTowerParts2[i].img,mTowerParts2[i].x,mTowerParts2[i].y,mTowerParts2[i].w,mTowerParts2[i].h);
        } else {
          //do nothing
        }
      }
    }
    
    if(state >= 5){
      for(int i=0;i<mTowerParts3.length;i++){
        /*if(mTowerParts3[i] != null){
          image(mTowerParts3[i].img,mTowerParts3[i].x,mTowerParts3[i].y,mTowerParts3[i].w,mTowerParts3[i].h);
        }*/
        
        if(state > 5){
          if(i != 55){
            tint(255,96,96); //Red is done
          } else {
            tint(255,255,255);
          }
          image(mTowerParts3[i].img,mTowerParts3[i].x,mTowerParts3[i].y,mTowerParts3[i].w,mTowerParts3[i].h);
        } else if(lastSuccess == 0 && (i == 0 /*|| i == 1*/)){
          tint(64,255,64);
          image(mTowerParts3[i].img,mTowerParts3[i].x,mTowerParts3[i].y,mTowerParts3[i].w,mTowerParts3[i].h);
        } else if(i < lastSuccess){
          //If the block's time has passed, draw it solid.
          if(i != 55){
            tint(255,96,96); //Red is done
          } else {
            tint(255,255,255);
          }
          image(mTowerParts3[i].img,mTowerParts3[i].x,mTowerParts3[i].y,mTowerParts3[i].w,mTowerParts3[i].h);
        } else if ((i == lastSuccess /*|| i == lastSuccess+1*/) && millis()-curMilli < timePerBlock){
          //Time almost up
          float timeLeft = millis()-curMilli;
          float trans = 255 - 255*timeLeft/timePerBlock;
          tint(255-trans,255,64,trans);
          image(mTowerParts3[i].img,mTowerParts3[i].x,mTowerParts3[i].y,mTowerParts3[i].w,mTowerParts3[i].h);
        } else {
          //do nothing
        }
      }
    }
    
    if(state > 1){
      tint(255,255,255,255);
      image(level1Topper,0,0);
    }
    if(state > 3){
      tint(255,255,255,255);
      image(btcupola,0,0);
      image(btwindows,0,10);
    }
    if(state > 5){
      tint(255,255,255,255);
      image(p_main,0,0);
    }
  
  if(state == 0){
    playVideo(myMovie); //Call this method to play the movie
  } else if(state == 2){
    playVideo(myMovie2);
  } else if(state == 4){
    playVideo(myMovie4);
  } else if(state == 6){
    playVideo(myMovie6);
  }

  float proportion = (prevSpeed - speedMin)/(speedMax-speedMin);
    color c = color(0,255,0);
    if(proportion > 0.6){
      c = color(255,128,0);
    } else if(proportion > 0.8){
      c = color(255,0,0);
    }
  
  //If the mouse is off screen, indicate which direction   
  int newPartX = mouseX;
  int newPartY = mouseY;

  //Had screen inverted when I wrote this, hence the 800-? stuff
  boolean gotChaged = false;
  if(state <= 1){
    if(newPartY < 362) {newPartY = 362;gotChaged=true;}
    if(newPartY > 575) {newPartY = 575;gotChaged=true;}
    
    if(newPartX > 610) {newPartX = 610;gotChaged=true;}
    if(newPartX <= 610 && 
       newPartY >= 362 &&
       newPartY <= 575) {
         int xCutoff = 496 - (14*(newPartY-362)/213);
         if(newPartX < xCutoff) {newPartX = xCutoff;gotChaged=true;}
       } 
  } else if(state <= 3){
    if(newPartY < 317) {newPartY = 317;gotChaged=true;}
    if(newPartY > 570) {newPartY = 570;gotChaged=true;}
    if(newPartX >= 182 && newPartY >= 317 && newPartY <= 570){
      float xCutoff = 238 + (14*(newPartY-317))/255;
      if(newPartX > xCutoff) {newPartX = (int)xCutoff;gotChaged=true;}
    }
    if(newPartX < 182) {newPartX = 182;gotChaged=true;}
  } else if(state <= 5){
    if(newPartY < 104) {newPartY = 104;gotChaged=true;}
    if(newPartY > 272) {newPartY = 272;gotChaged=true;}
    if(newPartX > 490) {newPartX = 490;gotChaged=true;}
    
    if(newPartX <= 490 && newPartY >= 104 && newPartY <= 272){
      float xCutoff = 415 - (14*(newPartY-104))/168;
      if(newPartX < xCutoff) {newPartX = (int)xCutoff;gotChaged=true;}
    }  
  }
  
  oldPartX = newPartX;
  oldPartY = newPartY;
  //White means your cursor is off-scream
  if(gotChaged){
    c = color(255);
  }
  ps.addParticle(newPartX,newPartY,c);
  ps.run();
    
  //Mask, for safety!
  tint(255,255,255,255);
  image(maskImg,0,0);
    
}

void playVideo(Movie mm){
  float totalSeconds = mm.duration();               //Movie length in seconds     
  float timeLeft = mm.duration() - mm.time();  //Seconds left in the movie
  float time;                                            //used in calculating the faderate
  boolean fadingOut = false;
  float trans = 255;
  
  if(timeLeft < 3){   //If there are 3 seconds left in the movie, then begin to fade out
    trans = 255*timeLeft/3;
  } else if(mm.time() < 1.5){
    trans = 0; 
  } else if(mm.time() < 1.5+3){
    trans = 255*(mm.time()-1.5)/3;
  }
  
  if(timeLeft < 0.1){
    if(state == 0){
      endStateZero();
    } else if(state == 2){
      endStateTwo();
    } else if(state == 4){
      endStateFour();
    }
  }

  tint(255,255,255,trans);     //Tints the current frame
  float wscale = 1.0;
  float hscale = 1.0;
  if(mm.width < 800){
    wscale = 800.0/mm.width;
  }
  if(mm.height*wscale < 600){
    hscale = 600.0/mm.height;
  }
  int w = (int)(wscale*hscale*mm.width);
  int h = (int)(wscale*hscale*mm.height);
  
  if(state <= 1){
    image(mm,0,0,w,h); 
  } else if(state <= 3){
    image(mm,-(w-800),0,w,h);                     //Displays the current frame
  } else {
    image(mm,0,0,w,h); 
  }
}

void endStateZero(){
  state = 1;
  //birds1.pause();
  myMovie.jump(myMovie.duration());
}

void endStateTwo(){
  state = 3;
  speedMax = 20.0;
  myMovie2.jump(myMovie2.duration());
}

void endStateFour(){
  state = 5;
  myMovie4.jump(myMovie4.duration());
}

/*
void endStateSix(){
  state = 0;
  myMovie6.jump(myMovie6.duration());
}*/

void movieEvent(Movie m) {
  m.read();                              //reads in the next frame
}

void mouseClicked() {
  if(state != 0){
    gameRestart();
  } else {
    endStateZero();
  }
}

// A simple Particle class

class Particle {
  PVector location;
  PVector velocity;
  PVector acceleration;
  color  mColor;
  float lifespan;

  Particle(PVector l, color icolor) {
    acceleration = new PVector(0,0.025);

    float xdir = mouseX - lastMouseX;
    float ydir = mouseY - lastMouseY;
    
    velocity = new PVector(-xdir/15+random(-0.25,0.25),-ydir/15+random(-0.25,0.25));
    location = l.get();
    lifespan = 60;
    mColor = icolor;
  }

  void run() {
    update();
    display();
  }

  // Method to update location
  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    lifespan -= 1.0;
  }

  // Method to display
  void display() {
    stroke(red(mColor),green(mColor),blue(mColor),lifespan);
    fill(red(mColor),green(mColor),blue(mColor),lifespan);
    ellipse(location.x,location.y,4,4);
  }
  
  // Is the particle still useful?
  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}




// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;

  ParticleSystem() {
    particles = new ArrayList<Particle>();
  }

  void addParticle(int xLoc,int yLoc, color ic) {
    particles.add(new Particle(new PVector(xLoc,yLoc),ic));
  }

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}
