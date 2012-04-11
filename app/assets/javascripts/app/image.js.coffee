window.image =
    show_sharing_popup: ->
        btn_share = $(".actions .button.share")
        popup = document.createElement("div")
        popup.id = 'social-sharing-popup'
        popup.style.width = '200px'
        popup.style.height = '200px'
        popup.style.backgroundColor = 'yellow'
        popup.style.position = 'absolute'

        x_position = btn_share.position().left + btn_share.width()/2 - $(popup).width()/2
        y_position = btn_share.position().top - $(popup).height()
        console.log(btn_share.position().top)
        console.log(btn_share.width()/2)
        console.log($(popup).width())
        console.log(x_position)
        popup.style.left = x_position + 'px'
        popup.style.top = y_position + 'px'

        $('body').append(popup)

