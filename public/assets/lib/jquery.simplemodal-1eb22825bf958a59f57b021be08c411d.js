/*
 * SimpleModal 1.4.2 - jQuery Plugin
 * http://simplemodal.com/
 * Copyright (c) 2011 Eric Martin
 * Licensed under MIT and GPL
 * Date: Sat, Dec 17 2011 15:35:38 -0800
 */
/**
 * SimpleModal is a lightweight jQuery plugin that provides a simple
 * interface to create a modal dialog.
 *
 * The goal of SimpleModal is to provide developers with a cross-browser
 * overlay and container that will be populated with data provided to
 * SimpleModal.
 *
 * There are two ways to call SimpleModal:
 * 1) As a chained function on a jQuery object, like $('#myDiv').modal();.
 * This call would place the DOM object, #myDiv, inside a modal dialog.
 * Chaining requires a jQuery object. An optional options object can be
 * passed as a parameter.
 *
 * @example $('<div>my data</div>').modal({options});
 * @example $('#myDiv').modal({options});
 * @example jQueryObject.modal({options});
 *
 * 2) As a stand-alone function, like $.modal(data). The data parameter
 * is required and an optional options object can be passed as a second
 * parameter. This method provides more flexibility in the types of data
 * that are allowed. The data could be a DOM object, a jQuery object, HTML
 * or a string.
 *
 * @example $.modal('<div>my data</div>', {options});
 * @example $.modal('my data', {options});
 * @example $.modal($('#myDiv'), {options});
 * @example $.modal(jQueryObject, {options});
 * @example $.modal(document.getElementById('myDiv'), {options});
 *
 * A SimpleModal call can contain multiple elements, but only one modal
 * dialog can be created at a time. Which means that all of the matched
 * elements will be displayed within the modal container.
 *
 * SimpleModal internally sets the CSS needed to display the modal dialog
 * properly in all browsers, yet provides the developer with the flexibility
 * to easily control the look and feel. The styling for SimpleModal can be
 * done through external stylesheets, or through SimpleModal, using the
 * overlayCss, containerCss, and dataCss options.
 *
 * SimpleModal has been tested in the following browsers:
 * - IE 6+
 * - Firefox 2+
 * - Opera 9+
 * - Safari 3+
 * - Chrome 1+
 *
 * @name SimpleModal
 * @type jQuery
 * @requires jQuery v1.2.4
 * @cat Plugins/Windows and Overlays
 * @author Eric Martin (http://ericmmartin.com)
 * @version 1.4.2
 */
