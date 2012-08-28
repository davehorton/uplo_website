#= require 'app/image_util.js'
  
computePrice = ->
  size = $('#line_item_size').val()
  moulding = $('#line_item_moulding').val()
  quantity = $('#line_item_quantity').val()
  price = pricing[size] * quantity
  discount = price * moulding_discount[moulding]
  $('#discount .number').text "- $#{discount.toFixed(2)}"
  $('#total .number').text "$#{(price - discount).toFixed(2)}"

$ ->
  computePrice()
  $('#line_item_size').selectmenu({
    style: 'dropdown',
    change: (e, obj) -> computePrice()
  });
  $('#line_item_moulding').selectmenu({
    style: 'dropdown',
    change: (e, obj) -> computePrice()
  });

  $('.add-to-cart').click -> $("#order-details").submit();
  $('#line_item_quantity').keypress (e) ->
    reg = /^\d{1,2}$/;
    if e.charCode != 0
      val = e.currentTarget.value + String.fromCharCode(e.charCode);
      if !reg.test(val) || (parseInt(val) > 10)
        return false;

  $('#line_item_quantity').keyup -> computePrice()  

  order_preview.setup()
