//= require 'lib/jquery.poshytip.js'

form_validation = {
  setup: function(input_fields){
    // Setup tool tip, require jquery.poshytip
    $(input_fields).poshytip({
      className: 'tip-yellow',
      showTimeout: 100,
      
      // To align on top
      //alignTo: 'target',
      //alignX: 'center',
      //offsetY: 5,
      //showOn: 'focus',
      
      // To align on right
      alignTo: 'target',
      alignX: 'right',
      alignY: 'center',
      offsetX: 5,
      
      allowTipHover: false
    });
  }
};
