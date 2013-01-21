import processing.video.*;

// objects
class Letter {
    PVector vel;
    PVector pos; 
    char ch;
    color col;
};

// global vars
int videoWidth = 640;
int videoHeight = 480;
Capture cap; // video capture device

ArrayList<Letter> LetterList = new ArrayList<Letter>(); // the list that will hold the particles
  
float letterXOffset = 10; // how far we should draw the individual letters
float letterYOffset = 400; // how far every sentance should be
float collisionThreshold = 30; // haw dark the areas of collision must be
PFont font;

void setup() {
  size(640,480);

  // initalizes video capture
  cap = new Capture(this, videoWidth, videoHeight);
  cap.start();
  
  // read text and launch "particles"
  launchSentances();
 
  // setup display font
  font = createFont("Helvetica Bold", 16, true);
  textFont(font, 16);
}

void launchSentances() {
  
  // read sentances from a file
  String lines[] = loadStrings("text.txt");

  for(int lineNum = 0;lineNum < lines.length;lineNum++) {
    String sentance = lines[lineNum];
    int setanceLength = sentance.length();
    for(int i=0;i<setanceLength;i++) {
      char character = sentance.charAt(i);
      if(character == ' ') continue;
      Letter l = new Letter();
      l.ch = character;
      l.pos = new PVector(letterXOffset * i, -lineNum * letterYOffset-letterYOffset/4 ,0.0);
      l.vel = new PVector(0.0,0.5 + random(0,0.1),0.0);
      l.col = color(255,255,255);
      LetterList.add(l);
    }  
  }

}

void update() {
  // read video feed
  if(cap.available()) {
    cap.read(); 
    cap.loadPixels();
  }

  for(int i=0;i<LetterList.size();i++) {
     Letter l = LetterList.get(i);
     // if the letter is not colliding continue down
     if(!isColliding(l.pos))
       l.pos.add(l.vel);
 
     // if we reach the bottom, go at the top again
     if(l.pos.y > height) {
       l.pos.y -= height+letterYOffset;
     }
  }
   
}

boolean isColliding(PVector pos) {
  float radius = 10.0;
  if(pos.y > radius && pos.y <= videoHeight-radius && pos.x >=0 && pos.x < videoWidth) {
    PVector pixelPos = pos.get();
    pixelPos.add(0.0,radius,0.0);
    int pixelIndex = floor(pixelPos.x) + floor(pixelPos.y)*videoWidth;
    color pixelColor = cap.pixels[pixelIndex];
  
    if(brightness(pixelColor) < collisionThreshold)
        return true;
  }
  return false;
}

void draw() {
  update();
  
  background(0);
  image(cap,0,0); 
       
  for(int i=0;i<LetterList.size();i++) {
       Letter l = LetterList.get(i);
       if(l.pos.y >= 0.0) {
         fill(l.col, 255 - abs(map(l.pos.y,0,height,-200,200)));
         text(l.ch, l.pos.x, l.pos.y);
       }
  }

}



