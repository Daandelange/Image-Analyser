import processing.opengl.*;
import processing.pdf.*;
//import java.awt.Color;

// variables for saving to PDF
boolean savePDF = false;
boolean stop = false;

// program variables
PImage src_img;

// holds our scanner tool class
img_analyser src_scanner;

void setup() {
  
  // load image
  src_img = loadImage("pic.png");
  
  // set size depending on the image
  size( src_img.width, src_img.height, OPENGL );
  
  // load our image analyser class
  src_scanner = new img_analyser( src_img );
  
  // you could load more scanners if you need to scan more images
  //sampled_scanner = new img_analyser(sampled_img);
  
  // init some drawing settings
  ellipseMode(CENTER);
  rectMode(CENTER);
  
  // no need to pump CPU ressources to display the same image every frame
  noLoop();
  
  // enable anti-aliasing for smooth rendering
  smooth();
  
}

void draw() {
  // draw image (just to waste some memory) #funny
  image(src_img,0,0);
  
  
  // prepare some variables
  int step = 12;
  int rad = 20;
  
  // prepare for drawing (reset)
  stroke(0, 0, 0, 30);
  strokeWeight(1);
  noStroke();
  
  // scan some lines
  while( src_scanner.line(step) ){
    int y = src_scanner.get_line();
    
    // scan some rows
    while( src_scanner.row(step) ){
      int x = src_scanner.get_row();
      
      // analyse some data around the current pixel
      color c = src_scanner.get_circular_average(x, y, rad, true);
      
      // draw some circles depending on the results of the analyser
      noStroke();
      fill(src_scanner.fade(c, 50));
      int rad2 = (int) map(brightness(c), 0, 255, step/2, step); 
      ellipse(x, y, rad2*1.2, rad2*1.2);
      
      // put some lighter circles "above" all other pixels
      // ( a messy but effective solution to translate in front of the 2D drawing zone )
      pushMatrix();
      translate(0, 0, map(brightness(c), 0, 255, 0, 10) );
      ellipse(x, y, rad2*1.2, rad2*1.2);
      popMatrix();
      
      // draw some kind of tiny square
      stroke(0,0,0,40);
      strokeWeight(1);
      noStroke();
      fill(c);
      rect(x, y, 7,7);
      
      // update some variables depending on the current pixels (dynamic stepping, yesh :D )
      // this technique makes it look "less-digitalish"
      // (because we use data from the harmonious colors of our photo that is captured from an analogic environment)
      rad = (int) map(brightness(c), 0, 255, 30, 20);
      step = (int) map(saturation(c), 0, 255, 4, 25);
    }
    
  }
  
  
}

