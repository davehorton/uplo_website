$("#gallery_permission").on("change", function(){
  if ($(this).val() == "public")
    $("#has-commission").hide();
  else
    $("#has-commission").show();
})

var gallery = {
  setup: function(){
    var target = "#gallery-form-container";
    var toggle_form = function(){
      if($(target).hasClass("hidden")){
        $(target).removeClass("hidden");
        $(target).slideDown("fast");
        $(target).show();
        if($('#edit-gallery').length > 0){
          $('#edit-gallery').addClass('text');
          $('#edit-gallery').addClass('highlight');
        }
      } else {
        // Hide the form and do nothing.
        $(target).slideUp("fast", function(){
          $(target).addClass("hidden");
          if($('#edit-gallery').length > 0){
            $('#edit-gallery').removeClass('text');
            $('#edit-gallery').removeClass('highlight');
          }
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
          $('#btn-gallery-cancel').click(function(){
            toggle_form();
          });
          $('#btn-gallery-save').click(function(){
            $('#frm-edit-gallery').submit();
          });
          toggle_form();
        },

        error: function(){
        }
      });
    });
  }
};
                                