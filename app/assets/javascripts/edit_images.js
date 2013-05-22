(function() {
  var confirmChanges, deletePhoto, initTabs, renderUpload, renderUploadingElement, requestUpdateTier, saveGridChanges;

  renderUploadingElement = function(element, img, img_name, error) {
    var clear_div, name, name_content, previewed_img, progress_div, separator, tmp;
    clear_div = $(document.createElement('div')).addClass('clear');
    separator = $(document.createElement('div')).addClass('line-separator left');
    previewed_img = $(document.createElement('div'));
    previewed_img.attr('title', img_name);
    previewed_img.addClass('image-container thumb no-padding');
    previewed_img.append(img);
    name = $(document.createElement('div'));
    name.addClass('info-panel left');
    tmp = $(document.createElement('div'));
    tmp.addClass('info-line left');
    name_content = $(document.createElement('div'));
    name_content.addClass('label text black bold font12');
    name_content.text(img_name);
    tmp.append(name_content);
    name.append(tmp);
    tmp = $(document.createElement('div'));
    tmp.addClass('progress info-line left');
    if (error) {
      tmp.append(error).removeClass('progress').addClass('error text italic font12');
      previewed_img.html('');
    } else {
      progress_div = $(document.createElement('div'));
      progress_div.addClass('uploading');
      tmp.append(progress_div);
    }
    name.append(tmp);
    element.addClass('upload-template container left');
    element.append(previewed_img);
    element.append(name);
    element.append(clear_div);
    element.append(separator);
    return element;
  };

  renderUpload = function(file) {
    var element;
    element = $(document.createElement('div'));
    window.loadImage(file, (function(img) {
      renderUploadingElement(element, img, file.name, file.error);
      return element.prependTo('#images-panel');
    }), {
      maxWidth: 155,
      maxHeight: 155,
      canvas: true
    });
    return element;
  };

  deletePhoto = function(node) {
    $('#delete-confirm-popup').modal();
    return $('#btn-ok').click(function() {
      $.modal.close();
      window.setTimeout("$('#mask').modal()", 500);
      return $.ajax({
        url: $(node).attr('data-url'),
        type: 'DELETE',
        dataType: 'json',
        success: function(response) {
          if (response.success) {
            $('#images-panel').html(response.items);
            $('.pagination-panel').each(function(idx, elem) {
              return $(elem).html(response.pagination);
            });
            $('#gallery_selector_id').html(response.gallery_options);
            $('select').selectmenu({
              style: 'dropdown'
            });
            return helper.show_notification("Deleted successfully!");
          } else {
            return helper.show_notification(response.msg);
          }
        },
        complete: function() {
          return window.setTimeout("$.modal.close();", 400);
        }
      });
    });
  };

  saveGridChanges = function(callback) {
    var data, photos;
    data = [];
    photos = $('#images-panel .edit-template');
    photos.each(function(idx, elem) {
      var node;
      node = $(elem);
      return data.push({
        id: node.attr('data-id'),
        name: node.find('#image_name').val(),
        gallery_id: node.find('#image_gallery_id').val(),
        price: node.find('#image_price').val(),
        description: node.find('#image_description').val(),
        gallery_cover: node.find('.album-cover').is(':checked'),
        owner_avatar: node.find('.user-avatar').is(':checked'),
        keyword: node.find('#image_keyword').val()
      });
    });
    $('#mask').modal();
    return $.ajax({
      url: '/images/update_images',
      type: 'PUT',
      data: {
        images: JSON.stringify(data),
        gallery_id: $('#gallery_selector_id').val()
      },
      dataType: 'json',
      success: function(response) {
        $('#images-panel').html(response.items);
        $('.pagination-panel').each(function(idx, elem) {
          return $(elem).html(response.pagination);
        });
        $('#gallery_selector_id').html(response.gallery_options);
        $('select').selectmenu({
          style: 'dropdown'
        });
        helper.show_notification("Updated successfully!");
        if (callback) {
          callback.call();
        }
        return window.grid_changed = false;
      },
      error: function() {
        return helper.show_notification("Problem saving!");
      },
      complete: function() {
        return window.setTimeout("$.modal.close();", 200);
      }
    });
  };

  confirmChanges = function(callback) {
    if (window.grid_changed === true) {
      $('#save-confirm-popup').modal();
      $('.button.save-my-changes').click(function() {
        return saveGridChanges(callback);
      });
      return $('.button.leave-not-saving').click(function() {
        return callback.call();
      });
    } else {
      return callback.call();
    }
  };

  requestUpdateTier = function(node) {
    var data, image_id;
    image_id = $(node).closest('.edit-template').attr('data-id');
    data = $('#frm-pricing').serialize();
    $.modal.close();
    window.setTimeout("$('#mask').modal()", 300);
    return $.ajax({
      url: "/images/" + image_id + "/tier",
      type: 'PUT',
      data: data,
      dataType: 'json',
      success: function(response) {
        if (response.success) {
          helper.show_notification("Price updated!");
          return $(node).siblings().text("Tier " + response.tier);
        } else {
          helper.show_notification('Something went wrong!');
          return $('#pricing-form').modal();
        }
      },
      complete: function() {
        return window.setTimeout("$.modal.close();", 400);
      }
    });
  };

  initTabs = function(tab) {
    $('.price-tab').hide();
    $('.price-tab:first').show();
    $('ul#tabs li:first a').addClass('active');
    return $('ul#tabs li').click(function() {
      var currentTab;
      $('ul#tabs li a').removeClass('active');
      tab = $(this).find('a');
      tab.addClass('active');
      currentTab = tab.attr('href');
      $('.price-tab').hide();
      $(currentTab).show();
      return false;
    });
  };

  $(function() {
    window.grid_changed = false;
    $("#multiple-fileupload").fileupload();
    $("#multiple-fileupload").fileupload("option", {
      dataType: 'text',
      maxFileSize: 20000000,
      acceptFileTypes: /^image\/(jpg|jpeg)$/,
      previewMaxWidth: 180,
      previewMaxHeight: 180,
      add: function(e, data) {
        data.context = renderUpload(data.files[0]);
        return data.submit();
      },
      done: function(e, data) {
        var response;
        response = $.parseJSON(data.result);
        if (response.success) {
          $('.empty-data').remove();
          $(data.context).replaceWith(response.item);
          $('.pagination-panel').each(function(idx, elem) {
            return $(elem).html(response.pagination);
          });
          if ($('.pagination-panel').find('.pagination').length > 0) {
            $('#images-panel').children().last().remove();
          }
          $('#gallery_selector_id').html(response.gallery_options);
          return $('select').selectmenu({
            style: 'dropdown'
          });
        } else {
          return $(data.context).find('.progress').replaceWith("<div class='error info-line text italic font12 left'>" + response.msg + "</div>");
        }
      },
      progress: function(e, data) {
        var progress, setLoadingStatus;
        progress = parseInt(data.loaded / data.total * 100, 10).toString() + '%';
        if (data.context) {
          setLoadingStatus = function() {
            return $(data.context).find('.progress .uploading').css('width', progress);
          };
          return window.setTimeout(setLoadingStatus, 300);
        }
      },
      fail: function(e, data) {
        return $(data.context).find('.progress').replaceWith("<div class='error info-line text italic font12 left'>Problem uploading photo.</div>");
      }
    });
    $('.button.save-grid-changes').click(function() {
      return saveGridChanges();
    });
    $('#images-panel').delegate('.edit-template .album-cover', 'click', function(e) {
      var other_checkboxes;
      other_checkboxes = $('#images-panel .edit-template .album-cover').not(e.target);
      return other_checkboxes.attr('checked', false);
    });
    $('#images-panel').delegate('.edit-template .user-avatar', 'click', function(e) {
      var other_checkboxes;
      other_checkboxes = $('#images-panel .edit-template .user-avatar').not(e.target);
      return other_checkboxes.attr('checked', false);
    });
    $('#images-panel').delegate('.button.delete-photo', 'click', function(e) {
      return deletePhoto(e.target);
    });
    $(document).delegate('#body-galleries .edit-gallery-link', 'click', function(e) {
      return $('#edit-gallery-popup').modal();
    });
    $('#images-panel').delegate('.edit-template input', 'change', function(e) {
      return window.grid_changed = true;
    });
    $('#images-panel').delegate('.edit-template textarea', 'change', function(e) {
      return window.grid_changed = true;
    });
    $('#images-panel').delegate('.edit-template select', 'change', function(e) {
      return window.grid_changed = true;
    });
    $('.pagination-panel').delegate('a', 'click', function(e) {
      e.preventDefault();
      return confirmChanges(function() {
        return window.location = $(e.target).attr('href');
      });
    });
    $('.header-menu ul li > a').click(function(e) {
      e.preventDefault();
      return confirmChanges(function() {
        return window.location = $(e.target).attr('href');
      });
    });
    $('#my_links').selectmenu({
      style: 'dropdown',
      select: function(e, obj) {
        return confirmChanges(function() {
          return window.location = obj.value;
        });
      }
    });
    $('#gallery_selector_id').change(function() {
      return confirmChanges(function() {
        return $.ajax({
          url: '/galleries/' + $('#gallery_selector_id').val() + '/edit_images',
          type: 'GET',
          dataType: 'json',
          success: function(response) {
            $('#images-panel').html(response.items);
            $('.pagination-panel').each(function(idx, elem) {
              return $(elem).html(response.pagination);
            });
            $('#delete-gallery').attr('href', response.delete_url);
            $('#fileupload').attr('action', response.upload_url);
            $('#edit-gallery-popup').replaceWith(response.edit_popup);
            $('#gallery_selector_id').html(response.gallery_options);
            $('select').selectmenu({
              style: 'dropdown'
            });
            return window.setTimeout("$.modal.close();", 200);
          }
        });
      });
    });
    return $('#images-panel').delegate('.edit-template .price', 'click', function(e) {
      var form, left, node, top;
      node = e.target;
      form = $('#pricing-form');
      left = e.clientX - 60;
      top = e.clientY - form.height();
      return $('#pricing-form').modal({
        opacity: 5,
        position: [top, left],
        escClose: false,
        overlayClose: true,
        onOpen: function(dialog) {
          return dialog.overlay.fadeIn('slow', function() {
            return dialog.container.fadeIn('slow', function() {
              var image_id;
              dialog.data.fadeIn();
              $('#pricing-form .button').fadeOut();
              image_id = $(node).closest('.edit-template').attr('data-id');
              return $.ajax({
                url: '/images/' + image_id + '/pricing',
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                  if (response.success) {
                    $('#price-tiers').html(response.price_table);
                    $('#pricing-form .button').fadeIn();
                    $('#btn-done').click(function() {
                      return requestUpdateTier(node);
                    });
                    initTabs();
                    top = e.clientY - form.height();
                    return form.closest('.simplemodal-container').css('top', "" + top + "px");
                  } else {
                    $('#price-tiers').html(response.msg);
                    $('#pricing-form .button.close').fadeIn();
                    top = e.clientY - form.height();
                    return form.closest('.simplemodal-container').css('top', "" + top + "px");
                  }
                }
              });
            });
          });
        }
      });
    });
  });

}).call(this);