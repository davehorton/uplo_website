/*
 * jQuery File Upload Plugin JS Example 6.0
 * https://github.com/blueimp/jQuery-File-Upload
 *
 * Copyright 2010, Sebastian Tschan
 * https://blueimp.net
 *
 * Licensed under the MIT license:
 * http://www.opensource.org/licenses/MIT
 */

/*jslint nomen: true, unparam: true, regexp: true */
/*global $, window, document */
$(function () {

    'use strict';
    // Initialize the jQuery File Upload widget:
    $('#fileupload').fileupload();

    $('#fileupload').fileupload('option', {
        maxFileSize: 5000000,
        acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i,
        previewMaxWidth: 180,
        previewMaxHeight: 180,
        autoUpload: true,
        displayNumber: page_size
    });
    // Load existing files:
    $.get($('#fileupload').prop('action'), function (files) {
        if(files.length == 0){
            $("#image_data").click();
        }else{
            var fu = $('#fileupload').data('fileupload'),
                template;

            fu._adjustMaxNumberOfFiles(-files.length);
            template = fu._renderDownload(files)
                .appendTo($('#fileupload .files.download'));
            // Force reflow:
            fu._reflow = fu._transition && template.length &&
                template[0].offsetWidth;
            template.addClass('in');

            var links = $("a");
            var edit_btns = $(".edit button");
            $.merge(links, edit_btns).bind('click', function(e){

                var targetObj = $(this);
                var url = targetObj.attr("href");
                if(url==null || url==undefined){
                  url = targetObj.attr("data-url");
                }
                $(".fileupload-buttonbar .cancel").click();
                window.setTimeout(function(){
                  window.location = url;
                }, 1500);
                return false;

            })
        }
    });

    // Enable iframe cross-domain access via redirect page:
    var redirectPage = window.location.href.replace(
        /\/[^\/]*$/,
        '/result.html?%s'
    );
    $('#fileupload').bind('fileuploadsend', function (e, data) {
        if (data.dataType.substr(0, 6) === 'iframe') {
            var target = $('<a/>').prop('href', data.url)[0];
            if (window.location.host !== target.host) {
                data.formData.push({
                    name: 'redirect',
                    value: redirectPage
                });
            }
        }
    });

    // Open download dialogs via iframes,
    // to prevent aborting current uploads:
    $('#fileupload .files').delegate(
        'a:not([rel^=gallery])',
        'click',
        function (e) {
            e.preventDefault();
            $('<iframe style="display:none;"></iframe>')
                .prop('src', this.href)
                .appendTo(document.body);
        }
    );

    // Initialize the Bootstrap Image Gallery plugin:
//    $('#fileupload .files').imagegallery();

});
