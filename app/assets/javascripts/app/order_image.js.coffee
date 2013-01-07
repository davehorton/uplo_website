#= require 'app/image_util.js'

computePrice = ->
  size = $('#line_item_size').val()
  moulding = $('#line_item_moulding').val()
  quantity = $('#line_item_quantity').val()
  # if moulding_price[moulding]
  price = moulding_price[moulding][tier][size]
  $('#total .number').text "$#{price.toFixed(2)}"

refreshMouldingOptions = (size) ->
  has_constrain = false
  moulding_selection = $('#line_item_moulding')
  options = moulding_selection.find 'option'
  $.each moulding_constrain, (key, val) ->
    is_limited_size = true
    $.each val, (i, v) ->
      if size.toString() == '' || size.toString() == v.toString()
        is_limited_size = false
    if is_limited_size
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
  $('.add-to-cart').click -> $("#order-details").submit();
  initSizeOptions()
  initMouldingOptions()
  $('#line_item_quantity').keyup -> computePrice()
  $('#line_item_quantity').keypress (e) ->
    reg = /^\d{1,2}$/
    if e.charCode != 0
      val = e.currentTarget.value + String.fromCharCode(e.charCode)
      if !reg.test(val) || (parseInt(val) > 10)
        return false

  order_preview.setup()
  computePrice()
  # refreshSizeOptions $('#line_item_moulding').val()
  # refreshMouldingOptions $('#line_item_size').val()
