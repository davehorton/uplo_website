load = (url, counter)->
  $('#mask').modal()
  $.ajax({
    url: url,
    type: 'GET',
    dataType: 'json',
    success: (response) ->
      plural_label = counter.replace('-counter', '')
      if plural_label=='galleries'
        single_label = 'gallery'
      else
        single_label = plural_label.replace(/[s]$/, '')
      count_label = helper.pluralize_without_count response.counter, single_label, plural_label
      $('#container').html response.html
      $("##{counter}").find('.info .number').text response.counter
      $("##{counter}").find('.info .label').text count_label
      $(window).scroll()
      $.modal.close()
  })

requestDislike = (node) ->
  target = $(node)
  $('#mask').modal()
  $.ajax({
    url: '/unlike_image',
    type: "GET",
    data: { image_id: target.attr('data-id') },
    dataType: "json",
    success: (response) ->
      if(response.success==false)
        helper.show_notification(response.msg)
        $.modal.close()
      else
        counter = $('.counter.current')
        url = counter.find('.info').attr('data-url')
        load(url, counter.attr('id'))
  })

requestFollow = (node) ->
  target = $(node)
  author_id = target.attr('data-author-id')
  unfollow = target.attr('data-following')
  $('#mask').modal()
  $.ajax({
    url: '/users/follow',
    type: "GET",
    data: { user_id:author_id, unfollow: unfollow },
    dataType: "json",
    success: (response) ->
      if(response.success==false)
        helper.show_notification(response.msg)
        $.modal.close()

      else if(unfollow=='false')
        target.attr('data-following', 'true')
        target.removeClass('follow-small')
        target.addClass('unfollow-small')
        # target.text('Unfollow')
        counter = $('.counter.current')
        url = counter.find('.info').attr('data-url')
        load(url, counter.attr('id'))
        if counter.attr('id')=='followers-counter' && $.parseJSON($('#counters').attr('data-current-user').toString())
          $('#following-counter .number').text response.followings
      else
        target.attr('data-following', 'false')
        target.removeClass('unfollow-small')
        target.addClass('follow-small')
        # target.text('Follow')
        counter = $('.counter.current')
        url = counter.find('.info').attr('data-url')
        load(url, counter.attr('id'))
        if counter.attr('id')=='followers-counter' && $.parseJSON($('#counters').attr('data-current-user').toString())
          $('#following-counter .number').text response.followings
  })

requestDeleteProfilePhoto = (node) ->
  $.modal.close()
  window.setTimeout("$('#delete-confirm-popup').modal()", 300)
  $('#delete-confirm-popup #btn-ok').click ->
    $.modal.close()
    target = $(node)
    $.ajax({
      url: target.attr('data-url'),
      type: "GET",
      data: { id: target.closest('.avatar').attr('data-id') },
      dataType: "json",
      success: (response) ->
        if(response.success==false)
          helper.show_notification(response.msg)
          $.modal.close()
          window.setTimeout("$('#edit-profile-photo-popup').modal()", 300)
        else
          $('#edit-profile-photo-popup .current-photo .avatar').attr 'src', response.extra_avatar_url
          $('#user-section .avatar.large').attr 'src', response.large_avatar_url
          $('#edit-profile-photo-popup .held-photos .photos').html response.profile_photos
          helper.show_notification('Deleted successfully!')
          $.modal.close()
          window.setTimeout("$('#edit-profile-photo-popup').modal()", 300)
    })
  $('#delete-confirm-popup .button.cancel').click -> window.setTimeout("$('#edit-profile-photo-popup').modal()", 300)

requestUpdateAvatar = (node) ->
  target = $(node)
  $.ajax({
    url: target.attr('data-url'),
    type: "GET",
    data: { id: target.closest('.avatar').attr('data-id') },
    dataType: "json",
    success: (response) ->
      if(response.success==false)
        helper.show_notification(response.msg)
      else
        helper.show_notification('Updated successfully!')
        $('#edit-profile-photo-popup .current-photo .avatar').attr 'src', response.extra_avatar_url
        $('#user-section .avatar.large').attr 'src', response.large_avatar_url
  })

