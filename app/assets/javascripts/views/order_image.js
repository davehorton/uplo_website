(function() {
  var computePrice, initSizeOptions;

  computePrice = function() {
    var quantity;
    quantity = $('#line_item_quantity').val();
    if ((typeof image_id !== "undefined" && image_id !== null)) {
      return $.ajax({
        url: '/images/' + image_id + '/price',
        type: 'GET',
        data: {
          product_id: $('#line_item_product_id').val()
        },
        dataType: 'json',
        success: function(response) {
          var price;
          if (response.success) {
            price = response.price * quantity;
            return $('#total .number').text("$" + (price.toFixed(2)));
          }
        },
        error: function() {
          return helper.show_notification('Something went wrong!');
        }
      });
    }
  };

  initSizeOptions = function() {
    return $('#line_item_product_id').selectmenu({
      style: 'dropdown',
      change: function(e, obj) {
        return computePrice();
      }
    });
  };

  $(function() {
    $('#preview-frame').on('contextmenu', function() {
      alert('These photos are copyrighted by their respective owners. All rights reserved. Unauthorized use prohibited.');
      return false;
    });

    $('.add-to-cart').click(function() {
      return $("#order-details").submit();
    });

    initSizeOptions();

    $('#line_item_quantity').keyup(function() {
      return computePrice();
    });

    $('#line_item_quantity').keypress(function(event) {
      var part1, part2, reg, val;
      reg = /^\d{1,2}$/;
      if (!event.charCode) {
        return true;
      }
      part1 = this.value.substring(0, this.selectionStart);
      part2 = this.value.substring(this.selectionEnd, this.value.length);
      val = part1 + String.fromCharCode(event.charCode) + part2;
      if (reg.test(val)) {
        return parseInt(val) <= 10;
      } else {
        return false;
      }
    });

    $('#line_item_product_id').change(function(){
      $.ajax({
        url: '/images/' + image_id + '/product_options',
        type: 'GET',
        data: {
          product_id: $('#line_item_product_id').val()
        }
      });
    });

    $('#line_item_product_option_id').change(function(){
      $('#preview-image').empty();
      $('#preview-waiting').show();

      $.ajax({
        url: '/images/' + image_id + '/print_image_preview',
        type: 'GET',
        data: {
          product_option_id: $(this).val()
        }
      });
    });

    $('#line_item_product_option_id').change();

    return computePrice();
  });

}).call(this);