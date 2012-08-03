$ ->
  $('form#frm-emails').inputHintOverlay(10, 8)

  $('#incoming-invites').delegate '.button.accept', 'click', ->
    $('#mask').modal()
    $.ajax({
      url: 'invites/confirm_invitation_request',
      type: 'GET',
      dataType: 'json',
      data: { id: $(@).attr('data-id') }
      success: (response) ->
        if response.success
          $('#emails-container').html(response.emails)
          alert('The invitation has been sent!')
          $.modal.close()
        else
          alert(msg)
          $.modal.close()
      error: ->
        alert('Cannot invite this email right now! Please try again later!')
        $.modal.close()
    })
