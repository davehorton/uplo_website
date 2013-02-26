CARDNUM_VALIDATOR = /^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$/

window.CARD_TYPE_VALIDATORS = [
  { value: 'USA_express', reg: /^3[47][0-9]{13}$/ },
  { value: 'discover', reg: /^6(?:011|5[0-9]{2})[0-9]{12}$/ },
  { value: 'visa', reg: /^4[0-9]{12}(?:[0-9]{3})?$/ },
  { value: 'jcb', reg: /^(?:2131|1800|35\d{3})\d{11}$/ },
  { value: 'dinners_club', reg: /^3(?:0[0-5]|[68][0-9])[0-9]{11}$/ },
  { value: 'master_card', reg: /^5[1-5][0-9]{14}$/ }
]

computeTax = (region) ->
  has_tax = false
  grand_total_elm = $('#grand-total')

  $.each regions_tax, (key, val) ->
    if region == val.state_code
      has_tax = true
      total_tax = 0
      grand_total = 0
      shipping_fee = parseFloat($('#shipping_fee').text().replace(/[$]/g, ''))

      $.each $('#order-summary .price'), (idx, elm) ->
        price_elm = $(elm)
        price = parseFloat price_elm.text().replace(/[$]/g, '')
        tax = price * val.tax
        total_tax += tax
        grand_total += (tax + price)
        price_elm.closest('.block').find('.tax').text "$#{tax.toFixed(2)}"
      grand_total += shipping_fee
      $('#order-summary .summary .tax').text "$#{total_tax.toFixed(2)}"
      grand_total_elm.text "$#{grand_total.toFixed(2)}"

  unless has_tax
    grand_total = 0
    $.each $('#order-summary .price'), (idx, elm) ->
      price_elm = $(elm)
      price = parseFloat price_elm.text().replace(/[$]/g, '')
      grand_total += price

    $('#order-summary .tax').text '--'
    grand_total_elm.text "$#{grand_total.toFixed(2)}"


$ ->
  $('.state').selectmenu
    change: (e, obj) ->
      if @.id == 'order_billing_address_attributes_state'
        computeTax(obj.value) if $('#billing_ship_to_billing').is(':checked')
      else
        computeTax(obj.value)

  $('#card_card_number').change ->
    card_type = $('#card_card_type').val()
    if card_type == ''
      helper.show_notification('Please choose card type!')
    else
      for validator in CARD_TYPE_VALIDATORS
        if validator.value == card_type
          if !validator.reg.test($(this).val())
            helper.show_notification('Your card number does not match this card_type!')
          break

  $('#card_card_type').change ->
    card_num = $('#card_card_number').val()
    for validator in CARD_TYPE_VALIDATORS
      if validator.value == $(this).val()
        if card_num!='' && !validator.reg.test(card_num)
          helper.show_notification('Your card number does not match this card_type!')
        break

  $('#cvv-explanation').click (e) ->
    cvv_form = $('#cvv-form')
    left = e.clientX - 155
    top = e.clientY - cvv_form.height()
    $('#cvv-form').modal({ opacity:5, overlayClose:true, position:[top, left]})
  $('#cvv-form .close').click -> $.modal.close()

  $(".zip_input").keypress (event) ->
    reg = /^\d{0,5}$/
    return true unless event.charCode
    part1 = @.value.substring 0, @.selectionStart
    part2 = @.value.substring @.selectionEnd, @.value.length
    return reg.test(part1 + String.fromCharCode(event.charCode) + part2)

  $('#shipping-address .edit a').click ->
    $('#shipping-address .inputs').removeClass('hide').addClass('show')
    $('#shipping-address .edit').removeClass('show').addClass('hide')
    $('#billing_ship_to_billing').prop('checked', false)
    $('#shipping-address .header .italic').removeClass('hide').addClass('show')

  $('#billing_ship_to_billing').change ->
    if $(@).is(':checked')
      $('#shipping-address .inputs').removeClass('show').addClass('hide')
      $('#shipping-address .header .italic').removeClass('show').addClass('hide')
      $('#shipping-address .edit').removeClass('hide').addClass('show')
      computeTax $('#order_billing_address_attributes_state').val()
    else
      $('#shipping-address .inputs').removeClass('hide').addClass('show')
      $('#shipping-address .header .italic').removeClass('hide').addClass('show')
      $('#shipping-address .edit').removeClass('show').addClass('hide')
      computeTax $('#order_shipping_address_attributes_state').val()

  $('.submit').click ->
    if $('#shipping-address .edit.hide').length==0
      $('#shipping-address .inputs').text("")

    # Google Analytics
    _gaq.push(['_trackEvent', 'UPLO Web / Check Out', 'Place Order', 'checkout', -1])
    $('#order-shippings').submit()

  # Form inline error showing
  form_validation.setup($('form.simple_form .error'))