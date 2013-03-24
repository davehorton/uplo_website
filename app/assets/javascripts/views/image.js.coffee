window.image =
  show_sharing_popup: ->
    btn_share = $(".actions .button.share")
    popup = document.createElement("div")
    popup.id = 'social-sharing-popup'
    popup.style.width = '200px'
    popup.style.height = '200px'
    popup.style.backgroundColor = 'yellow'
    popup.style.position = 'absolute'

    x_position = btn_share.position().left + btn_share.width()/2 - $(popup).width()/2
    y_position = btn_share.position().top - $(popup).height()
    popup.style.left = x_position + 'px'
    popup.style.top = y_position + 'px'

    $('body').append(popup)


$ ->
  $('form#frm-comment').inputHintOverlay(5, 8)
  $('#post-comment').click ->
    if($('#comment_description').val().trim() == '')
      $("#post-comment-warning").html('Comment cannot be blank!')
      return false

    data_form = $('#frm-comment')
    $.modal.close()
    window.setTimeout("$('#mask').modal()", 300)
    $.ajax({
      url: data_form.attr('action'),
      type: 'POST',
      data: data_form.serialize(),
      dataType: 'json',
      success: (response) ->
        if response.success
          $('#current_comments').html(response.comments)
          $('.comment .times').html(response.comments_number)
          $('.comment .label').html helper.pluralize_without_count(response.comments_number, 'Comment', 'Comments')
          $('#comment_description').val('')
          $('form#frm-comment').inputHintOverlay(5, 8)
          $("#post-comment-warning").html("")
        else
          $("#post-comment-warning").html(response.msg)
      error: ->
        helper.show_notification('Something went wrong!')
      complete: ->
        window.setTimeout("$.modal.close();", 400)
    });

  $('#comments-section').delegate '.pagination.comments a', 'click', (e) ->
    e.preventDefault()
    $.modal.close()
    window.setTimeout("$('#mask').modal()", 300)
    $.ajax({
      url: $(@).attr('href'),
      type: 'GET',
      dataType: 'json',
      data: { image_id: $('#comments-section').attr('data-id') }
      success: (response) ->
        if response.success
          $('#current_comments').html(response.comments)
          $.modal.close()
        else
          helper.show_notification('Something went wrong!')
          $.modal.close()
    });

  $('.image-container.medium').on 'contextmenu', ->
    alert('These photos are copyrighted by their respective owners. All rights reserved. Unauthorized use prohibited.')
    return false