(function(a){typeof define=="function"&&define.amd?define(["jquery"],a):a(jQuery)})(function(a){var b=[],c=a(document),d=a.browser.msie&&parseInt(a.browser.version)===6&&typeof window.XMLHttpRequest!="object",e=a.browser.msie&&parseInt(a.browser.version)===7,f=null,g=a(window),h=[];a.modal=function(b,c){return a.modal.impl.init(b,c)},a.modal.close=function(){a.modal.impl.close()},a.modal.focus=function(b){a.modal.impl.focus(b)},a.modal.setContainerDimensions=function(){a.modal.impl.setContainerDimensions()},a.modal.setPosition=function(){a.modal.impl.setPosition()},a.modal.update=function(b,c){a.modal.impl.update(b,c)},a.fn.modal=function(b){return a.modal.impl.init(this,b)},a.modal.defaults={appendTo:"body",focus:!0,opacity:50,overlayId:"simplemodal-overlay",overlayCss:{},containerId:"simplemodal-container",containerCss:{},dataId:"simplemodal-data",dataCss:{},minHeight:null,minWidth:null,maxHeight:null,maxWidth:null,autoResize:!1,autoPosition:!0,zIndex:1e3,close:!0,closeHTML:'<a class="modalCloseImg" title="Close"></a>',closeClass:"simplemodal-close",escClose:!0,overlayClose:!1,fixed:!0,position:null,persist:!1,modal:!0,onOpen:null,onShow:null,onClose:null},a.modal.impl={d:{},init:function(b,c){var d=this;if(d.d.data)return!1;f=a.browser.msie&&!a.boxModel,d.o=a.extend({},a.modal.defaults,c),d.zIndex=d.o.zIndex,d.occb=!1;if(typeof b=="object")b=b instanceof jQuery?b:a(b),d.d.placeholder=!1,b.parent().parent().size()>0&&(b.before(a("<span></span>").attr("id","simplemodal-placeholder").css({display:"none"})),d.d.placeholder=!0,d.display=b.css("display"),d.o.persist||(d.d.orig=b.clone(!0)));else{if(typeof b!="string"&&typeof b!="number")return alert("SimpleModal Error: Unsupported data type: "+typeof b),d;b=a("<div></div>").html(b)}return d.create(b),b=null,d.open(),a.isFunction(d.o.onShow)&&d.o.onShow.apply(d,[d.d]),d},create:function(c){var e=this;e.getDimensions(),e.o.modal&&d&&(e.d.iframe=a('<iframe src="javascript:false;"></iframe>').css(a.extend(e.o.iframeCss,{display:"none",opacity:0,position:"fixed",height:h[0],width:h[1],zIndex:e.o.zIndex,top:0,left:0})).appendTo(e.o.appendTo)),e.d.overlay=a("<div></div>").attr("id",e.o.overlayId).addClass("simplemodal-overlay").css(a.extend(e.o.overlayCss,{display:"none",opacity:e.o.opacity/100,height:e.o.modal?b[0]:0,width:e.o.modal?b[1]:0,position:"fixed",left:0,top:0,zIndex:e.o.zIndex+1})).appendTo(e.o.appendTo),e.d.container=a("<div></div>").attr("id",e.o.containerId).addClass("simplemodal-container").css(a.extend({position:e.o.fixed?"fixed":"absolute"},e.o.containerCss,{display:"none",zIndex:e.o.zIndex+2})).append(e.o.close&&e.o.closeHTML?a(e.o.closeHTML).addClass(e.o.closeClass):"").appendTo(e.o.appendTo),e.d.wrap=a("<div></div>").attr("tabIndex",-1).addClass("simplemodal-wrap").css({height:"100%",outline:0,width:"100%"}).appendTo(e.d.container),e.d.data=c.attr("id",c.attr("id")||e.o.dataId).addClass("simplemodal-data").css(a.extend(e.o.dataCss,{display:"none"})).appendTo("body"),c=null,e.setContainerDimensions(),e.d.data.appendTo(e.d.wrap),(d||f)&&e.fixIE()},bindEvents:function(){var e=this;a("."+e.o.closeClass).bind("click.simplemodal",function(a){a.preventDefault(),e.close()}),e.o.modal&&e.o.close&&e.o.overlayClose&&e.d.overlay.bind("click.simplemodal",function(a){a.preventDefault(),e.close()}),c.bind("keydown.simplemodal",function(a){e.o.modal&&a.keyCode===9?e.watchTab(a):e.o.close&&e.o.escClose&&a.keyCode===27&&(a.preventDefault(),e.close())}),g.bind("resize.simplemodal orientationchange.simplemodal",function(){e.getDimensions(),e.o.autoResize?e.setContainerDimensions():e.o.autoPosition&&e.setPosition(),d||f?e.fixIE():e.o.modal&&(e.d.iframe&&e.d.iframe.css({height:h[0],width:h[1]}),e.d.overlay.css({height:b[0],width:b[1]}))})},unbindEvents:function(){a("."+this.o.closeClass).unbind("click.simplemodal"),c.unbind("keydown.simplemodal"),g.unbind(".simplemodal"),this.d.overlay.unbind("click.simplemodal")},fixIE:function(){var b=this,c=b.o.position;a.each([b.d.iframe||null,b.o.modal?b.d.overlay:null,b.d.container.css("position")==="fixed"?b.d.container:null],function(a,b){if(b){var d="document.body.clientHeight",e="document.body.clientWidth",f="document.body.scrollHeight",g="document.body.scrollLeft",h="document.body.scrollTop",i="document.body.scrollWidth",j="document.documentElement.clientHeight",k="document.documentElement.clientWidth",l="document.documentElement.scrollLeft",m="document.documentElement.scrollTop",n=b[0].style;n.position="absolute";if(a<2)n.removeExpression("height"),n.removeExpression("width"),n.setExpression("height",""+f+" > "+d+" ? "+f+" : "+d+' + "px"'),n.setExpression("width",""+i+" > "+e+" ? "+i+" : "+e+' + "px"');else{var o,q;if(c&&c.constructor===Array){var r=c[0]?typeof c[0]=="number"?c[0].toString():c[0].replace(/px/,""):b.css("top").replace(/px/,"");o=r.indexOf("%")===-1?r+" + (t = "+m+" ? "+m+" : "+h+') + "px"':parseInt(r.replace(/%/,""))+" * (("+j+" || "+d+") / 100) + (t = "+m+" ? "+m+" : "+h+') + "px"';if(c[1]){var s=typeof c[1]=="number"?c[1].toString():c[1].replace(/px/,"");q=s.indexOf("%")===-1?s+" + (t = "+l+" ? "+l+" : "+g+') + "px"':parseInt(s.replace(/%/,""))+" * (("+k+" || "+e+") / 100) + (t = "+l+" ? "+l+" : "+g+') + "px"'}}else o="("+j+" || "+d+") / 2 - (this.offsetHeight / 2) + (t = "+m+" ? "+m+" : "+h+') + "px"',q="("+k+" || "+e+") / 2 - (this.offsetWidth / 2) + (t = "+l+" ? "+l+" : "+g+') + "px"';n.removeExpression("top"),n.removeExpression("left"),n.setExpression("top",o),n.setExpression("left",q)}}})},focus:function(b){var c=this,d=b&&a.inArray(b,["first","last"])!==-1?b:"first",e=a(":input:enabled:visible:"+d,c.d.wrap);setTimeout(function(){e.length>0?e.focus():c.d.wrap.focus()},10)},getDimensions:function(){var d=this,e=a.browser.opera&&a.browser.version>"9.5"&&a.fn.jquery<"1.3"||a.browser.opera&&a.browser.version<"9.5"&&a.fn.jquery>"1.2.6"?g[0].innerHeight:g.height();b=[c.height(),c.width()],h=[e,g.width()]},getVal:function(a,b){return a?typeof a=="number"?a:a==="auto"?0:a.indexOf("%")>0?parseInt(a.replace(/%/,""))/100*(b==="h"?h[0]:h[1]):parseInt(a.replace(/px/,"")):null},update:function(a,b){var c=this;if(!c.d.data)return!1;c.d.origHeight=c.getVal(a,"h"),c.d.origWidth=c.getVal(b,"w"),c.d.data.hide(),a&&c.d.container.css("height",a),b&&c.d.container.css("width",b),c.setContainerDimensions(),c.d.data.show(),c.o.focus&&c.focus(),c.unbindEvents(),c.bindEvents()},setContainerDimensions:function(){var b=this,c=d||e,f=b.d.origHeight?b.d.origHeight:a.browser.opera?b.d.container.height():b.getVal(c?b.d.container[0].currentStyle.height:b.d.container.css("height"),"h"),g=b.d.origWidth?b.d.origWidth:a.browser.opera?b.d.container.width():b.getVal(c?b.d.container[0].currentStyle.width:b.d.container.css("width"),"w"),i=b.d.data.outerHeight(!0),j=b.d.data.outerWidth(!0);b.d.origHeight=b.d.origHeight||f,b.d.origWidth=b.d.origWidth||g;var k=b.o.maxHeight?b.getVal(b.o.maxHeight,"h"):null,l=b.o.maxWidth?b.getVal(b.o.maxWidth,"w"):null,m=k&&k<h[0]?k:h[0],n=l&&l<h[1]?l:h[1],o=b.o.minHeight?b.getVal(b.o.minHeight,"h"):"auto";f?f=b.o.autoResize&&f>m?m:f<o?o:f:i?i>m?f=m:b.o.minHeight&&o!=="auto"&&i<o?f=o:f=i:f=o;var p=b.o.minWidth?b.getVal(b.o.minWidth,"w"):"auto";g?g=b.o.autoResize&&g>n?n:g<p?p:g:j?j>n?g=n:b.o.minWidth&&p!=="auto"&&j<p?g=p:g=j:g=p,b.d.container.css({height:f,width:g}),b.d.wrap.css({overflow:i>f||j>g?"auto":"visible"}),b.o.autoPosition&&b.setPosition()},setPosition:function(){var a=this,b,c,d=h[0]/2-a.d.container.outerHeight(!0)/2,e=h[1]/2-a.d.container.outerWidth(!0)/2,f=a.d.container.css("position")!=="fixed"?g.scrollTop():0;a.o.position&&Object.prototype.toString.call(a.o.position)==="[object Array]"?(b=f+(a.o.position[0]||d),c=a.o.position[1]||e):(b=f+d,c=e),a.d.container.css({left:c,top:b})},watchTab:function(b){var c=this;if(a(b.target).parents(".simplemodal-container").length>0){c.inputs=a(":input:enabled:visible:first, :input:enabled:visible:last",c.d.data[0]);if(!b.shiftKey&&b.target===c.inputs[c.inputs.length-1]||b.shiftKey&&b.target===c.inputs[0]||c.inputs.length===0){b.preventDefault();var d=b.shiftKey?"last":"first";c.focus(d)}}else b.preventDefault(),c.focus()},open:function(){var b=this;b.d.iframe&&b.d.iframe.show(),a.isFunction(b.o.onOpen)?b.o.onOpen.apply(b,[b.d]):(b.d.overlay.show(),b.d.container.show(),b.d.data.show()),b.o.focus&&b.focus(),b.bindEvents()},close:function(){var b=this;if(!b.d.data)return!1;b.unbindEvents();if(a.isFunction(b.o.onClose)&&!b.occb)b.occb=!0,b.o.onClose.apply(b,[b.d]);else{if(b.d.placeholder){var c=a("#simplemodal-placeholder");b.o.persist?c.replaceWith(b.d.data.removeClass("simplemodal-data").css("display",b.display)):(b.d.data.hide().remove(),c.replaceWith(b.d.orig))}else b.d.data.hide().remove();b.d.container.hide().remove(),b.d.overlay.hide(),b.d.iframe&&b.d.iframe.hide().remove(),b.d.overlay.remove(),b.d={}}}}});