/*
  
  flob part sys example
  a typical particle system influenced by blobs positions
  each particle has its own force towards all blobs
  André Sier 2010
  
  updated for processing 2.0
*/

import processing.opengl.*;
import processing.video.*;
import s373.flob.*;


Capture video;   
Flob flob;       
ArrayList blobs; 
PImage vrImage;
PSys psys;

int tresh = 20;   // adjust treshold value here or keys t/T
int fade = 25;
int om = 1;
int videores=128;
String info="";
PFont font;
float fps = 60;
int videotex = 0; //case 0: videotex = videoimg;//case 1: videotex = videotexbin; 
//case 2: videotex = videotexmotion//case 3: videotex = videoteximgmotion;



void setup() {

  size(1024,512,OPENGL);
  frameRate(fps);
  rectMode(CENTER);
  // init video data and stream
  video = new Capture(this, 320, 240, 30);// (int)fps);  
  video.start();

  vrImage = createImage(videores, videores, RGB);

  flob = new Flob(this, videores, videores, width, height);

  flob.setThresh(tresh).setSrcImage(videotex)
  .setBackground(vrImage).setBlur(0).setOm(1).
  setFade(fade).setMirror(true,false);

  font = createFont("monaco",10);
  textFont(font);

  psys = new PSys(2500);
  stroke(255,200);
  strokeWeight(2);
}



void draw() {

  if(video.available()) {
     video.read();
    vrImage.copy(video, 0, 0, 320, 240, 0, 0, videores, videores);
    blobs = flob.calc(flob.binarize(vrImage)); 
  }

  image(flob.getSrcImage(), 0, 0, width, height);

  rectMode(CENTER);

  int numblobs = flob.getNumBlobs();
  for(int i = 0; i < numblobs; i++) {
    ABlob ab = (ABlob)flob.getABlob(i); 
    psys.touch(ab);

    //box
    fill(0,0,255,100);
    rect(ab.cx,ab.cy,ab.dimx,ab.dimy);
    //centroid
    fill(0,255,0,200);
    rect(ab.cx,ab.cy, 5, 5);
    info = ""+ab.id+" "+ab.cx+" "+ab.cy;
    text(info,ab.cx,ab.cy+20);
  }

  psys.go();
  psys.draw();

  //report presence graphically
  fill(255,152,255);
  rectMode(CORNER);
  rect(5,5,flob.getPresencef()*width,10);
  String stats = ""+frameRate+"\nflob.numblobs: "+numblobs+"\nflob.thresh:"+tresh+
    " <t/T>"+"\nflob.fade:"+fade+"   <f/F>"+"\nflob.om:"+flob.getOm()+
    "\nflob.image:"+videotex+"\nflob.presence:"+flob.getPresencef();
  fill(0,255,0);
  text(stats,5,25);
}


void keyPressed() {

    if (key=='i') {  
    videotex = (videotex+1)%4;
    flob.setImage(videotex);
  }
  if(key=='t') {
    flob.setTresh(tresh--);
  }
  if(key=='T') {
    flob.setTresh(tresh++);
  }   
  if(key=='f') {
    flob.setFade(fade--);
  }
  if(key=='F') {
    flob.setFade(fade++);
  }   
  if(key=='o') {
    om=(om +1) % 3;
    flob.setOm(om);
  }   
  if(key==' ') //space clear flob.background
    flob.setBackground(video);
}

