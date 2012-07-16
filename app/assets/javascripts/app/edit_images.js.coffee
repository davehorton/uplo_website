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
  tmp = $(document.createElement 'div')
  tmp.addClass 'progress info-line left'
  progress_div = $(document.createElement 'div')
  progress_div.addClass 'uploading'
  tmp.append progress_div
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
    window.setTimeout "$('#mask').modal()", 500
    $.ajax({
      url: $(node).attr('data-url'),
      type: 'GET',
      dataType: 'json',
      success: (response) ->
        $('#images-panel')[0].innerHTML = response.items
        $('.pagination-panel').each( (idx, elem) -> $(elem).html response.pagination )
        $('#gallery_selector_id').html response.gallery_options
        alert("Delete successfully!")
        $.modal.close()
    });

saveGridChanges = (callback) ->
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
      is_album_cover: node.find('.album-cover').is(':checked'),
      is_avatar: node.find('.user-avatar').is(':checked'),
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
      callback.call() if callback
      window.is_grid_changed = false
      $.modal.close()
  });

confirmChanges = (callback) ->
  if window.is_grid_changed == true
    $('#save-confirm-popup').modal()
    $('.button.save-my-changes').click ->
      saveGridChanges(callback)
    $('.button.leave-not-saving').click ->
      callback.call()
  else
    callback.call()


$ ->
  window.is_grid_changed = false
  $("#fileupload").fileupload()
  $("#fileupload").fileupload "option",
    dataType: 'text'
    maxFileSize: 5000000
    acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i
    previewMaxWidth: 180
    previewMaxHeight: 180
    add: (e, data) ->
      data.context = renderUpload(data.files[0])
      data.submit()
    done: (e, data) ->
      response = $.parseJSON(data.result)
      if response.success
        $(data.context).replaceWith response.item
        $('.pagination-panel').each((idx, elem) -> elem.innerHTML = response.pagination)
        $('#images-panel').children().last().remove() if $('.pagination-panel').find('.pagination').length > 0
        $('#gallery_selector_id').html response.gallery_options
        $('.empty-data').remove()
      else
        $(data.context).find('.progress').replaceWith("<div class='error info-line text italic font12 left'>#{response.msg}</div>")
    progress: (e, data) ->
      progress = parseInt(data.loaded / data.total * 100, 10).toString() + '%'
      if data.context
        setLoadingStatus =-> $(data.context).find('.progress .uploading').css('width','80%')
        window.setTimeout(setLoadingStatus, 300);

  $('.button.save-grid-changes').click -> saveGridChanges()

  $('#images-panel').delegate '.edit-template .album-cover', 'click', (e)->
    other_checkboxes = $('#images-panel .edit-template .album-cover').not(e.target)
    other_checkboxes.attr('checked', false)

  $('#images-panel').delegate '.edit-template .user-avatar', 'click', (e)->
    other_checkboxes = $('#images-panel .edit-template .user-avatar').not(e.target)
    other_checkboxes.attr('checked', false)

  $('#images-panel').delegate '.button.delete-photo', 'click', (e) -> deletePhoto(e.target)
  $('#edit-gallery').click -> $('#edit-gallery-popup').modal()
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
          $('#gallery_selector_id').html(response.gal_with_number_options)
          $('.edit-template #image_gallery_id').each((idx, val) -> val.html(response.gallery_options))
        else
          alert(response.msg)
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
