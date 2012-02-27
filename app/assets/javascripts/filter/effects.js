
/* Predefine our effects as functions for easy calling. */
var EFFECTS = {
  
  e1 : function() {
  
    /* This is the starting point to apply filtrr on your images.
     * Using the img() function you can pass in an id or the img element,
     * and a callback function, to be called when the image has been loaded.
     * The callback function is given a filtr parameter which is a wrapper around
     * the canvas element, and contains all the filter and blending methods. 
     */
    filtrr.img("origin-pic", function(filtr) {
    
      /* filtr.duplicate() can be used to get a duplicate of the filtr object
       * so you can blend many together.*/
      var topFiltr = filtr.duplicate();
      
      /* filtr.core contains all the core filters. Filter calls can be chained.
       * filtr.blend contains all the blending modes. */
      topFiltr.core.saturation(0).blur();
      
      /* Here we are blending the topFiltr on top of the filtr object. */
      filtr.blend.multiply(topFiltr);
      
      /* All filters after a blending, will apply on the blended filtr object */
      filtr.core.tint([60, 35, 10], [170, 140, 160]).contrast(0.8).brightness(10);
      
      /* You need to call put() on a filtr object to see your filter applied on 
       * the image. This is explained in the commented version of filtrr.js */
      filtr.put();
      
      /* filtr also gives a reference to the underlying canvas object using filtr.canvas().
       * This is very useful in drawing frames or other images on top - so for example you 
       * can draw the white frame as in my example, or a wrinkly pattern.
       */
//      filtr.canvas().getContext("2d").drawImage(whiteFrame, 0, 0);
      
      /* Here I'm just removing the 'Working..' loader. */
      $("#loader").fadeOut(100);
      window.mask.hide();
    });  
  },
  
  e2 : function() {
    filtrr.img("origin-pic", function(filtr) {
      filtr.core.saturation(0.3).posterize(70).tint([50, 35, 10], [190, 190, 230]);  
      filtr.put();
//      filtr.canvas().getContext("2d").drawImage(whiteFrame, 0, 0);
      $("#loader").fadeOut(100);
      window.mask.hide();
    });
  },
  
  e3 : function() {
    filtrr.img("origin-pic", function(filtr) {
      filtr.core.tint([60, 35, 10], [170, 170, 230]).contrast(0.8);
      filtr.put();
//      filtr.canvas().getContext("2d").drawImage(whiteFrame, 0, 0);
      $("#loader").fadeOut(100);
      window.mask.hide();
    });
  },
  
  e4 : function() {
    filtrr.img("origin-pic", function(filtr) {
      filtr.core.grayScale().tint([60,60,30], [210, 210, 210]);
      filtr.put();
//      filtr.canvas().getContext("2d").drawImage(whiteFrame, 0, 0);
      $("#loader").fadeOut(100);
      window.mask.hide();
    });
  },
  
  e5 : function() {
    filtrr.img("origin-pic", function(filtr) {
      filtr.core.tint([30, 40, 30], [120, 170, 210])
            .contrast(0.75)
            .bias(1)
              .saturation(0.6)
              .brightness(20);
      filtr.put();
//      filtr.canvas().getContext("2d").drawImage(whiteFrame, 0, 0);
      $("#loader").fadeOut(100);
      window.mask.hide();
    });
  },
  
  e6 : function() {
    filtrr.img("origin-pic", function(filtr) {
      filtr.core.saturation(0.4).contrast(0.75).tint([20, 35, 10], [150, 160, 230]);
      filtr.put();
//      filtr.canvas().getContext("2d").drawImage(whiteFrame, 0, 0);
      $("#loader").fadeOut(100);
      window.mask.hide();
    });
  },
  
  e7 : function() {
    filtrr.img("origin-pic", function(filtr) {
      var topFiltr = filtr.duplicate();
      topFiltr.core.tint([20, 35, 10], [150, 160, 230]).saturation(0.6);
      filtr.core.adjust(0.1,0.7,0.4).saturation(0.6).contrast(0.8);
      filtr.blend.multiply(topFiltr);
      filtr.put();
//      filtr.canvas().getContext("2d").drawImage(whiteFrame, 0, 0);
      $("#loader").fadeOut(100);
      window.mask.hide();
    });
  },
  
  e8 : function() {
    filtrr.img("origin-pic", function(filtr) {
      
      /* In this example we are creating 3 different duplicate layers. Each one is filtered
       * and then blended on the filtr object. Note that you could say blend topFiltr1 and 
       * topFiltr2 together and then blend the resuln on filtr.
       */
      var topFiltr = filtr.duplicate();        
      var topFiltr1 = filtr.duplicate();
      var topFiltr2 = filtr.duplicate();
      topFiltr2.core.fill(167, 118, 12);
      topFiltr1.core.gaussianBlur();
      topFiltr.core.saturation(0);
      filtr.blend.overlay(topFiltr);
      filtr.blend.softLight(topFiltr1);
      filtr.blend.softLight(topFiltr2);
      filtr.core.saturation(0.5).contrast(0.86);
      filtr.put();
//      filtr.canvas().getContext("2d").drawImage(whiteFrame, 0, 0);
      $("#loader").fadeOut(100);
      window.mask.hide();
    });
  },
  
  e9 : function() {
    filtrr.img("origin-pic", function(filtr) {
      var topFiltr = filtr.duplicate();
      var topFiltr1 = filtr.duplicate();
      topFiltr1.core.fill(226, 217, 113).saturation(0.2);
      topFiltr.core.gaussianBlur().saturation(0.2);
      topFiltr.blend.multiply(topFiltr1);
      filtr.core.saturation(0.2).tint([30, 45, 40], [110, 190, 110]);
      filtr.blend.multiply(topFiltr);
      filtr.core.brightness(20).sharpen().contrast(1.1);
      filtr.put();
//      filtr.canvas().getContext("2d").drawImage(whiteFrame, 0, 0);
      $("#loader").fadeOut(100);
      window.mask.hide();
    });
  },
  
  e10 : function() {
    filtrr.img("origin-pic", function(filtr) {
      filtr.core.sepia().bias(0.6);
      filtr.put();
//      filtr.canvas().getContext("2d").drawImage(whiteFrame, 0, 0);
      $("#loader").fadeOut(100);
      window.mask.hide();
    });  
  }
};
 

