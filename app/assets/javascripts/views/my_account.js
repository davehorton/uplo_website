(function() {
  var CARDNUM_VALIDATOR;

  CARDNUM_VALIDATOR = /^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$/;

  window.CARD_TYPE_VALIDATORS = [
    {
      value: 'USA_express',
      reg: /^3[47][0-9]{13}$/
    },
    {
      value: 'discover',
      reg: /^6(?:011|5[0-9]{2})[0-9]{12}$/
    },
    {
      value: 'visa',
      reg: /^4[0-9]{12}(?:[0-9]{3})?$/
    },
    {
      value: 'master_card',
      reg: /^5[1-5][0-9]{14}$/
    }
  ];

  $(function() {
    $('#user_card_number').change(function() {
      var card_type, validator, _i, _len, _results;
      card_type = $('#user_card_type').val();
      if (card_type === '') {
        return helper.show_notification('Please choose credit card type!');
      } else {
        _results = [];
        for (_i = 0, _len = CARD_TYPE_VALIDATORS.length; _i < _len; _i++) {
          validator = CARD_TYPE_VALIDATORS[_i];
          if (validator.value === card_type) {
            if (!validator.reg.test($(this).val())) {
              helper.show_notification('Your card number does not match ' + $('#user_card_type option:selected').text() + '!');
            }
            break;
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }
    });
    $('#user_card_type').change(function() {
      var card_num, validator, _i, _len, _results;
      card_num = $('#user_card_number').val();
      _results = [];
      for (_i = 0, _len = CARD_TYPE_VALIDATORS.length; _i < _len; _i++) {
        validator = CARD_TYPE_VALIDATORS[_i];
        if (validator.value === $(this).val()) {
          if (card_num !== '' && !validator.reg.test(card_num)) {
            helper.show_notification('Your card number does not match ' + $('#user_card_type option:selected').text() + '!');
          }
          break;
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    });
    $('#cvv-explanation').click(function(e) {
      var cvv_form, left, top;
      cvv_form = $('#cvv-form');
      left = e.clientX - 155;
      top = e.clientY - cvv_form.height();
      return $('#cvv-form').modal({
        opacity: 5,
        overlayClose: true,
        position: [top, left]
      });
    });
    return $('#cvv-form .close').click(function() {
      return $.modal.close();
    });
  });

}).call(this);