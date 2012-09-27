// a helper class to facilitate analysing images.

class img_analyser {
  PImage img;
  int img_h, img_w;

  // for the row() and line() pointers;
  int row_pointer, line_pointer;

  // setup the analyser class
  img_analyser( PImage image_to_define ) {
    // load image
    load_image( image_to_define );
  }

  // loads the image into the class
  void load_image( PImage image_to_define ) {
    // register the image
    img = image_to_define;

    // set the dimensions
    img_h = img.height;
    img_w = img.width;

    // load its pixels
    img.loadPixels();

    // reset row and line pointers
    line_pointer = row_pointer = 0;
  }

  // gets avgerage pixel data around a pixel of the loaded image.
  // units are pixels
  // use_importance will have farther pixels have less importance then the ones in the center
  color get_circular_average(int x, int y, float rad, boolean use_importance) {
    //if(rad==null) rad=3.0;
    //if(use_importance=null) use_importance = true;

    // define the zone 2 be scanned
    // (we start with a square surface, then use an importance factor to limit it to a cercle)
    int scan_x = round( x - rad );  // calculate scan zone offset
    int scan_y = round( y - rad );
    int scan_width = (int) rad * 2; // calculate scan zone dimension
    int scan_height = (int) rad * 2;

    // define the area being scanned
    int[] zone = restrict_area_to_img(scan_x, scan_y, scan_width, scan_height);
    scan_x      = zone[0];
    scan_y      = zone[1];
    scan_width  = zone[2];
    scan_height = zone[3];

    // init returning data
    float[] result = new float[3]; // r,g,b
    float importance = 0.0; // holds the importance of the result values (to be divided)

    // start analysing each pixel around it
    // every line
    for (int px = scan_x; px <= scan_x + scan_width; px++) {

      // every column
      for (int py = scan_y; py <= scan_y + scan_height; py++) {
        // calculate the distance from the center
        float dst = dist(x, y, px, py);

        // zone out of reach?
        if ( dst > rad ) continue;

        // calculate some importance factors
        float tmp_importance;
        if (use_importance) {
          tmp_importance = 1 / sqrt(dst);

          // small fix for small dst values
          if (tmp_importance > 1) tmp_importance = 1;
        }
        else tmp_importance = 1;

        // cache the color being analysed
        color c = this.pixel( x, y );

        // add values to final result
        result[0] += red( c ) * tmp_importance;
        result[1] += green( c ) * tmp_importance;
        result[2] += blue( c ) * tmp_importance;
        importance += tmp_importance ;
      }
    }

    // sum values
    result[0] /= importance;
    result[1] /= importance;
    result[2] /= importance;

    // return
    return color(result[0], result[1], result[2]);
  }

  // this function restrains the scanned area to existing image surface.
  int[] restrict_area_to_img(int x, int y, int w, int h) {
    // left side
    if ( x < 0 ) x = 0;
    // top
    if ( y < 0 ) y = 0;
    // bottom
    if ( x + w > img_w ) w = img_w - x;
    // right side
    if ( y + h > img_h ) h = img_h - y;

    int[] ret = {
      x, y, w, h
    };
    return ret;
  }

  // utility to loop pixels of the image
  boolean row() {
    return this.row(1);
  }
  boolean row(int step_size) {
    // there remain rows to scan
    if(row_pointer + step_size < img_w){
      row_pointer += step_size;
      return true;
    }
    // end reached, reset pointer to new line
    else {
      row_pointer=0;
      return false;
    }
  }
  int get_row(){ return row_pointer; }
  
  boolean line() {
    return this.line(1);
  }
  boolean line(int step_size) {
    // there remain rows to scan
    if(line_pointer + step_size <= img_h){
      line_pointer += step_size;
      return true;
    }
    // end reached, reset pointer to new line
    else {
      line_pointer=0;
      return false;
    }
  }
  int get_line(){ return line_pointer; }
  
  // function to get a pixel (color format) with x and y rather than offset
  color pixel(int x, int y){
    // check values
    if(x < 0 || y < 0 || x > img_w || y > img_h) return color(0,0,0); // total darkness! mouhahahahaha
    
    return img.pixels[(int)( img_w * (y-1) + x )];
  }
  
  // color tool to return a more transparent color
  color fade(color c, int transparency){
    return color( red(c), green(c), blue(c), map(transparency, 0, 100, 0, 255));
  }
}

