class window.Mask
  constructor: () ->
    @htmlElement = document.createElement("div")
    @htmlElement.classList.add("mask")
    $("body").append(@htmlElement)

  show: =>
    @htmlElement.classList.add("display")
    
  hide: =>
    @htmlElement.classList.remove("display")


class window.Popup
  constructor: (options = {id: "", title:"", text:"", css:{}, buttons:{}}) ->
    @htmlElement = document.createElement("div")
    @htmlElement.classList.add("popup")    
    @htmlElement.classList.add("round-box")    
    @htmlElement.classList.add("blue-gradient-reverse")
    
    if options.id!=null and options.id!=undefined
      @htmlElement.id = options.id
      
    title = document.createElement("div")
    title.classList.add("title")    
    if options.title==null or options.title==undefined
      title.innerHTML = "&nbsp;"
      title.classList.add("non-text")
    else if($.browser.msie == true)
      title.innerText = options.title
    else
      title.textContent = options.title
    
    content = @initContent(options.text, options.css)
    buttons = @initButtons(options.buttons)
    @htmlElement.appendChild(title)
    @htmlElement.appendChild(content)
    @htmlElement.appendChild(buttons)
    $("body").append(@htmlElement)

  initContent: (text="", css = {}) ->
    content = document.createElement("div")
    content.classList.add("content")
    if($.browser.msie == true)
      content.innerText = text
    else
      content.textContent = text
      
    if css==null or css==undefined
      @setPosition()
    else
      @setPosition(css.top, css.left)
      delete(css.top)
      delete(css.left)
        
      tmp = $(content)
      $.each(css, (key, val) ->
        tmp.css(key, val)
      )
      
    return content
  
  initButtons: (buttons) ->
    buttons_pane = document.createElement("div")
    buttons_pane.classList.add("buttons")
    $.each(buttons, (name, func) ->
      btn = document.createElement("button")
      btn.type = "button"
      btn.innerHTML = name
      $(btn).click(func)
      buttons_pane.appendChild(btn)
    )
    return buttons_pane
    
  setPosition: (top, left) =>
    elm = $(@htmlElement)
    if top!=null and top!=undefined
      elm.css("top", top)
    else
      elm.css("top", $("body").height()/2)
      
    if left!=null and left!=undefined
      elm.css("left", left)
    else
      elm.css("left", $("body").width()/3)
      
  show: =>
    @htmlElement.classList.add("display")
    window.mask = new Mask() unless window.mask
    window.mask.show()
    
  hide: =>
    @htmlElement.classList.remove("display")
    window.mask.hide()
    
  close: =>
    $(@htmlElement).remove()
    $(".mask").remove()
    window.mask = null
