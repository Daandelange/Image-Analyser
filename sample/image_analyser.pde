// a helper class to facilitate analysing images.
// ideas for later:
// - add ability to pre_scan images for faster processing while scanning -> calculating

class img_analyser {
  PImage img;
  int img_h, img_w;
  img_scanner main_scanner;

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

    // (re)set the scanner instance (by creating a fresh one)
    main_scanner = new img_scanner( 0, 0, img_h, img_w, "row_line");
  }

  // gets avgerage pixel data around a pixel of the loaded image.
  // units are pixels
  // use_importance will have farther pixels have less importance then the ones in the center
  // todo: rename this function to get_average_color with a shape argument
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
    // maybe this can be removed so that the scanner also scans zones outside of the image
    // drawing will only be possible on the image, but this will prevent getting those stupid borders around the image
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
    img_scanner scanner = new img_scanner( 0 , 0, img_h, img_w, "row_line");
    while( scanner.process(1) ){
    //for (int px = scan_x; px <= scan_x + scan_width; px++) {
      int px = scanner.get_x();
      int py = scanner.get_y();
      
      // every column
      //for (int py = scan_y; py <= scan_y + scan_height; py++) {
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
      //}
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
  
  // function to get a pixel (color format) with x and y rather than offset
  color pixel(int x, int y){
    // check values
    if(x < 0 || y < 0 || x > img_w || y > img_h) return color(0,0,0); // total darkness! mouhahahahaha
    
    // get the correct Y multiplier
    if(y > 0) y -= 1;
    
    return img.pixels[(int)( img_w * (y) + x )];
  }
  
  // color tool to return a more transparent color
  color fade(color c, int transparency){
    return color( red(c), green(c), blue(c), map(transparency, 0, 100, 0, 255));
  }
  
  // a function that allows you to search for a given color around a given pixel
  // it returns the [x,y] location of it
  // tolerance is from 0 to 1 and affect the color matching toleranc
  // force_return makes the function return the most matching color location if the tolerance parameter is not given.
  // use amount_of_colors to control the number of lacations returned. Set to 0 to return all matched colors.
  int[] get_same_color_around(int center_x, int center_y, int search_radius, float tolerance, boolean force_return, int amount_of_colors){
    // check if the center is located within the image
    // or maybe this isn't really necessary ... ? ... [or] maybe we should rather check if a color is within the scanned area.
    
    // the color is the one in the center
    color c = pixel(center_x, center_y);
    
    // loop trough each pixel around the center pixel
    
    
    // and finaly we return our amazing result :p
    return new int[2];
  }
  
  // a function that returns a float from 0 to 1
  // 0 = they dont match at all; 
  // 1 = they match perfectly
  float match_colors(color c1, color c2){
    // this calculates the difference between the R, G and B values.
    float diff_rgb = dist(red(c1), green(c1), blue(c1), red(c2), green(c2), blue(c2));
    
    // calculate the difference between HSL values.
    float diff_hsb = diff_rgb; // todo, but we haz not yet hsl conversion support :p
    
    // mix them and return
    return (float) ((diff_rgb+diff_hsb)/2);
  }
}

// todo and ideas
// enable parallel usage of multiple row() and line() --> create instances for them?
