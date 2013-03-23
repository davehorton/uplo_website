computePrice = ->
  size = $('#line_item_size').val()
  moulding = $('#line_item_moulding').val()
  quantity = $('#line_item_quantity').val()
  if (moulding_price?)
    price = moulding_price[moulding][tier][size] * quantity
    $('#total .number').text "$#{price.toFixed(2)}"

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

initMouldingOptions = ->
  moulding_selection = $('#line_item_moulding')
  options = moulding_selection.find 'option'
  $.each options, (idx, val) ->
    option = $(val)
    option.prop 'disabled', moulding_pending[option.val()]
  moulding_selection.selectmenu({
    style: 'dropdown',
    change: (e, obj) ->
      computePrice()
      # refreshSizeOptions obj.value
  })

initSizeOptions = ->
  $('#line_item_size').selectmenu({
    style: 'dropdown',
    change: (e, obj) ->
      computePrice()
      # refreshMouldingOptions obj.value
  })

$ ->
  $('#preview-frame').on 'contextmenu', ->
    alert('These photos are copyrighted by their respective owners. All rights reserved. Unauthorized use prohibited.')
    return false

  $('.add-to-cart').click -> $("#order-details").submit();

  initSizeOptions()
  initMouldingOptions()
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
