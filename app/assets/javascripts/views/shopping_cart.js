(function() {
  var deleteItem;

  deleteItem = function(node) {
    return $('#btn-ok').click(function() {
      var id, url;
      url = $(node).attr('data-url');
      id = $(node).attr('data-id');
      return $.ajax({
        url: url,
        type: 'GET',
        data: {
          id: id
        },
        dataType: 'json',
        success: function(response) {
          if (response.success === false) {
            helper.show_notification(response.msg);
          } else {
            helper.show_notification('The item has been removed successfully!');
            $(node).closest('.line').remove();
            $('#cart-counter').text("(" + response.cart_items + ")");
            if (response.cart_items === 0) {
              $('.cart-details').replaceWith('<div class="left" style="min-height: 100px;">Your cart is current empty.</div>\
                                            <div class="line-separator clear" style=""></div>');
              $('.actions').find('div').not('.shopping').remove();
              $('.actions').find('a').not('.shopping').remove();
            } else {
              $('#subtotal').text(response.cart_amounts.price_total);
              $('#tax-total').text(response.cart_amounts.tax);
              $('#cart-total').text(response.cart_amounts.cart_total);
            }
          }
          return $.modal.close();
        }
      });
    });
  };

  $(function() {
    return $('.delete-section').click(function() {
      $('#delete-confirm-popup').modal();
      return deleteItem(this);
    });
  });

}).call(this);