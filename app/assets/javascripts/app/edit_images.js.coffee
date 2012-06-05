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
      element.prependTo('#images-panel')
    ),
    maxWidth: 155
    maxHeight: 155
    canvas: true
  return element


deletePhoto = (node) ->
  $.ajax({
    url: $(node).attr('data-url'),
    type: 'GET',
    dataType: 'json',
    success: (response) ->
      $('#images-panel')[0].innerHTML = response.items
      $('.pagination-panel').each( (idx, elem) ->
        elem.innerHTML = response.pagination
      )
  });


$ ->
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
      $('.pagination-panel').each( (idx, elem) ->
        elem.innerHTML = response.pagination
      )
      $('#images-panel').children().last().remove()

  $('.button.save-grid-changes').click ->
    data = []
    photos =  $('#images-panel .edit-template')
    photos.each( (idx, elem)->
      node = $(elem)
      data.push {
        id: node.attr('data-id'),
        name: node.find('#image_name').val(),
        gallery_id: node.find('#image_gallery_id').val(),
        price: node.find('#image_price').val(),
        description: node.find('#image_description').val(),
        is_album_cover: node.find('#image_album_cover').val(),
        is_avatar: node.find('#user_avatar').val(),
        keyword: node.find('#image_key_words').val()
      }
    )
    $.ajax({
      url: '/images/update_images',
      type: 'POST',
      data: { images: $.toJSON(data), gallery_id: $('#gallery_selector_id').val() },
      dataType: 'json',
      success: (response) ->
        $('#images-panel')[0].innerHTML = response.items
        $('.pagination-panel').each( (idx, elem) ->
          elem.innerHTML = response.pagination
        )
    });

  $('#gallery_selector_id').change ->
    $.ajax({
      url: 'edit_images',
      type: 'GET',
      data: { gallery_id: $('#gallery_selector_id').val() },
      dataType: 'json',
      success: (response) ->
        $('#images-panel')[0].innerHTML = response.items
        $('.pagination-panel').each( (idx, elem) ->
          elem.innerHTML = response.pagination
        )
        $('#edit-gallery-popup').replaceWith response.edit_popup
    });

  $('#images-panel').delegate '.button.delete-photo', 'click', (e) -> deletePhoto(e.target)
  $('#edit-gallery').click -> $('#edit-gallery-popup').modal()
  $('body').delegate '#edit-gallery-popup .close', 'click', (e) -> $.modal.close()
  $('body').delegate '#btn-gallery-save', 'click', (e) ->
    $.ajax({
      url: $('#frm-edit-gallery').attr('action'),
      type: 'POST',
      data: $('#frm-edit-gallery').serialize(),
      dataType: 'json',
      success: (response) ->
        if response.success
          alert("Your gallery has been updated!")
          $.modal.close()
          $('#edit-gallery-popup').replaceWith response.edit_popup
        else
          alert("Something went wrong!")
    });




