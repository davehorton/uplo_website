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

$ ->
  $('.not-implement').click -> helper.alert_not_implement()
  $('#container .edit-pane[data-url!="#"]').click -> load($(@).attr('data-url'))
  $('#container .list[data-url!="#"]').click -> load($(@).attr('data-url'))
  $('#user-section .edit-pane').click -> $('#edit-profile-photo-popup').modal()

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

  $('#container').delegate '.follow', 'click', (e) ->
    target = $(e.target)
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
