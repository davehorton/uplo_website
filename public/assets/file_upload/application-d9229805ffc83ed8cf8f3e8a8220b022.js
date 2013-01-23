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
$(function(){"use strict";$("#fileupload").fileupload(),$("#fileupload").fileupload("option",{maxFileSize:5e6,acceptFileTypes:/(\.|\/)(gif|jpe?g|png)$/i,previewMaxWidth:180,previewMaxHeight:180,autoUpload:!0,displayNumber:page_size}),$.get($("#fileupload").prop("action"),function(e){if(e.length==0)$("#image_data").click();else{var t=$("#fileupload").data("fileupload"),n;t._adjustMaxNumberOfFiles(-e.length),n=t._renderDownload(e).appendTo($("#fileupload .files.download")),t._reflow=t._transition&&n.length&&n[0].offsetWidth,n.addClass("in");var r=$("a"),i=$(".edit button");$.merge(r,i).bind("click",function(e){var t=$(this),n=t.attr("href");if(n==null||n==undefined)n=t.attr("data-url");return $(".fileupload-buttonbar .cancel").click(),window.setTimeout(function(){window.location=n},1500),!1})}});var e=window.location.href.replace(/\/[^\/]*$/,"/result.html?%s");$("#fileupload").bind("fileuploadsend",function(t,n){if(n.dataType.substr(0,6)==="iframe"){var r=$("<a/>").prop("href",n.url)[0];window.location.host!==r.host&&n.formData.push({name:"redirect",value:e})}}),$("#fileupload .files").delegate("a:not([rel^=gallery])","click",function(e){e.preventDefault(),$('<iframe style="display:none;"></iframe>').prop("src",this.href).appendTo(document.body)})});