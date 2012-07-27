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
          if(response.status == 'ok'){
            $(user).addClass('disabled');
            
            var redirect_url = $.trim(response.redirect_url);
            if(redirect_url && redirect_url != ''){
              window.location.href = redirect_url;
            }
          }
          else{
            if(jQuery.trim(response.message) != ''){
              alert(response.message);
            }
          }         
          
          $.modal.close();
        }
      });
    });
  }
};
