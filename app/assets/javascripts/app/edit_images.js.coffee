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
        if (response.success)
          $('#images-panel').html response.items
          $('.pagination-panel').each( (idx, elem) -> $(elem).html response.pagination )
          $('#gallery_selector_id').html response.gallery_options
          $('select').selectmenu({ style: 'dropdown' })
          helper.show_notification("Delete successfully!")
        else
          helper.show_notification(response.msg)
      complete: ->
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
      $('#images-panel').html response.items
      $('.pagination-panel').each((idx, elem) -> $(elem).html response.pagination)
      $('#gallery_selector_id').html response.gallery_options
      $('select').selectmenu({ style: 'dropdown' })
      helper.show_notification("Update successfully!")
      callback.call() if callback
      window.is_grid_changed = false
    error: -> 
      helper.show_notification("Fail to update!")
    complete: ->
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

requestUpdateTier = (node) ->
  image_id = $(node).closest('.edit-template').attr('data-id')
  data = $('#frm-pricing').serialize()
  $.modal.close()
  window.setTimeout "$('#mask').modal()", 300
  $.ajax({
    url: "/images/update_tier?id=#{ image_id }",
    type: 'POST',
    data: data,
    dataType: 'json',
    success: (response) ->
      if response.success
        helper.show_notification("Price has been updated successfully!")
        $(node).siblings().text "Tier #{response.tier}"
        $.modal.close()
      else
        helper.show_notification('Something went wrong!')
        $('#pricing-form').modal()
  });

initTabs = (tab) ->
  $('.price-tab').hide()
  $('.price-tab:first').show()
  $('ul#tabs li:first a').addClass('active')
  $('ul#tabs li').click ->
    $('ul#tabs li a').removeClass('active')
    tab = $(@).find('a')
    tab.addClass('active')
    currentTab = tab.attr('href')
    $('.price-tab').hide()
    $(currentTab).show()
    return false


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
        $('.empty-data').remove()
        $(data.context).replaceWith response.item
        $('.pagination-panel').each((idx, elem) -> $(elem).html response.pagination)
        $('#images-panel').children().last().remove() if $('.pagination-panel').find('.pagination').length > 0
        $('#gallery_selector_id').html response.gallery_options
        $('select').selectmenu({ style: 'dropdown' })
      else
        $(data.context).find('.progress').replaceWith("<div class='error info-line text italic font12 left'>#{response.msg}</div>")
    progress: (e, data) ->
      progress = parseInt(data.loaded / data.total * 100, 10).toString() + '%'
      if data.context
        setLoadingStatus =-> $(data.context).find('.progress .uploading').css('width', progress)
        window.setTimeout(setLoadingStatus, 300);
    fail: (e, data) ->
      $(data.context).find('.progress').replaceWith("<div class='error info-line text italic font12 left'>Cannot upload this image right now! Please try again later!</div>")

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
          helper.show_notification("Your gallery has been updated!")
          $.modal.close()
          $('#edit-gallery-popup').replaceWith response.edit_popup
          $('#gallery_selector_id').html(response.gal_with_number_options)
          $('.edit-template #image_gallery_id').each((idx, val) -> $(val).html(response.gallery_options))
          $('select[id=gallery_permission]').selectmenu({ style: 'dropdown' })
        else
          helper.show_notification(response.msg)
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

  $('.header-menu ul li > a').click (e)->
    e.preventDefault()
    confirmChanges ->
      window.location = $(e.target).attr('href')

  $('#my_links').selectmenu({
    style: 'dropdown',
    select: (e, obj)->
      confirmChanges -> window.location = obj.value
  })


  $('#gallery_selector_id').change ->
    confirmChanges ->
      $.ajax({
        url: 'edit_images',
        type: 'GET',
        data: { gallery_id: $('#gallery_selector_id').val() },
        dataType: 'json',
        success: (response) ->
          $('#images-panel').html response.items
          $('.pagination-panel').each( (idx, elem) ->
            $(elem).html response.pagination
          )
          $('#delete-gallery').attr('href', response.delete_url)
          $('#fileupload').attr('action', response.upload_url)
          $('#edit-gallery-popup').replaceWith response.edit_popup
          $(@).html response.gallery_options
          $('select').selectmenu({ style: 'dropdown' })
          $.modal.close()
      })

  $('#images-panel').delegate '.edit-template .price', 'click', (e) ->
    node = e.target
    form = $('#pricing-form')
    left = e.clientX - 60
    top = e.clientY - form.height()
    $('#pricing-form').modal({
      opacity: 5,
      position:[top, left],
      escClose: false,
      overlayClose: true,
      onOpen: (dialog) ->
        dialog.overlay.fadeIn('slow', ->
          dialog.container.fadeIn('slow', ->
            dialog.data.fadeIn()
            $('#pricing-form .button').fadeOut()
            image_id = $(node).closest('.edit-template').attr('data-id')
            $.ajax({
              url: '/images/show_pricing',
              type: 'GET',
              data: { id: image_id },
              dataType: 'json',
              success: (response) ->
                if response.success
                  $('#price-tiers').html(response.price_table)
                  $('#pricing-form .button').fadeIn()
                  $('#btn-done').click -> requestUpdateTier(node)
                  initTabs()
                  top = e.clientY - form.height()
                  form.closest('.simplemodal-container').css('top', "#{top}px")
                else
                  $('#price-tiers').html(response.msg)
                  $('#pricing-form .button.close').fadeIn()
                  top = e.clientY - form.height()
                  form.closest('.simplemodal-container').css('top', "#{top}px")
            })
          )
        )
    })
