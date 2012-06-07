load = (url, callback)->
  $('#mask').modal()
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
      $.modal.close();
  });

$ ->
  $('.not-implement').click -> helper.alert_not_implement()
  $('#container .edit-pane[data-url!="#"]').click -> load($(@).attr('data-url'))
  $('#followers-section .list').click -> load($(@).attr('data-url'))

  $('#container').delegate '.follow', 'click', (e) ->
    target = $(e.target)
    author_id = target.attr('data-author-id')
    is_unfollow = target.attr('data-following')
    $('#mask').modal()
    $.ajax({
      url: '/users/follow',
      type: "GET",
      data: { user_id:author_id, unfollow: is_unfollow },
      dataType: "json",
      success: (response) ->
        if(response.success==false)
          alert(response.msg)
        else if(is_unfollow=='false')
          target.attr('data-following', 'true')
          target.text('Unfollow')
        else
          target.attr('data-following', 'false')
          target.text('Follow')
        $.modal.close
    });

  $('#counters .counter').click ->
    url = $(@).attr('data-url')
    if url != '#'
      load(url)


