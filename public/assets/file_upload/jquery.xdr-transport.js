/*
 * jQuery XDomainRequest Transport Plugin 1.0.1
 * https://github.com/blueimp/jQuery-File-Upload
 *
 * Copyright 2011, Sebastian Tschan
 * https://blueimp.net
 *
 * Licensed under the MIT license:
 * http://www.opensource.org/licenses/MIT
 *
 * Based on Julian Aubourg's ajaxHooks xdr.js:
 * https://github.com/jaubourg/ajaxHooks/
 */
/*jslint unparam: true */
/*global jQuery, window, XDomainRequest */
(function(a){"use strict",window.XDomainRequest&&jQuery.ajaxTransport(function(a){if(a.crossDomain&&a.async){a.timeout&&(a.xdrTimeout=a.timeout,delete a.timeout);var b;return{send:function(c,d){function e(a,c,e,f){b.onload=b.onerror=b.ontimeout=jQuery.noop,b=null,d(a,c,e,f)}b=new XDomainRequest,a.type==="DELETE"?(a.url=a.url+(/\?/.test(a.url)?"&":"?")+"_method=DELETE",a.type="POST"):a.type==="PUT"&&(a.url=a.url+(/\?/.test(a.url)?"&":"?")+"_method=PUT",a.type="POST"),b.open(a.type,a.url),b.onload=function(){e(200,"OK",{text:b.responseText},"Content-Type: "+b.contentType)},b.onerror=function(){e(404,"Not Found")},a.xdrTimeout&&(b.ontimeout=function(){e(0,"timeout")},b.timeout=a.xdrTimeout),b.send(a.hasContent&&a.data||null)},abort:function(){b&&(b.onerror=jQuery.noop(),b.abort())}}}})})(jQuery);