spotlights = {
  setup_promote_popup: function(){
    $('.image-container').delegate('.promote-button', 'click', function(e){
      var target = e.target;
      if(!$(target).hasClass('disabled')){
        spotlights.do_promote_photo(target)
      }
    });
  },
  
  do_promote_photo: function(photo){
    $('#promote-confirm-popup').modal();
    $('#btn-ok').click(function(){
      $.modal.close();
      window.setTimeout("$('#mask').modal()", 500);
      var form = $(photo).find('form.promote-photo-form');
      var post_url = $(form).attr('action');
      var params = $(form).serialize();
      console.log(post_url);
      console.log(params);
      
      if(!post_url || !params)
        return false;
        
      $.ajax({
        url: post_url,
        type: 'POST',
        data: params,
        success: function(response){
          if(response.status == 'ok'){
            $(photo).addClass('disabled');
          }
          
          if(jQuery.trim(response.message) != ''){
            alert(response.message);
          }
          
          $.modal.close();
        }
      });
    });
  }
};
