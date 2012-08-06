$ ->
  $('form#frm-invite').inputHintOverlay(10, 8)

  $('#btn-accept-all').click ->
    $('#mask').modal()
    ids = []
    $.each $('#incoming-invites .button.accept'), (idx, val) ->
      ids.push $(val).attr('data-id')
    console.log(ids)
    $.ajax({
      url: 'invites/confirm_invitation_request',
      type: 'GET',
      dataType: 'json',
      data: { ids: ids }
      success: (response) ->
        if response.success
          $('#emails-container').html(response.emails)
          alert('The invitation has been sent!')
          $.modal.close()
        else
          alert(response.msg)
          $.modal.close()
      error: ->
        alert('Cannot invite this email right now! Please try again later!')
        $.modal.close()
    })

  $('#incoming-invites').delegate '.button.accept', 'click', ->
    $('#mask').modal()
    $.ajax({
      url: 'invites/confirm_invitation_request',
      type: 'GET',
      dataType: 'json',
      data: { ids: [$(@).attr('data-id')] }
      success: (response) ->
        if response.success
          $('#emails-container').html(response.emails)
          alert('The invitation has been sent!')
          $.modal.close()
        else
          alert(response.msg)
          $.modal.close()
      error: ->
        alert('Cannot invite this email right now! Please try again later!')
        $.modal.close()
    })

  $('#btn-invite').click ->
    $('#mask').modal()
    $.ajax({
      url: 'invites/send_invitation',
      type: 'POST',
      dataType: 'json',
      data: $('#frm-invite').serialize(),
      success: (response) ->
        alert(response.msg)
        $.modal.close()
      error: ->
        alert('Cannot invite any emails right now! Please try again later!')
        $.modal.close()
    })
