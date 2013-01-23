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
(function(e){"use strict";window.XDomainRequest&&jQuery.ajaxTransport(function(e){if(e.crossDomain&&e.async){e.timeout&&(e.xdrTimeout=e.timeout,delete e.timeout);var t;return{send:function(n,r){function i(e,n,i,s){t.onload=t.onerror=t.ontimeout=jQuery.noop,t=null,r(e,n,i,s)}t=new XDomainRequest,e.type==="DELETE"?(e.url=e.url+(/\?/.test(e.url)?"&":"?")+"_method=DELETE",e.type="POST"):e.type==="PUT"&&(e.url=e.url+(/\?/.test(e.url)?"&":"?")+"_method=PUT",e.type="POST"),t.open(e.type,e.url),t.onload=function(){i(200,"OK",{text:t.responseText},"Content-Type: "+t.contentType)},t.onerror=function(){i(404,"Not Found")},e.xdrTimeout&&(t.ontimeout=function(){i(0,"timeout")},t.timeout=e.xdrTimeout),t.send(e.hasContent&&e.data||null)},abort:function(){t&&(t.onerror=jQuery.noop(),t.abort())}}}})})(jQuery);