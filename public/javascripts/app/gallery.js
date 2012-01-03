gallery = {
  setup: function(){
    $("img.image-thumb").jail({
      effect : "fadeIn"
    });
    
    var target = "#gallery-form-container";
    $("#edit-gallery").click(function(e){
      e.preventDefault();
      var toggle_form = function(){
        if($(target).hasClass("hidden")){
          $(target).removeClass("hidden");
          $(target).slideDown("fast");
          $(target).show();
        } else {
          // Hide the form and do nothing.
          $(target).slideUp("fast", function(){
            $(target).addClass("hidden");
          });
        }
      };   
      
      if(!$(target).hasClass("hidden")){
        toggle_form();
        return false;
      }
          
      var link = $(this);
      $.ajax({
        url: link.attr("href"), 
        type: 'GET',
        success: function(res){
          $(target).html(res);
          toggle_form();
        },
        
        error: function(){
        }
      });
    });
  }
};
