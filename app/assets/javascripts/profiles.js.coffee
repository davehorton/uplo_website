load = (url, callback)->
  $('#mask').modal()
  $.ajax({
    url: url,
    type: 'GET',
    dataType: 'html',
    success: (response) ->
      $('#container')[0].innerHTML = response
      helper.endless_load_more( ->
        if($(document).height() <= $(window).height())
          $(window).scroll()
        return
      )
      $(window).scroll()
      $.modal.close()
  })

requestFollow = (node) ->
  target = $(node)
  author_id = target.attr('data-author-id')
  is_unfollow = target.attr('data-following')
  $('#mask').modal()
  $.ajax({
    url: '/users/follow',
    type: "GET",
    data: { user_id:author_id, unfollow: is_unfollow },
    dataType: "json",
    success: (response) ->
      if(response.success==false)
        alert(response.msg)
      else if(is_unfollow=='false')
        target.attr('data-following', 'true')
        target.text('Unfollow')
        $('#followers-counter .number').text response.followers
        $('#following-counter .number').text response.followings
        $('#followings-number').text "(#{response.followings})"
        $('#followers-number').text "(#{response.followers})"
      else
        target.attr('data-following', 'false')
        target.text('Follow')
        target.closest('.user-section.following').remove()
        $('#followers-counter .number').text response.followers
        $('#following-counter .number').text response.followings
        $('#followings-number').text "(#{response.followings})"
        $('#followers-number').text "(#{response.followers})"
      $.modal.close()
  })

requestDeleteProfilePhoto = (node) ->
  $.modal.close()
  window.setTimeout("$('#delete-confirm-popup').modal()", 300)
  $('#delete-confirm-popup #btn-ok').click ->
    target = $(node)
    $.ajax({
      url: target.attr('data-url'),
      type: "GET",
      data: { id: target.closest('.avatar').attr('data-id') },
      dataType: "json",
      success: (response) ->
        if(response.success==false)
          alert(response.msg)
        else
          $('#edit-profile-photo-popup .current-photo .avatar').attr 'src', response.extra_avatar_url
          $('#user-section .avatar.large').attr 'src', response.large_avatar_url
          $('#edit-profile-photo-popup .held-photos .photos')[0].innerHTML = response.profile_photos
          alert('Delete successfully!')
          $.modal.close()
    })

requestUpdateAvatar = (node) ->
  target = $(node)
  $.ajax({
    url: target.attr('data-url'),
    type: "GET",
    data: { id: target.closest('.avatar').attr('data-id') },
    dataType: "json",
    success: (response) ->
      if(response.success==false)
        alert(response.msg)
      else
        alert('Update successfully!')
        $('#edit-profile-photo-popup .current-photo .avatar').attr 'src', response.extra_avatar_url
        $('#user-section .avatar.large').attr 'src', response.large_avatar_url
  })

$ ->
  $('.not-implement').click -> helper.alert_not_implement()
  $('#container .edit-pane[data-url!="#"]').click -> load($(@).attr('data-url'))
  $('#container .list[data-url!="#"]').click -> load($(@).attr('data-url'))
  $('#user-section .avatar .edit-pane').click -> $('#edit-profile-photo-popup').modal({persist:true})
  $('#user-section .info .edit-pane').click -> $('#edit-profile-info-popup').modal({persist:true})

  $("#edit-profile-photo-popup #fileupload").fileupload()
  $("#edit-profile-photo-popup #fileupload").fileupload "option",
    maxFileSize: 5000000
    acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i
    add: (e, data) ->
      # data.context = renderUpload(data.files[0])
      # $('#mask').modal()
      data.submit()
    done: (e, data) ->
      if(data.result.success==false)
        alert(data.result.msg)
      else
        alert('Update successfully!')
        $('#edit-profile-photo-popup .current-photo .avatar').attr 'src', data.result.extra_avatar_url
        $('#user-section .avatar.large').attr 'src', data.result.large_avatar_url
        $('#edit-profile-photo-popup .held-photos .photos')[0].innerHTML = data.result.profile_photos


  $('body').delegate '#edit-profile-photo-popup .held-photos .delete', 'click', (e) -> requestDeleteProfilePhoto(e.target)
  $('body').delegate '#edit-profile-photo-popup .held-photos img', 'click', (e) -> requestUpdateAvatar(e.target)

  $('#container').delegate '.follow', 'click', (e) -> requestFollow(e.target)
  $('#counters .counter').click ->
    url = $(@).attr('data-url')
    if url != '#'
      load(url)

  $('#btn-follow').click ->
    author_id = $(@).attr('data-author-id')
    is_unfollow = $(@).attr('data-following')
    $('#mask').modal()
    $.ajax({
      url: '/users/follow',
      type: "GET",
      data: { user_id:author_id, unfollow: is_unfollow },
      dataType: "json",
      success: (response) ->
        if(response.success==false)
          alert(response.msg)
        else if(is_unfollow=='false')
          $('#btn-follow').attr('data-following', 'true')
          $('#btn-follow').removeClass('follow')
          $('#btn-follow').addClass('unfollow')
        else
          $('#btn-follow').attr('data-following', 'false')
          $('#btn-follow').removeClass('unfollow')
          $('#btn-follow').addClass('follow')
        $.modal.close()
    })

  $('#btn-update').click ->
    email_reg = /^([0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*@(([0-9a-zA-Z])+([-\w]*[0-9a-zA-Z])*\.)+[a-zA-Z]{2,9})$/i
    website_reg = /(^$)|(^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/i
    if email_reg.test($('#user_email').val()) == false
      alert('Email is invalid!')
    else if website_reg.test($('#user_website').val()) == false
      alert('Website is invalid!')
    else
      data_form = $('#frm-edit-profile-info')
      $.ajax({
        url: data_form.attr('action'),
        type: 'POST',
        data: data_form.serialize(),
        dataType: 'json',
        success: (response) ->
          if response.success
            alert("Your profile has been updated!")
            $.modal.close()
          else
            alert(response.msg)
      });
