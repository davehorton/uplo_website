gallery = {
  setup: function(){
    helper.setup_async_image_tag("img.image-thumb");
    helper.setup_async_image_tag("img.gallery-cover-image");
    var target = "#gallery-form-container";
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
      
    // New gallery form
    $("#new-gallery").click(function(e){
      e.preventDefault();
      toggle_form();
    });
    
    // Ajax edit gallery.
    $("#edit-gallery").click(function(e){
      e.preventDefault();
         
      
      if(!$(target).hasClass("hidden") || $(target).find("form.gallery-form").length > 0){
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
