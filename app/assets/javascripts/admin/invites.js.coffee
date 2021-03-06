$ ->
  $('form#frm-invite').inputHintOverlay(10, 8)

  $('#btn-accept-all').click ->
    $('#mask').modal()
    ids = []
    $.each $('#incoming-invites .button.accept'), (idx, val) ->
      ids.push $(val).attr('data-id')
    $.ajax({
      url: 'invites/confirm_request',
      type: 'GET',
      dataType: 'json',
      data: { ids: ids }
      success: (response) ->
        if response.success
          $('#emails-container').html(response.emails)
          $('#email_invitation_warning').html('Invite(s) sent!')
          $.modal.close()
        else
          $('#email_invitation_warning').html(response.msg)
          $.modal.close()
      error: ->
        $('#email_invitation_warning').html('Problem sending invite.')
        $.modal.close()
    })

  $('#incoming-invites').delegate '.button.accept', 'click', ->
    $('#mask').modal()
    $.ajax({
      url: 'invites/confirm_request',
      type: 'GET',
      dataType: 'json',
      data: { ids: [$(@).attr('data-id')] }
      success: (response) ->
        if response.success
          $('#emails-container').html(response.emails)
          $('#email_invitation_warning').html('Invite(s) sent!')
          $.modal.close()
        else
          $('#email_invitation_warning').html(response.msg)
          $.modal.close()
      error: ->
        $('#email_invitation_warning').html('Problem sending invite.')
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
        $('#email_invitation_warning').html(response.msg)
        $('#inv_emails').val('');
        $('#inv_message').val('');
        $.modal.close()
      error: ->
        $('#email_invitation_warning').html('Problem sending invite.')
        $.modal.close()
    })
