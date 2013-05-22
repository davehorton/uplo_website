(function() {
  var displayPaginatedItems, load, requestDeleteProfilePhoto, requestDislike, requestFollow, requestUpdateAvatar;

  load = function(url, counter) {
    $('#mask').modal();
    return $.ajax({
      url: url,
      type: 'GET',
      dataType: 'json',
      success: function(response) {
        var count_label, plural_label, single_label;
        plural_label = counter.replace('-counter', '');
        if (plural_label === 'galleries') {
          single_label = 'gallery';
        } else {
          single_label = plural_label.replace(/[s]$/, '');
        }
        count_label = helper.pluralize_without_count(response.counter, single_label, plural_label);
        $('#container').html(response.html);
        $("#" + counter).find('.info .number').text(response.counter);
        $("#" + counter).find('.info .label').text(count_label);
        $(window).scroll();
        return $.modal.close();
      }
    });
  };

  requestDislike = function(node) {
    var target;
    target = $(node);
    $('#mask').modal();
    return $.ajax({
      url: '/unlike_image',
      type: "GET",
      data: {
        image_id: target.attr('data-id')
      },
      dataType: "json",
      success: function(response) {
        var counter, url;
        if (response.success === false) {
          helper.show_notification(response.msg);
          return $.modal.close();
        } else {
          counter = $('.counter.current');
          url = counter.find('.info').attr('data-url');
          return load(url, counter.attr('id'));
        }
      }
    });
  };

  requestFollow = function(node) {
    var author_id, target, unfollow;
    target = $(node);
    author_id = target.attr('data-author-id');
    unfollow = target.attr('data-following');
    $('#mask').modal();
    return $.ajax({
      url: '/users/follow',
      type: "GET",
      data: {
        user_id: author_id,
        unfollow: unfollow
      },
      dataType: "json",
      success: function(response) {
        var counter, url;
        if (response.success === false) {
          helper.show_notification(response.msg);
          return $.modal.close();
        } else if (unfollow === 'false') {
          target.attr('data-following', 'true');
          target.removeClass('follow-small');
          target.addClass('unfollow-small');
          counter = $('.counter.current');
          url = counter.find('.info').attr('data-url');
          load(url, counter.attr('id'));
          if (counter.attr('id') === 'followers-counter' && $.parseJSON($('#counters').attr('data-current-user').toString())) {
            return $('#following-counter .number').text(response.followings);
          }
        } else {
          target.attr('data-following', 'false');
          target.removeClass('unfollow-small');
          target.addClass('follow-small');
          counter = $('.counter.current');
          url = counter.find('.info').attr('data-url');
          load(url, counter.attr('id'));
          if (counter.attr('id') === 'followers-counter' && $.parseJSON($('#counters').attr('data-current-user').toString())) {
            return $('#following-counter .number').text(response.followings);
          }
        }
      }
    });
  };

  requestDeleteProfilePhoto = function(node) {
    $.modal.close();
    window.setTimeout("$('#delete-confirm-popup').modal()", 300);
    $('#delete-confirm-popup #btn-ok').click(function() {
      var target;
      $.modal.close();
      target = $(node);
      return $.ajax({
        url: target.attr('data-url'),
        type: "GET",
        data: {
          id: target.closest('.avatar').attr('data-id')
        },
        dataType: "json",
        success: function(response) {
          if (response.success === false) {
            helper.show_notification(response.msg);
            $.modal.close();
            return window.setTimeout("$('#edit-profile-photo-popup').modal()", 300);
          } else {
            $('#edit-profile-photo-popup .current-photo .avatar').attr('src', response.extra_avatar_url);
            $('#user-section .avatar.large').attr('src', response.large_avatar_url);
            $('#edit-profile-photo-popup .held-photos .photos').html(response.profile_photos);
            helper.show_notification('Deleted successfully!');
            $.modal.close();
            return window.setTimeout("$('#edit-profile-photo-popup').modal()", 300);
          }
        }
      });
    });
    return $('#delete-confirm-popup .button.cancel').click(function() {
      return window.setTimeout("$('#edit-profile-photo-popup').modal()", 300);
    });
  };

  requestUpdateAvatar = function(node) {
    var target;
    target = $(node);
    return $.ajax({
      url: target.attr('data-url'),
      type: "GET",
      data: {
        id: target.closest('.avatar').attr('data-id')
      },
      dataType: "json",
      success: function(response) {
        if (response.success === false) {
          return helper.show_notification(response.msg);
        } else {
          helper.show_notification('Updated successfully!');
          $('#edit-profile-photo-popup .current-photo .avatar').attr('src', response.extra_avatar_url);
          return $('#user-section .avatar.large').attr('src', response.large_avatar_url);
        }
      }
    });
  };

  displayPaginatedItems = function(node) {
    return $.ajax({
      url: $(node).attr('href'),
      dataType: 'json',
      success: function(response) {
        $('#endless-pages').html(response.items);
        return $('.pagination').each(function(idx, elem) {
          return $(elem).html(response.pagination);
        });
      }
    });
  };

  $(function() {
    var loading_elems;
    if (($('#body-profiles').length)) {
      $.ajaxSetup({
        error: function(xhr) {
          if (xhr.status === 401 || xhr.status === 403) {
            return window.location.reload();
          }
        }
      });
      loading_elems = ['#likes-section .edit-pane', '#following-section .edit-pane', '#container .title', '.list'];
      $.each(loading_elems, function(idx, val) {
        return $(val).click(function(e) {
          var counter_id, url;
          counter_id = $(this).closest('.container').attr('id').replace('-section', '-counter');
          $('#counters .counter.current').removeClass('current');
          $("#" + counter_id).addClass('current');
          url = $(this).attr('href');
          load(url, counter_id);
          return false;
        });
      });
      $('#user-section .avatar .edit-pane').click(function() {
        return $('#edit-profile-photo-popup').modal({
          persist: true
        });
      });
      $('#user-section .info .edit-pane').click(function() {
        return $('#edit-profile-info-popup').modal({
          persist: true
        });
      });
      $("#edit-profile-photo-popup #fileupload").fileupload();
      $("#edit-profile-photo-popup #fileupload").fileupload("option", {
        dataType: 'text',
        maxFileSize: 20000000,
        acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i,
        add: function(e, data) {
          $.modal.close();
          window.setTimeout("$('#mask').modal()", 300);
          return data.submit();
        },
        done: function(e, data) {
          var response;
          response = $.parseJSON(data.result);
          if (response.success === false) {
            helper.show_notification(response.msg);
            $.modal.close();
            return window.setTimeout("$('#edit-profile-photo-popup').modal()", 300);
          } else {
            helper.show_notification('Updated successfully!');
            $('#edit-profile-photo-popup .held-photos .photos').html(response.profile_photos);
            $('#edit-profile-photo-popup .current-photo .avatar').attr('src', response.extra_avatar_url);
            $('#user-section .avatar.large').attr('src', response.large_avatar_url);
            $.modal.close();
            return window.setTimeout("$('#edit-profile-photo-popup').modal()", 300);
          }
        }
      });
      $('body').delegate('#edit-profile-photo-popup .held-photos .delete', 'click', function(e) {
        return requestDeleteProfilePhoto(e.target);
      });
      $('body').delegate('#edit-profile-photo-popup .held-photos img', 'click', function(e) {
        return requestUpdateAvatar(e.target);
      });
      $(document).on('click', '.pagination a', function(e) {
        e.preventDefault();
        return displayPaginatedItems(e.target);
      });
      $('#container').delegate('.user-section .button', 'click', function(e) {
        return requestFollow(e.target);
      });
      $('#container').delegate('.image-section .button', 'click', function(e) {
        return requestDislike(e.target);
      });
      $('#counters .counter .info').click(function() {
        var counter, url;
        url = $(this).attr('data-url');
        counter = $(this).closest('.counter');
        if (url !== '#' && !counter.hasClass('current')) {
          $('#counters .counter.current').removeClass('current');
          counter.addClass('current');
          return load(url, counter.attr('id'));
        }
      });
      $('#btn-follow').click(function() {
        var author_id, unfollow;
        author_id = $(this).attr('data-author-id');
        unfollow = $(this).attr('data-following');
        $('#mask').modal();
        return $.ajax({
          url: '/users/follow',
          type: "GET",
          data: {
            user_id: author_id,
            unfollow: unfollow
          },
          dataType: "json",
          success: function(response) {
            if (response.success === false) {
              helper.show_notification(response.msg);
              return $.modal.close();
            } else if (unfollow === 'false') {
              $('#btn-follow').attr('data-following', 'true');
              $('#btn-follow').removeClass('follow');
              $('#btn-follow').addClass('unfollow');
              $('.note').fadeIn();
              if (!$.parseJSON($('#counters').attr('data-current-user').toString())) {
                if ($('.counter.current').attr('id') === 'followers-counter') {
                  return load($('.counter.current .info').attr('data-url'), 'followers-counter');
                } else {
                  $('#followers-counter .info .number').text(response.followee_followers);
                  $('#followers-counter .info .label').text(helper.pluralize_without_count(response.followee_followers, 'follower', 'followers'));
                  return $.modal.close();
                }
              } else {
                return $.modal.close();
              }
            } else {
              $('#btn-follow').attr('data-following', 'false');
              $('#btn-follow').removeClass('unfollow');
              $('#btn-follow').addClass('follow');
              $('.note').fadeOut();
              if (!$.parseJSON($('#counters').attr('data-current-user').toString())) {
                if ($('.counter.current').attr('id') === 'followers-counter') {
                  return load($('.counter.current .info').attr('data-url'), 'followers-counter');
                } else {
                  $('#followers-counter .info .number').text(response.followee_followers);
                  $('#followers-counter .info .label').text(helper.pluralize_without_count(response.followee_followers, 'follower', 'followers'));
                  return $.modal.close();
                }
              } else {
                return $.modal.close();
              }
            }
          }
        });
      });
      $('#btn-update').click(function() {
        var data_form, email_reg, website_reg;
        $('#frm-edit-profile-info').submit();
        return;
        email_reg = /^([0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*@(([0-9a-zA-Z])+([-\w]*[0-9a-zA-Z])*\.)+[a-zA-Z]{2,9})$/i;
        website_reg = /(^$)|(^((http|https):\/\/){0,1}[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/i;
        if (email_reg.test($('#user_email').val()) === false) {
          return helper.show_notification('Email is invalid!');
        } else if (website_reg.test($('#user_website').val()) === false) {
          return helper.show_notification('Website is invalid!');
        } else if ($("#user_first_name").val().length < 1 || $("#user_first_name").val().length > 30) {
          return helper.show_notification('First name must be between 1 to 30 characters in length');
        } else if ($("#user_last_name").val().length < 1 || $("#user_last_name").val().length > 30) {
          return helper.show_notification('Last name must between 1 to 30 characters in length');
        } else {
          data_form = $('#frm-edit-profile-info');
          $.modal.close();
          window.setTimeout("$('#mask').modal()", 300);
          return $.ajax({
            url: data_form.attr('action'),
            type: 'POST',
            data: data_form.serialize(),
            dataType: 'json',
            success: function(response) {
              if (response.success) {
                helper.show_notification("Your profile has been updated!");
                $('#user-section .name a').text(response.fullname);
                return $.modal.close();
              } else {
                helper.show_notification(response.msg);
                $.modal.close();
                return window.setTimeout("$('#edit-profile-info-popup').modal()", 300);
              }
            },
            error: function() {
              helper.show_notification("Something went wrong!");
              $.modal.close();
              return window.setTimeout("$('#edit-profile-info-popup').modal()", 300);
            }
          });
        }
      });
      $("#user_first_name").keypress(function(event) {
        return helper.prevent_exceed_characters(this, event.charCode, 30);
      });
      $("#user_last_name").keypress(function(event) {
        return helper.prevent_exceed_characters(this, event.charCode, 30);
      });
      $("#user_first_name").blur(function() {
        return helper.check_less_than_characters(this.value, 1, function() {
          return helper.show_notification('First name must be at least 1 character!');
        });
      });
      return $("#user_last_name").blur(function() {
        return helper.check_less_than_characters(this.value, 1, function() {
          return helper.show_notification('Last name must be at least 1 character!');
        });
      });
    }
  });

}).call(this);