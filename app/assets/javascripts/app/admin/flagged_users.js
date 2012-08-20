flagged_users = {
  setup_forms: function(){
    $('.action-container').delegate('.button.reinstate', 'click', function(e){
      var target = e.target;
      if(!$(target).hasClass('disabled')){
        flagged_users.do_action(target);
      }
    });
    
    $('.action-container').delegate('.button.remove', 'click', function(e){
      var target = e.target;
      if(!$(target).hasClass('disabled')){
        flagged_users.do_action(target);
      }
    });
    
    $('.action-container').delegate('#remove_flagged_users', 'click', function(e){
      var target = e.target;
      if(!$(target).hasClass('disabled')){
        flagged_users.do_action(target);
      }
    });
    
    $('.action-container').delegate('#reinstate_flagged_users', 'click', function(e){
      var target = e.target;
      if(!$(target).hasClass('disabled')){
        flagged_users.do_action(target);
      }
    });
    
    // Setup tool tip, require jquery.poshytip
    $('.button.tooltip').poshytip({
      className: 'tip-yellowsimple',
      showTimeout: 100,
      alignTo: 'target',
      alignX: 'center',
      offsetY: 5,
      allowTipHover: false
    });
  },
  
  do_action: function(user){
    $('#flagged-users-confirm-popup').modal();
    var message = $(user).attr('data-confirm');    
    // Change the message on modal dialog.
    $('#flagged-users-confirm-popup').find('#confirm-message-container').text(message);
    
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
            $.modal.close(); 
        }
      });
    });
  }
};
