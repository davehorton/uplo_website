renderUploadingElement = (element, img, img_name) ->
  clear_div = $(document.createElement 'div').addClass 'clear'
  separator = $(document.createElement 'div').addClass 'line-separator left'

  previewed_img = $(document.createElement 'div')
  previewed_img.attr 'title', img_name
  previewed_img.addClass 'image-container thumb no-padding'
  previewed_img.append img

  name = $(document.createElement 'div')
  name.addClass 'info-panel left'
  tmp = $(document.createElement 'div')
  tmp.addClass 'info-line left'
  name_content = $(document.createElement 'div')
  name_content.addClass 'label text black bold font12'
  name_content.text img_name
  tmp.append name_content
  name.append tmp

  element.addClass 'upload-template container left'
  element.append previewed_img
  element.append name
  element.append clear_div
  element.append separator
  return element


renderUpload = (file) ->
  element = $(document.createElement 'div')
  window.loadImage file, ((img) ->
      renderUploadingElement(element, img, file.name)
      element.prependTo('#upload-panel')
    ),
    maxWidth: 155
    maxHeight: 155
    canvas: true
  return element

$ ->
  "use strict"
  $("#fileupload").fileupload()
  $("#fileupload").fileupload "option",
    maxFileSize: 5000000
    acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i
    previewMaxWidth: 180
    previewMaxHeight: 180
    displayNumber: page_size
    add: (e, data) ->
      data.context = renderUpload(data.files[0])
      data.submit()
    done: (e, data) ->
      $(data.context).replaceWith data.result.item
      $('.pagination').replaceWith data.result.pagination
      $('#images-panel').children().last().remove()





