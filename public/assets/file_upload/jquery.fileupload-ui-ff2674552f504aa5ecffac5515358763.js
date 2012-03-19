/*
 * jQuery File Upload User Interface Plugin 6.0.2
 * https://github.com/blueimp/jQuery-File-Upload
 *
 * Copyright 2010, Sebastian Tschan
 * https://blueimp.net
 *
 * Licensed under the MIT license:
 * http://www.opensource.org/licenses/MIT
 */
/*jslint nomen: true, unparam: true, regexp: true */
/*global window, document, URL, webkitURL, FileReader, jQuery */
(function(a){function b(){a("#upload-counter").remove();var b=document.createElement("div");b.id="upload-counter";var c=a(".template-upload").size(),d=c+" file(s) is ready to upload";b.innerHTML=d,a(".gallery-header").append(b)}"use strict",a.widget("blueimpUI.fileupload",a.blueimp.fileupload,{options:{autoUpload:!1,maxNumberOfFiles:undefined,maxFileSize:undefined,minFileSize:1,acceptFileTypes:/.+$/i,previewFileTypes:/^image\/(gif|jpeg|png)$/,previewMaxFileSize:5e6,previewMaxWidth:80,previewMaxHeight:80,previewAsCanvas:!0,dataType:"json",displayNumber:5,add:function(c,d){console.log(a(this));var e=a(this).data("fileupload"),f=d.files;e._adjustMaxNumberOfFiles(-f.length),d.isAdjusted=!0,d.files.valid=d.isValidated=e._validate(f),d.context=e._renderUpload(f).prependTo(a(this).find(".files.upload")).data("data",d),b(),e._reflow=e._transition&&d.context[0].offsetWidth,d.context.addClass("in"),(e.options.autoUpload||d.autoUpload)&&d.isValidated&&d.submit()},send:function(b,c){if(!c.isValidated){var d=a(this).data("fileupload");c.isAdjusted||d._adjustMaxNumberOfFiles(-c.files.length);if(!d._validate(c.files))return!1}c.context&&c.dataType&&c.dataType.substr(0,6)==="iframe"&&c.context.find(".progressbar div").css("width",parseInt(100,10)+"%")},done:function(c,d){var e=a(this).data("fileupload"),f,g;d.context?d.context.each(function(c){var h=a.isArray(d.result)&&d.result[c]||{error:"emptyResult"};h.error&&e._adjustMaxNumberOfFiles(1),e._transitionCallback(a(this).removeClass("in"),function(c){f=e._renderDownload([h]),g=c.find(".preview img, .preview canvas"),g.length&&f.find(".preview img").prop("width",g.prop("width")).prop("height",g.prop("height")),f.replaceAll(c).prependTo(a(".files.download")),b(),e._reflow=e._transition&&f[0].offsetWidth,f.addClass("in")})}):(f=e._renderDownload(d.result).prependTo(a(".files.download")),e._reflow=e._transition&&f[0].offsetWidth,f.addClass("in"),a(".files.download").children().size()>this.options.displayNumber&&a(".files.download").children().last().remove())},fail:function(b,c){var d=a(this).data("fileupload"),e;d._adjustMaxNumberOfFiles(c.files.length),c.context?c.context.each(function(b){if(c.errorThrown!=="abort"){var f=c.files[b];f.error=f.error||c.errorThrown||!0,d._transitionCallback(a(this).removeClass("in"),function(a){e=d._renderDownload([f]).replaceAll(a),d._reflow=d._transition&&e[0].offsetWidth,e.addClass("in")})}else d._transitionCallback(a(this).removeClass("in"),function(a){a.remove()})}):c.errorThrown!=="abort"&&(d._adjustMaxNumberOfFiles(-c.files.length),c.context=d._renderUpload(c.files).appendTo(d._files).data("data",c),d._reflow=d._transition&&c.context[0].offsetWidth,c.context.addClass("in"))},progress:function(a,b){b.context&&b.context.find(".progressbar div").css("width",parseInt(b.loaded/b.total*100,10)+"%")},progressall:function(b,c){a(this).find(".fileupload-progressbar div").css("width",parseInt(c.loaded/c.total*100,10)+"%")},start:function(){a(this).find(".fileupload-progressbar div").css("width","0%")},stop:function(){a(this).find(".fileupload-progressbar div").css("width","0%")},destroy:function(b,c){var d=a(this).data("fileupload");c.url&&(c.success=function(b){b.success==1?a.get(a("#fileupload").prop("action"),function(b){var c=a("#fileupload").data("fileupload"),d=a("#fileupload .files.download"),e;d.empty(),c._adjustMaxNumberOfFiles(-b.length),e=c._renderDownload(b).appendTo(d),c._reflow=c._transition&&e.length&&e[0].offsetWidth,e.addClass("in")}):alert("Something went wrong! Cannot delete this picture")},a.ajax(c))}},_enableDragToDesktop:function(){var b=a(this),c=b.prop("href"),d=decodeURIComponent(c.split("/").pop()).replace(/:/g,"-"),e="application/octet-stream";b.bind("dragstart",function(a){try{a.originalEvent.dataTransfer.setData("DownloadURL",[e,d,c].join(":"))}catch(b){}})},_adjustMaxNumberOfFiles:function(a){typeof this.options.maxNumberOfFiles=="number"&&(this.options.maxNumberOfFiles+=a,this.options.maxNumberOfFiles<1?this._disableFileInputButton():this._enableFileInputButton())},_formatFileSize:function(a){return typeof a!="number"?"":a>=1e9?(a/1e9).toFixed(2)+" GB":a>=1e6?(a/1e6).toFixed(2)+" MB":(a/1e3).toFixed(2)+" KB"},_hasError:function(a){return a.error?a.error:this.options.maxNumberOfFiles<0?"maxNumberOfFiles":!this.options.acceptFileTypes.test(a.type)&&!this.options.acceptFileTypes.test(a.name)?"acceptFileTypes":this.options.maxFileSize&&a.size>this.options.maxFileSize?"maxFileSize":typeof a.size=="number"&&a.size<this.options.minFileSize?"minFileSize":null},_validate:function(b){var c=this,d=!!b.length;return a.each(b,function(a,b){b.error=c._hasError(b),b.error&&(d=!1)}),d},_renderTemplate:function(b,c){return a(this.options.templateContainer).html(b({files:c,formatFileSize:this._formatFileSize,options:this.options})).children()},_renderUpload:function(b){var c=this,d=this.options,e=this._renderTemplate(d.uploadTemplate,b);return e.find(".preview span").each(function(e,f){var g=b[e];d.previewFileTypes.test(g.type)&&(!d.previewMaxFileSize||g.size<d.previewMaxFileSize)&&window.loadImage(b[e],function(b){a(f).append(b),c._reflow=c._transition&&f.offsetWidth,a(f).addClass("in")},{maxWidth:d.previewMaxWidth,maxHeight:d.previewMaxHeight,canvas:d.previewAsCanvas})}),e},_renderDownload:function(a){var b=this._renderTemplate(this.options.downloadTemplate,a);return b.find("a").each(this._enableDragToDesktop),b},_startHandler:function(b){b.preventDefault();var c=a(this),d=c.closest(".template-upload"),e=d.data("data");e&&e.submit&&!e.jqXHR&&e.submit()&&c.prop("disabled",!0)},_cancelHandler:function(c){c.preventDefault();var d=a(this).closest(".template-upload"),e=d.data("data")||{};e.jqXHR?e.jqXHR.abort():(e.errorThrown="abort",c.data.fileupload._trigger("fail",c,e)),window.setTimeout(function(){b()},200)},_editHandler:function(b){b.preventDefault();var c=a(this);window.location=c.attr("data-url")},_deleteHandler:function(b){b.preventDefault();var c=a(this);b.data.fileupload._trigger("destroy",b,{context:c.closest(".template-download"),url:c.attr("data-url"),type:c.attr("data-type"),dataType:b.data.fileupload.options.dataType})},_transitionCallback:function(a,b){var c=this;this._transition&&a.hasClass("fade")?a.bind(this._transitionEnd,function(d){d.target===a[0]&&(a.unbind(c._transitionEnd),b.call(c,a))}):b.call(this,a)},_initTransitionSupport:function(){var a=this,b=(document.body||document.documentElement).style,c="."+a.options.namespace;a._transition=b.transition!==undefined||b.WebkitTransition!==undefined||b.MozTransition!==undefined||b.MsTransition!==undefined||b.OTransition!==undefined,a._transition&&(a._transitionEnd=["TransitionEnd","webkitTransitionEnd","transitionend","oTransitionEnd"].join(c+" ")+c)},_initButtonBarEventHandlers:function(){var b=this.element.find(".fileupload-buttonbar"),c=this._files,d=this.options.namespace;b.find(".start").bind("click."+d,function(a){a.preventDefault(),c.find(".start button").click()}),b.find(".cancel").bind("click."+d,function(a){a.preventDefault(),c.find(".cancel button").click()}),b.find(".delete").bind("click."+d,function(b){b.preventDefault();var d=a("#fileupload").data("fileupload"),e=[],f,g;return f=c.find(".delete input:checked"),f.each(function(a,b){e.push(b.getAttribute("data-id"))}),g=a(f[0]).siblings("button").attr("data-url"),g=g.substr(0,g.lastIndexOf("/")),g=g+"/"+e,a.ajax({url:g,success:function(b){b.success==1&&f.each(function(b,c){var e=a(c).closest(".template-download");d._adjustMaxNumberOfFiles(1),d._transitionCallback(e.removeClass("in"),function(a){a.remove()})})}}),!1}),b.find(".toggle").bind("change."+d,function(b){c.find(".delete input").prop("checked",a(this).is(":checked"))})},_destroyButtonBarEventHandlers:function(){this.element.find(".fileupload-buttonbar button").unbind("click."+this.options.namespace),this.element.find(".fileupload-buttonbar .toggle").unbind("change."+this.options.namespace)},_initEventHandlers:function(){var b=this;a.blueimp.fileupload.prototype._initEventHandlers.call(this);var c={fileupload:this};this._files.delegate(".start button","click."+this.options.namespace,c,this._startHandler).delegate(".cancel button","click."+this.options.namespace,c,this._cancelHandler).delegate(".edit button","click."+this.options.namespace,c,this._editHandler).delegate(".delete button","click."+this.options.namespace,c,this._deleteHandler),this._initButtonBarEventHandlers(),this._initTransitionSupport()},_destroyEventHandlers:function(){this._destroyButtonBarEventHandlers(),this._files.undelegate(".start button","click."+this.options.namespace).undelegate(".cancel button","click."+this.options.namespace).undelegate(".delete button","click."+this.options.namespace),a.blueimp.fileupload.prototype._destroyEventHandlers.call(this)},_enableFileInputButton:function(){this.element.find(".fileinput-button input").prop("disabled",!1).parent().removeClass("disabled")},_disableFileInputButton:function(){this.element.find(".fileinput-button input").prop("disabled",!0).parent().addClass("disabled")},_initTemplates:function(){this.options.templateContainer=document.createElement(this._files.prop("nodeName")),this.options.uploadTemplate=window.tmpl("template-upload"),this.options.downloadTemplate=window.tmpl("template-download")},_initFiles:function(){this._files=this.element.find(".files")},_create:function(){this._initFiles(),a.blueimp.fileupload.prototype._create.call(this),this._initTemplates()},destroy:function(){a.blueimp.fileupload.prototype.destroy.call(this)},enable:function(){a.blueimp.fileupload.prototype.enable.call(this),this.element.find("input, button").prop("disabled",!1),this._enableFileInputButton()},disable:function(){this.element.find("input, button").prop("disabled",!0),this._disableFileInputButton(),a.blueimp.fileupload.prototype.disable.call(this)}})})(jQuery);