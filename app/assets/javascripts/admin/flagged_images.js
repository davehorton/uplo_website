var flagged_images = {
  setup_forms: function(){
    $('.action-container').delegate('.button.reinstate', 'click', function(e){
      var target = e.target;
      if(!$(target).hasClass('disabled')){
        flagged_images.do_action(target);
      }
    });

    $('.action-container').delegate('.button.remove', 'click', function(e){
      var target = e.target;
      if(!$(target).hasClass('disabled')){
        flagged_images.do_action(target);
      }
    });

    $('.action-container').delegate('#remove_flagged_images', 'click', function(e){
      var target = e.target;
      if(!$(target).hasClass('disabled')){
        flagged_images.do_action(target);
      }
    });

    $('.action-container').delegate('#reinstate_flagged_images', 'click', function(e){
      var target = e.target;
      if(!$(target).hasClass('disabled')){
        flagged_images.do_action(target);
      }
    });

    flagged_images.setup_image_popup();
  },

  do_action: function(user){
    $('#flagged-images-confirm-popup').modal();
    var message = $(user).attr('data-confirm');
    // Change the message on modal dialog.
    $('#flagged-images-confirm-popup').find('#confirm-message-container').text(message);

    $('#btn-ok').click(function(){
      $.modal.close();
      window.setTimeout("$('#mask').modal()", 200);
      var form = $(user).find('form.action-form');
      var post_url = $(form).attr('action');
      var params = $(form).serialize();

      if(!post_url || !params)
        return false;

      $.ajax({
        url: post_url,
        type: 'POST',
        data: params,
        success: function(response){
          var need_close_loading = true;

          if(response.status == 'ok'){
            $(user).addClass('disabled');

            var redirect_url = $.trim(response.redirect_url);
            if(redirect_url && redirect_url != ''){
              need_close_loading = false;
              window.location.href = redirect_url;
            }
          }
          else{
            if(jQuery.trim(response.message) != ''){
              helper.show_notification(response.message);
            }
          }

          if(need_close_loading)
            window.setTimeout("$.modal.close();", 200);
        }
      });
    });
  },

  setup_image_popup: function(){
    $(".image_frame, .flagged_image_container .image_name .image_link").click(function(e){
      e.preventDefault();

      var target_url = $.trim($(this).attr('data-url'));

      if(target_url == '')
        return false;

      $("#mask").modal();

      $.ajax({
        url: target_url,
        type: "GET",
        dataType: "json",
        success: function(data){
          $.modal.close();
          if (data.success) {
            setTimeout(flagged_images.show_popup, 100);
            $('#flagged_image_popup').html(data.data);
          }else{
            helper.show_notification(data.msg);
          }
        },
        error: function(){
          $.modal.close();
        }
      });
    });
  },

  show_popup: function(){
    $('#flagged_image_popup').modal();
  }
};