$ ->
  if($('#body-profiles').length)
    $.ajaxSetup({
      error: (xhr) ->
        if(xhr.status == 401 || xhr.status == 403)
          # Refresh page to show error when user was banned or removed.
          window.location.reload()
    })
    loading_elems = ['#likes-section .edit-pane', '#following-section .edit-pane', '#container .title', '.list']
    $.each loading_elems, (idx, val) ->
      $(val).click (e)->
        counter_id = $(@).closest('.container').attr('id').replace('-section', '-counter')
        $('#counters .counter.current').removeClass('current')
        $("##{counter_id}").addClass('current')
        url = $(@).attr('href')
        load(url, counter_id)
        return false

    $('#user-section .avatar .edit-pane').click -> $('#edit-profile-photo-popup').modal({persist:true})
    $('#user-section .info .edit-pane').click -> $('#edit-profile-info-popup').modal({persist:true})

    $("#edit-profile-photo-popup #fileupload").fileupload()
    $("#edit-profile-photo-popup #fileupload").fileupload "option",
      dataType: 'text'
      maxFileSize: 5000000
      acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i
      add: (e, data) ->
        $.modal.close()
        window.setTimeout("$('#mask').modal()", 300)
        data.submit()
      done: (e, data) ->
        response = $.parseJSON(data.result)
        if(response.success==false)
          helper.show_notification(response.msg)
          $.modal.close()
          window.setTimeout("$('#edit-profile-photo-popup').modal()", 300)
        else
          helper.show_notification('Updated successfully!')
          $('#edit-profile-photo-popup .held-photos .photos').html(response.profile_photos)
          $('#edit-profile-photo-popup .current-photo .avatar').attr 'src', response.extra_avatar_url
          $('#user-section .avatar.large').attr 'src', response.large_avatar_url
          $.modal.close()
          window.setTimeout("$('#edit-profile-photo-popup').modal()", 300)

    $('body').delegate '#edit-profile-photo-popup .held-photos .delete', 'click', (e) -> requestDeleteProfilePhoto(e.target)
    $('body').delegate '#edit-profile-photo-popup .held-photos img', 'click', (e) -> requestUpdateAvatar(e.target)

    $('#container').delegate '.user-section .button', 'click', (e) ->
      requestFollow(e.target)
    $('#container').delegate '.image-section .button', 'click', (e) ->
      requestDislike(e.target)
    $('#counters .counter .info').click ->
      url = $(@).attr('data-url')
      counter = $(@).closest('.counter')
      if url != '#' && !counter.hasClass('current')
        $('#counters .counter.current').removeClass 'current'
        counter.addClass 'current'
        load url, counter.attr('id')

    $('#btn-follow').click ->
      author_id = $(@).attr('data-author-id')
      unfollow = $(@).attr('data-following')
      $('#mask').modal()
      $.ajax({
        url: '/users/follow',
        type: "GET",
        data: { user_id:author_id, unfollow: unfollow },
        dataType: "json",
        success: (response) ->
          if(response.success==false)
            helper.show_notification(response.msg)
            $.modal.close()

          else if(unfollow=='false')
            $('#btn-follow').attr('data-following', 'true')
            $('#btn-follow').removeClass('follow')
            $('#btn-follow').addClass('unfollow')
            $('.note').fadeIn()
            if !$.parseJSON($('#counters').attr('data-current-user').toString())
              if $('.counter.current').attr('id') == 'followers-counter'
                load($('.counter.current .info').attr('data-url'), 'followers-counter')
              else
                $('#followers-counter .info .number').text(response.followee_followers)
                $('#followers-counter .info .label').text helper.pluralize_without_count(response.followee_followers, 'follower', 'followers')
                $.modal.close()
            else
              $.modal.close()
          else
            $('#btn-follow').attr('data-following', 'false')
            $('#btn-follow').removeClass('unfollow')
            $('#btn-follow').addClass('follow')
            $('.note').fadeOut()
            if !$.parseJSON($('#counters').attr('data-current-user').toString())
              if $('.counter.current').attr('id') == 'followers-counter'
                load($('.counter.current .info').attr('data-url'), 'followers-counter')
              else
                $('#followers-counter .info .number').text(response.followee_followers)
                $('#followers-counter .info .label').text helper.pluralize_without_count(response.followee_followers, 'follower', 'followers')
                $.modal.close()
            else
              $.modal.close()
      })

    $('#btn-update').click ->
      $('#frm-edit-profile-info').submit()
      return
      email_reg = /^([0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*@(([0-9a-zA-Z])+([-\w]*[0-9a-zA-Z])*\.)+[a-zA-Z]{2,9})$/i
      website_reg = /(^$)|(^((http|https):\/\/){0,1}[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/i
      if email_reg.test($('#user_email').val()) == false
        helper.show_notification('Email is invalid!')
      else if website_reg.test($('#user_website').val()) == false
        helper.show_notification('Website is invalid!')
      else if $("#user_first_name").val().length < 1 || $("#user_first_name").val().length > 30
        helper.show_notification('First name must be between 1 to 30 characters in length')
      else if $("#user_last_name").val().length < 1 || $("#user_last_name").val().length > 30
        helper.show_notification('Last name must between 1 to 30 characters in length')
      else
        data_form = $('#frm-edit-profile-info')
        $.modal.close()
        window.setTimeout("$('#mask').modal()", 300)
        $.ajax({
          url: data_form.attr('action'),
          type: 'POST',
          data: data_form.serialize(),
          dataType: 'json',
          success: (response) ->
            if response.success
              helper.show_notification("Your profile has been updated!")
              $('#user-section .name a').text response.fullname
              $.modal.close()
            else
              helper.show_notification(response.msg)
              $.modal.close()
              window.setTimeout("$('#edit-profile-info-popup').modal()", 300)
          ,
          error: ->
            helper.show_notification("Something went wrong!")
            $.modal.close()
            window.setTimeout("$('#edit-profile-info-popup').modal()", 300)
        });

    $("#user_first_name").keypress (event) -> helper.prevent_exceed_characters(@, event.charCode, 30)
    $("#user_last_name").keypress (event) -> helper.prevent_exceed_characters(@, event.charCode, 30)
    $("#user_first_name").blur ->
      helper.check_less_than_characters(@.value, 1, -> helper.show_notification('First name must be at least 1 character!'))
    $("#user_last_name").blur ->
      helper.check_less_than_characters(@.value, 1, -> helper.show_notification('Last name must be at least 1 character!'))
