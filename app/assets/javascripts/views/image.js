(function() {

  window.image = {
    show_sharing_popup: function() {
      var btn_share, popup, x_position, y_position;
      btn_share = $(".actions .button.share");
      popup = document.createElement("div");
      popup.id = 'social-sharing-popup';
      popup.style.width = '200px';
      popup.style.height = '200px';
      popup.style.backgroundColor = 'yellow';
      popup.style.position = 'absolute';
      x_position = btn_share.position().left + btn_share.width() / 2 - $(popup).width() / 2;
      y_position = btn_share.position().top - $(popup).height();
      popup.style.left = x_position + 'px';
      popup.style.top = y_position + 'px';
      return $('body').append(popup);
    }
  };

  $(function() {
    $('form#frm-comment').inputHintOverlay(5, 8);
    $('#post-comment').click(function() {
      var data_form;
      if ($('#comment_description').val().trim() === '') {
        $("#post-comment-warning").html('Comment cannot be blank!');
        return false;
      }
      data_form = $('#frm-comment');
      $.modal.close();
      window.setTimeout("$('#mask').modal()", 300);
      return $.ajax({
        url: data_form.attr('action'),
        type: 'POST',
        data: data_form.serialize(),
        dataType: 'json',
        success: function(response) {
          if (response.success) {
            $('#current_comments').html(response.comments);
            $('.comment .times').html(response.comments_number);
            $('.comment .label').html(helper.pluralize_without_count(response.comments_number, 'Comment', 'Comments'));
            $('#comment_description').val('');
            $('form#frm-comment').inputHintOverlay(5, 8);
            return $("#post-comment-warning").html("");
          } else {
            return $("#post-comment-warning").html(response.msg);
          }
        },
        error: function() {
          return helper.show_notification('Something went wrong!');
        },
        complete: function() {
          return window.setTimeout("$.modal.close();", 400);
        }
      });
    });
    $('#comments-section').delegate('.pagination.comments a', 'click', function(e) {
      e.preventDefault();
      $.modal.close();
      window.setTimeout("$('#mask').modal()", 300);
      return $.ajax({
        url: $(this).attr('href'),
        type: 'GET',
        dataType: 'json',
        data: {
          image_id: $('#comments-section').attr('data-id')
        },
        success: function(response) {
          if (response.success) {
            $('#current_comments').html(response.comments);
            return $.modal.close();
          } else {
            helper.show_notification('Something went wrong!');
            return $.modal.close();
          }
        }
      });
    });
    return $('.image-container.medium').on('contextmenu', function() {
      alert('These photos are copyrighted by their respective owners. All rights reserved. Unauthorized use prohibited.');
      return false;
    });
  });

}).call(this);

$(document).on("keypress", "textarea[maxlength]", function(event) {
  var key = event.which;
  
  //all keys including return.
  if(key >= 33 || key == 13 || key == 32) {
    var maxLength = $(this).attr("maxlength");
    var length = this.value.length;
    if(length >= maxLength) {                    
      event.preventDefault();
    }
  }
});