var spotlights = {
  setup_promote_popup: function(){
    $('.image-container').delegate('.promote-button', 'click', function(e){
      var target = e.target;
      spotlights.do_promote_photo(target);
    });
  },

  do_promote_photo: function(photo){
    $('#promote-confirm-popup').modal();
    var message = "";
    var on_promoting = true;
    if($(photo).hasClass('disabled')){
      message = $('#promote-confirm-popup-container').attr('data-demote-confirm');
      on_promoting = false;
    }
    else{
      message = $('#promote-confirm-popup-container').attr('data-promote-confirm');
      on_promoting = true;
    }

    // Change the message on modal dialog.
    $('#promote-confirm-popup').find('#confirm-message-container').text(message);

    $('#btn-ok').click(function(){
      $.modal.close();
      window.setTimeout("$('#mask').modal()", 200);
      var form = $(photo).find('form.promote-photo-form');
      var post_url = $(form).attr('action');
      var params = $(form).serialize();

      if(!post_url || !params)
        return false;

      $.ajax({
        url: post_url,
        type: 'POST',
        data: params,
        success: function(response){
          if(response.status == 'ok'){
            var url = $.url(post_url);
            var params = url.param();

            if(on_promoting){
              $(photo).addClass('disabled');
              // Change parent container style
              $(photo).parents(".image-container").addClass('promoted');
              params['demote'] = true;
            }
            else{
              $(photo).removeClass('disabled');
              $(photo).parents(".image-container").removeClass('promoted');
              delete params['demote'];
            }

            post_url = url.attr('path') + "?" + $.param(params);
            // Change the form action URL.
            $(form).attr('action', post_url);
          }
          else{
            if(jQuery.trim(response.message) != ''){
              helper.show_notification(response.message);
            }
          }

          $.modal.close();
        }
      });
    });
  }
};
