CARDNUM_VALIDATOR = /^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$/

window.CARD_TYPE_VALIDATORS = [
  { value: 'USA_express', reg: /^3[47][0-9]{13}$/ },
  { value: 'discover', reg: /^6(?:011|5[0-9]{2})[0-9]{12}$/ },
  { value: 'visa', reg: /^4[0-9]{12}(?:[0-9]{3})?$/ },
  { value: 'jcb', reg: /^(?:2131|1800|35\d{3})\d{11}$/ },
  { value: 'dinners_club', reg: /^3(?:0[0-5]|[68][0-9])[0-9]{11}$/ },
  { value: 'master_card', reg: /^5[1-5][0-9]{14}$/ }
]

$ ->
  $('#user_card_number').change ->
    card_type = $('#user_card_type').val()
    if card_type == ''
      helper.show_notification('Please choose card type!')
    else
      for validator in CARD_TYPE_VALIDATORS
        if validator.value == card_type
          if !validator.reg.test($(this).val())
            helper.show_notification('Your card number does not match ' + $('#user_card_type option:selected').text() + '!')
          break

  $('#user_card_type').change ->
    card_num = $('#user_card_number').val()
    for validator in CARD_TYPE_VALIDATORS
      if validator.value == $(this).val()
        if card_num!='' && !validator.reg.test(card_num)
          helper.show_notification('Your card number does not match ' + $('#user_card_type option:selected').text() + '!')
        break

  $('#cvv-explanation').click (e) ->
    cvv_form = $('#cvv-form')
    left = e.clientX - 155
    top = e.clientY - cvv_form.height()
    $('#cvv-form').modal({ opacity:5, overlayClose:true, position:[top, left]})
  $('#cvv-form .close').click -> $.modal.close()