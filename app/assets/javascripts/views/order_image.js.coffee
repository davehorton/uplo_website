computePrice = ->
  quantity = $('#line_item_quantity').val()
  if (image_id?)
    $.ajax({
      url: '/images/' + image_id + '/price',
      type: 'GET',
      data: {
        size_id: $('#line_item_size').val(),
        moulding_id: $('#line_item_moulding').val()
      },
      dataType: 'json',
      success: (response) ->
        if response.success
          price = response.price * quantity
          $('#total .number').text "$#{price.toFixed(2)}"
      error: ->
        helper.show_notification('Something went wrong!')
    });

refreshMouldingOptions = (size) ->
  has_constrain = false
  moulding_selection = $('#line_item_moulding')
  options = moulding_selection.find 'option'
  $.each moulding_constrain, (key, val) ->
    limited_size = true
    $.each val, (i, v) ->
      if size.toString() == '' || size.toString() == v.toString()
        limited_size = false
    if limited_size
      options = options.not "option[value!=#{key}]"
      has_constrain = true
  options.prop 'disabled', has_constrain
  moulding_selection.selectmenu()

refreshSizeOptions = (mould) ->
  has_constrain = false
  sizes_selection = $('#line_item_size')
  options = sizes_selection.find 'option'
  if moulding_constrain[mould]
    $.each moulding_constrain[mould], (i, v) ->
      options = options.not "option[value=#{v}]"
      has_constrain = true
  options.prop 'disabled', has_constrain
  sizes_selection.selectmenu()

initSizeOptions = ->
  $('#line_item_size, #line_item_moulding').selectmenu({
    style: 'dropdown',
    change: (e, obj) ->
      computePrice()
  })

$ ->
  $('#preview-frame').on 'contextmenu', ->
    alert('These photos are copyrighted by their respective owners. All rights reserved. Unauthorized use prohibited.')
    return false

  $('.add-to-cart').click -> $("#order-details").submit();

  initSizeOptions()
  $('#line_item_quantity').keyup -> computePrice()
  $('#line_item_quantity').keypress (event) ->
    reg = /^\d{1,2}$/
    return true unless event.charCode
    part1 = @.value.substring 0, @.selectionStart
    part2 = @.value.substring @.selectionEnd, @.value.length
    val = part1 + String.fromCharCode(event.charCode) + part2
    if reg.test(val)
      return (parseInt(val) <= 10)
    else
      return false

  order_preview.setup()
  computePrice()
  # refreshSizeOptions $('#line_item_moulding').val()
  # refreshMouldingOptions $('#line_item_size').val()
