helper.endless_load_more( ->
  if($(document).height() - 20  <= $(window).height())
    return $(window).scroll()
  else
    return $.modal.close()
)
load = (url, counter)->
  $('#mask').modal()
  $.ajax({
    url: url,
    type: 'GET',
    dataType: 'json',
    success: (response) ->
      plural_label = counter.replace('-counter', '')
      single_label = plural_label.replace(/[s]$/, '')
      count_label = helper.pluralize_without_count response.counter, single_label, plural_label
      $('#container').html response.html
      $("##{counter}").find('.info .number').text response.counter
      $("##{counter}").find('.info .label').text count_label
      $(window).scroll()
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
        alert(response.msg)
      else
        counter = $('.counter.current')
        url = counter.find('.info').attr('data-url')
        load(url, counter.attr('id'))
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
        counter = $('.counter.current')
        url = counter.find('.info').attr('data-url')
        load(url, counter.attr('id'))
        if counter.attr('id')=='followers-counter' && $.parseJSON($('#counters').attr('data-current-user').toString())
          $('#following-counter .number').text response.followings
      else
        target.attr('data-following', 'false')
        target.text('Follow')
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
    window.setTimeout("$('#mask').modal()", 300)
    target = $(node)
    $.ajax({
      url: target.attr('data-url'),
      type: "GET",
      data: { id: target.closest('.avatar').attr('data-id') },
      dataType: "json",
      success: (response) ->
        if(response.success==false)
          alert(response.msg)
          $.modal.close()
          window.setTimeout("$('#edit-profile-photo-popup').modal()", 300)
        else
          $('#edit-profile-photo-popup .current-photo .avatar').attr 'src', response.extra_avatar_url
          $('#user-section .avatar.large').attr 'src', response.large_avatar_url
          $('#edit-profile-photo-popup .held-photos .photos').html response.profile_photos
          alert('Delete successfully!')
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
        alert(response.msg)
      else
        alert('Update successfully!')
        $('#edit-profile-photo-popup .current-photo .avatar').attr 'src', response.extra_avatar_url
        $('#user-section .avatar.large').attr 'src', response.large_avatar_url
  })

$ ->
  $('.not-implement').click -> helper.alert_not_implement()
  $('#container .edit-pane').click ->
    counter_id = $(@).closest('.container').attr('id').replace('-section', '-counter')
    $('#counters .counter.current').removeClass('current')
    $("##{counter_id}").addClass('current')
    load $(@).attr('data-url'), counter_id

  $('#container .list[data-url!="#"]').click ->
    counter_id = $(@).closest('.container').attr('id').replace('-section', '-counter')
    $('#counters .counter.current').removeClass('current')
    $("##{counter_id}").addClass('current')
    load $(@).attr('data-url'), counter_id

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
        alert(response.msg)
        $.modal.close()
        window.setTimeout("$('#edit-profile-photo-popup').modal()", 300)
      else
        alert('Update successfully!')
        $('#edit-profile-photo-popup .held-photos .photos').html(response.profile_photos)
        $('#edit-profile-photo-popup .current-photo .avatar').attr 'src', response.extra_avatar_url
        $('#user-section .avatar.large').attr 'src', response.large_avatar_url
        $.modal.close()
        window.setTimeout("$('#edit-profile-photo-popup').modal()", 300)

  $('body').delegate '#edit-profile-photo-popup .held-photos .delete', 'click', (e) -> requestDeleteProfilePhoto(e.target)
  $('body').delegate '#edit-profile-photo-popup .held-photos img', 'click', (e) -> requestUpdateAvatar(e.target)

  $('#container').delegate '.follow', 'click', (e) -> requestFollow(e.target)
  $('#container').delegate '.like', 'click', (e) -> requestDislike(e.target)
  $('#counters .counter .info').click ->
    url = $(@).attr('data-url')
    counter = $(@).closest('.counter')
    if url != '#' && !counter.hasClass('current')
      $('#counters .counter.current').removeClass 'current'
      counter.addClass 'current'
      load url, counter.attr('id')

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
          $('.note').fadeIn()
        else
          $('#btn-follow').attr('data-following', 'false')
          $('#btn-follow').removeClass('unfollow')
          $('#btn-follow').addClass('follow')
          $('.note').fadeOut()
        $.modal.close()
    })

  $('#btn-update').click ->
    email_reg = /^([0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*@(([0-9a-zA-Z])+([-\w]*[0-9a-zA-Z])*\.)+[a-zA-Z]{2,9})$/i
    website_reg = /(^$)|(^((http|https):\/\/){0,1}[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/i
    if email_reg.test($('#user_email').val()) == false
      alert('Email is invalid!')
    else if website_reg.test($('#user_website').val()) == false
      alert('Website is invalid!')
    else if $("#user_first_name").val().length < 2 || $("#user_first_name").val().length > 30
      alert('First name must be 2 - 30 characters in length')
    else if $("#user_last_name").val().length < 2 || $("#user_last_name").val().length > 30
      alert('Last name must be 2 - 30 characters in length')
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
            alert("Your profile has been updated!")
            $('#user-section .name a').text response.fullname
            $.modal.close()
          else
            alert(response.msg)
            $.modal.close()
            window.setTimeout("$('#edit-profile-info-popup').modal()", 300)
      });

  $("#user_first_name").keypress (event) -> helper.prevent_exceed_characters(@, event.charCode, 30)
  $("#user_last_name").keypress (event) -> helper.prevent_exceed_characters(@, event.charCode, 30)
  $("#user_first_name").blur ->
    helper.check_less_than_characters(@.value, 2, -> alert('First name must be at least 2 characters!'))
  $("#user_last_name").blur ->
    helper.check_less_than_characters(@.value, 2, -> alert('Last name must be at least 2 characters!'))
