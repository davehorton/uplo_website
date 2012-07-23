loadDefaultPrice = ->
  $.ajax({
    url: '/images/get_price',
    type: 'GET',
    dataType: 'json',
    data: { image_id: image_id, size:$('.print-sizes-container input:radio:checked').attr('value') }
    success: (response) ->
      if response.success
        $('#image-price').text response.price
        $.modal.close()
      else
        alert(response.msg)
        window.location = '/browse'
  });

$ ->
  loadDefaultPrice()
  $('.print-sizes-container input:radio').change (e,a)->
    $('#mask').modal()
    $.ajax({
      url: '/images/get_price',
      type: 'GET',
      dataType: 'json',
      data: { image_id: image_id, size:$(e.target).attr('value') }
      success: (response) ->
        if response.success
          $('#image-price').text response.price
          $.modal.close()
        else
          alert(response.msg)
          window.location = '/browse'
    });
