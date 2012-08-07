deleteItem = (node)->
  $('#btn-ok').click ->
    url = $(node).attr('data-url')
    id = $(node).attr('data-id')
    $.ajax({
      url: url,
      type: 'GET',
      data: { id: id },
      dataType: 'json',
      success: (response) ->
        if(response.success == false)
          helper.show_notification(response.msg)
        else
          helper.show_notification('The item has been removed successfully!')
          $(node).closest('.line').remove()
          $('#cart-counter').text "(#{response.cart_items})"
          if response.cart_items == 0
            $('.cart-details').replaceWith('<div class="left" style="min-height: 100px;">Your cart is current empty.</div>
                                            <div class="line-separator clear" style=""></div>')
            $('.actions').find('div').not('.shopping').remove()
            $('.actions').find('a').not('.shopping').remove()
          else
            $('#subtotal').text(response.cart_amounts.price_total)
            $('#tax-total').text(response.cart_amounts.tax)
            $('#cart-total').text(response.cart_amounts.cart_total)
        $.modal.close()
    });

$ ->
  $('.delete-section').click ->
    $('#delete-confirm-popup').modal()
    deleteItem(@)

