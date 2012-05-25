load = (url)->
    $.ajax({
        url: url,
        type: 'GET',
        dataType: 'html',
        success: (response) ->
            $('#container')[0].innerHTML = response;
    });

$ ->
    $('.edit-pane').click -> load($(@).attr('data-url'))
