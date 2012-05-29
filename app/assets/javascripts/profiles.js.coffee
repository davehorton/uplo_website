load = (url, callback)->
  $.ajax({
    url: url,
    type: 'GET',
    dataType: 'html',
    success: (response) ->
      $('#container')[0].innerHTML = response
      helper.endless_load_more( ()->
        while($(document).height() == $(window).height())
          $(window).scroll()
        return
      )
      $(window).scroll();
  });

$ ->
  $('.edit-pane').click -> load($(@).attr('data-url'))
