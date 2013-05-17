renderUploadingElement = (element, img, img_name, error) ->
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
  if (error)
    tmp.append(error).removeClass('progress').addClass('error text italic font12')
    previewed_img.html('')
  else
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
      renderUploadingElement(element, img, file.name, file.error)
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
      type: 'DELETE',
      dataType: 'json',
      success: (response) ->
        if (response.success)
          $('#images-panel').html response.items
          $('.pagination-panel').each( (idx, elem) -> $(elem).html response.pagination )
          $('#gallery_selector_id').html response.gallery_options
          $('select').selectmenu({ style: 'dropdown' })
          helper.show_notification("Deleted successfully!")
        else
          helper.show_notification(response.msg)
      complete: ->
        window.setTimeout("$.modal.close();", 400)
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
      gallery_cover: node.find('.album-cover').is(':checked'),
      owner_avatar: node.find('.user-avatar').is(':checked'),
      keyword: node.find('#image_keyword').val()
    }
  )
  $('#mask').modal()
  $.ajax({
    url: '/images/update_images',
    type: 'PUT',
    data: { images: JSON.stringify(data), gallery_id: $('#gallery_selector_id').val() },
    dataType: 'json',
    success: (response) ->
      $('#images-panel').html response.items
      $('.pagination-panel').each((idx, elem) -> $(elem).html response.pagination)
      $('#gallery_selector_id').html response.gallery_options
      $('select').selectmenu({ style: 'dropdown' })
      helper.show_notification("Updated successfully!")
      callback.call() if callback
      window.grid_changed = false
    error: ->
      helper.show_notification("Problem saving!")
    complete: ->
      window.setTimeout("$.modal.close();", 200)
  });

confirmChanges = (callback) ->
  if window.grid_changed == true
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
    url: "/images/" + image_id + "/tier",
    type: 'PUT',
    data: data,
    dataType: 'json',
    success: (response) ->
      if response.success
        helper.show_notification("Price updated!")
        $(node).siblings().text "Tier #{response.tier}"
      else
        helper.show_notification('Something went wrong!')
        $('#pricing-form').modal()
    complete: ->
        window.setTimeout("$.modal.close();", 400)
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
  window.grid_changed = false
  $("#multiple-fileupload").fileupload()
  $("#multiple-fileupload").fileupload "option",
    dataType: 'text'
    maxFileSize: 20000000
    acceptFileTypes: /^image\/(jpg|jpeg)$/
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
      $(data.context).find('.progress').replaceWith("<div class='error info-line text italic font12 left'>Problem uploading photo.</div>")

  $('.button.save-grid-changes').click -> saveGridChanges()

  $('#images-panel').delegate '.edit-template .album-cover', 'click', (e)->
    other_checkboxes = $('#images-panel .edit-template .album-cover').not(e.target)
    other_checkboxes.attr('checked', false)

  $('#images-panel').delegate '.edit-template .user-avatar', 'click', (e)->
    other_checkboxes = $('#images-panel .edit-template .user-avatar').not(e.target)
    other_checkboxes.attr('checked', false)

  $('#images-panel').delegate '.button.delete-photo', 'click', (e) -> deletePhoto(e.target)

  $(document).delegate '#body-galleries .edit-gallery-link', 'click', (e) ->
    $('#edit-gallery-popup').modal()

  $('#images-panel').delegate '.edit-template input', 'change', (e) ->
    window.grid_changed = true
  $('#images-panel').delegate '.edit-template textarea', 'change', (e) ->
    window.grid_changed = true
  $('#images-panel').delegate '.edit-template select', 'change', (e) ->
    window.grid_changed = true

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
        url: '/galleries/' + $('#gallery_selector_id').val() + '/edit_images',
        type: 'GET',
        dataType: 'json',
        success: (response) ->
          $('#images-panel').html response.items
          $('.pagination-panel').each( (idx, elem) ->
            $(elem).html response.pagination
          )
          $('#delete-gallery').attr('href', response.delete_url)
          $('#fileupload').attr('action', response.upload_url)
          $('#edit-gallery-popup').replaceWith response.edit_popup
          $('#gallery_selector_id').html response.gallery_options
          $('select').selectmenu({ style: 'dropdown' })
          window.setTimeout("$.modal.close();", 200)
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
              url: '/images/' + image_id + '/pricing',
              type: 'GET',
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
