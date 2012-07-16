//= require 'lib/jquery.center.js'

/**
 * Utility methods for image processing.
 */
image_util = {
  // Convert inch -> pixel
  inch_to_px: function(inch, dpi){
    if(!dpi)
      dpi = 75; // Default DPI
    return inch * dpi;
  },
  
  // Detect the curent DPI of the screen.
  // Requires: jQuery.
  detect_dpi: function(){
    var tmp_div = $('<div style="display: block; height: 1in; left: -100%; \
                    position: absolute; top: -100%;  width: 1in; padding:0; margin:0;"></div>');
    $('body').append(tmp_div);
    var width = $(tmp_div).width();
    $(tmp_div).remove();
    return width;
  },
  
  // Resize an image.
  // Requires: jquery.center.js plugin.
  resize_image: function(img, params){
    if(!params.ratio)
      params.ratio = 1.5;
      
    var new_w = params.width;
    var new_h = params.height;
    var correct_h = new_w / params.ratio;
    
    if(correct_h < new_h){
      new_w = new_h * params.ratio;
    }
    else {
      var correct_w = new_h * params.ratio;
      if(correct_w < new_w){
        new_h = correct_h;
      }
    }
    
    $(img).width(new_w).height(new_h);
    $(img).css('max-width', new_w);
    $(img).css('max-height', new_h);
    $(img).center();
    
    //console.log('output:' +  $(img).width() + 'x' + $(img).height());
  },
  
  resize_frame: function (img, auto){
    if(auto){
      $(parent).width('auto');
      $(parent).height('auto');
    }
    else{
      var width = $(img).width();
      var height = $(img).height();
      
      if(!width){
        width = parseInt($(img).attr('data-width'), 10);
      }
      var parent = $(img).parents('.image-container');
      var parent_width = parseInt($(parent).css('max-width'), 10);
      if(width > 0 && width <= parent_width){
        $(parent).width(width);
      }
      else if(width > 0 && width > parent_width){
        $(parent).width(parent_width);
      }
      
      if(height > 0)
        $(parent).height(height);
    }
  }
};
