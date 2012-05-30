load = (url, callback)->
  $.ajax({
    url: url,
    type: 'GET',
    dataType: 'html',
    success: (response) ->
      $('#container')[0].innerHTML = response
      helper.endless_load_more( ->
        if($(document).height() <= $(window).height())
          $(window).scroll()
        return
      )
      $(window).scroll();
  });

$ ->
  $('.not-implement').click -> helper.alert_not_implement()
  $('#container .edit-pane[data-url!="#"]').click -> load($(@).attr('data-url'))
