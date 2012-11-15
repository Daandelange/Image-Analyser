// an instance of this class is created by the image_analyser class
// this class makes it possible to easily scan a particular zone in an image
// it's very basic and is made to be useful in image_analyser (might not be very handy for other tools)

class img_scanner {
  // for the row() and line() pointers;
  int row_pointer, line_pointer;
  
  int start_x, start_y, end_x, end_y;
  
  // variables for line/row stepping
  int prev_step_x, prev_step_y, offset_y, offset_x = 0;
  
  int shape_type; // shape of the zone being scanned (0=rect, 1=circle)
  int scan_method; // how the scanner advances to the next pixel (0=row_line, 1=line_row, 2=spiral)
  
  // setup the scanner class
  img_scanner( int x, int y, int w, int h, String scanning_method){
    // (re)set scanner variables
    // todo: add other variables for other scanning methods (spiral...)
    row_pointer = x;
    line_pointer = y;
    
    start_x = x;
    start_y = y;
    
    end_x = x + w;
    end_y = y + h;
    
    // our shape is a circle
    shape_type = 0;
    
    // (re)set scanning method
    if( scanning_method.equals("row_line") ) scan_method = 0;
    else if( scanning_method.equals("line_row") ) scan_method = 1;
    else if( scanning_method.equals("spiral") ) scan_method = 2;
    else scan_method = 0; // default is row_line for rectangles
    
    return;
  }
  
  // a crcular shape
  img_scanner( int x, int y, int rad, String scanning_method){
    // (re)set scanner variables
    row_pointer = x;
    line_pointer = y;
    
    start_x = x - rad;
    start_y = y - rad;
    
    end_x = x + rad;
    end_y = y + rad;
    
    // our shape is a circle
    shape_type = 1;
    
    // (re)set scanning method
    if( scanning_method.equals("row_line") ) scan_method = 0;
    else if( scanning_method.equals("line_row") ) scan_method = 1;
    else if( scanning_method.equals("spiral") ) scan_method = 2;
    else scan_method = 2; // default is a spiral for circles
    
    return;
  }
  
  // alternative ways to call this function
  //img_scanner( int x, int y, int w, int h, int step_x) {
    
  //}
  
  // some shape functions for easier-to-read syntax
  boolean is_rect(){
    return (shape_type == 0);
  }
  
  boolean is_circle(){
    return (shape_type == 1);
  }
  
  // utility to loop pixels of the image row by row
  boolean row() {
    return this.row(1);
  }
  boolean row(int step_size) {
    // there remain rows to scan
    if(row_pointer + step_size < end_x){
      prev_step_x = step_size;
      row_pointer += step_size;
      return true;
    }
    // end reached, reset pointer to new line
    else {
      row_pointer=0;
      prev_step_x = 0;
      return false;
    }
  }
  int get_x(){ return row_pointer + offset_x; }
  
  // utility to loop pixels of the image line by line
  boolean line() {
    return this.line(1);
  }
  boolean line(int step_size) {
    // there remain rows to scan
    if(line_pointer + step_size <= end_y){
      prev_step_y = step_size;
      line_pointer += step_size;
      return true;
    }
    // end reached, reset pointer to new line
    else {
      line_pointer=0;
      prev_step_y = 0;
      return false;
    }
  }
  
  // To get the current position: SCANNER.get_y();
  int get_y(){ return line_pointer + offset_y; }
  
  // This is an important function that handles the "stepper" to loop trough an image
  // usage: while( process( step_x, step_y ) ) { do_shit(); }
  // return TRUE to ask for another loop
  // must return FALSE when done
  // idea: add number of loops as argument in order to be able to play around with many scans
  //
  // args:
  // [stepx, stepy] Offset to take for each step (depending on shape figure)
  boolean process(int stepx, int stepy){
    // stepper system for the rectangled shapes
    // increments x and y positions
    if(this.scan_method == 0){
      
      // update x and y offsets
      offset_y = stepy - prev_step_y;
      offset_x = 0;
      offset_x = prev_step_x - stepx ;
      
      // scan some lines and rows
      return (
        // tricky and it works :p
        // increment a row; and when there's a new row, incremment a line.
        // when both are done, they will both return false.
        this.row(stepx) || this.line( stepy )
      );
    }
    
    else if(this.scan_method == 1){
      
      // update x and y offsets
      offset_x = prev_step_x - stepx ;
      offset_y = 0;
      
      // scan some lines and rows
      return (
        // tricky and it works :p
        // increment a row; and when there's a new row, incremment a line.
        // when both are done, they will both return false.
        this.line(stepy) || this.row( stepx )
      );
    }
    
    
    // spirals
    else if(this.scan_method == 2){
      
      // todo
    }
    
    // return if we did nothing
    return false; // nothing to do/ stop while loop
    
  }
  // variants of this function
  boolean process(int step){ return process( step, step ); }
  //boolean scan_rect( int x, int y, int w, int h, int step){ return scan_rect(x,y,w,h,step, step); }
  //boolean scan_rect( int x, int y, int w, int h){ return scan_rect(x,y,w,h,1,1); }
  
  // allow the scanned zone to be updated
  // just with variables xywh or also a greyscale map image? Make that a function apart ?
  
}

// idea --> add scan modes (ex: circular / spiral / row_line / completely_random / etc... )
