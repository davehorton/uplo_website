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
  $('#delete-confirm-popup').modal();
  $('#btn-ok').click ->
    $.modal.close()
    $('#mask').modal()
    window.setTimeout "$('#mask').modal()", 500
    $.ajax({
      url: $(node).attr('data-url'),
      type: 'GET',
      dataType: 'json',
      success: (response) ->
        $('#images-panel')[0].innerHTML = response.items
        $('.pagination-panel').each( (idx, elem) ->
          elem.innerHTML = response.pagination
        )
        alert("Delete successfully!")
        $.modal.close()
    });

confirmChanges = (callback) ->
  if window.is_grid_changed == true
    $('#save-confirm-popup').modal()
    $('.button.save-my-changes').click ->
      $('.button.save-grid-changes').first().click()
      callback.call()
    $('.button.leave-not-saving').click ->
      callback.call()
  else
    callback.call()


$ ->
  window.is_grid_changed = false
  $("#fileupload").fileupload()
  $("#fileupload").fileupload "option",
    maxFileSize: 5000000
    acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i
    previewMaxWidth: 180
    previewMaxHeight: 180
    displayNumber: page_size
    add: (e, data) ->
      data.context = renderUpload(data.files[0])
      $('#mask').modal()
      data.submit()
    done: (e, data) ->
      $(data.context).replaceWith data.result.item
      $('.pagination-panel').each( (idx, elem) ->
        elem.innerHTML = data.result.pagination
      )
      $('#images-panel').children().last().remove() if $('.pagination-panel').find('.pagination').length > 0
      $.modal.close()

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
    $('#mask').modal()
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
        alert("Update successfully!")
        window.is_grid_changed = false
        $.modal.close()
    });

  $('#images-panel').delegate '.button.delete-photo', 'click', (e) -> deletePhoto(e.target)
  $('#edit-gallery').click -> $('#edit-gallery-popup').modal()
  $('body').delegate '.popup .close', 'click', (e) -> $.modal.close()
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

  $('#images-panel').delegate '.edit-template input', 'change', (e) ->
    window.is_grid_changed = true
  $('#images-panel').delegate '.edit-template textarea', 'change', (e) ->
    window.is_grid_changed = true
  $('#images-panel').delegate '.edit-template select', 'change', (e) ->
    window.is_grid_changed = true

  $('.pagination-panel').delegate 'a', 'click', (e) ->
    e.preventDefault()
    confirmChanges ->
      window.location = $(e.target).attr('href')

  $('.header-menu a').click (e)->
    e.preventDefault()
    confirmChanges ->
      window.location = $(e.target).attr('href')

  $('#my_links').unbind 'change'
  $('#my_links').bind 'change', (e) ->
    confirmChanges ->
      window.location = $(e.target).val()

  $('#gallery_selector_id').change ->
    confirmChanges ->
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
          $('#delete-gallery').attr('href', response.delete_url)
          $('#fileupload').attr('action', response.upload_url)
          $('#edit-gallery-popup').replaceWith response.edit_popup
          $.modal.close()
      });
