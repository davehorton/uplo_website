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
(function(e){typeof define=="function"&&define.amd?define(["jquery"],e):e(jQuery)})(function(e){var t=[],n=e(document),r=e.browser.msie&&parseInt(e.browser.version)===6&&typeof window.XMLHttpRequest!="object",i=e.browser.msie&&parseInt(e.browser.version)===7,s=null,o=e(window),u=[];e.modal=function(t,n){return e.modal.impl.init(t,n)},e.modal.close=function(){e.modal.impl.close()},e.modal.focus=function(t){e.modal.impl.focus(t)},e.modal.setContainerDimensions=function(){e.modal.impl.setContainerDimensions()},e.modal.setPosition=function(){e.modal.impl.setPosition()},e.modal.update=function(t,n){e.modal.impl.update(t,n)},e.fn.modal=function(t){return e.modal.impl.init(this,t)},e.modal.defaults={appendTo:"body",focus:!0,opacity:50,overlayId:"simplemodal-overlay",overlayCss:{},containerId:"simplemodal-container",containerCss:{},dataId:"simplemodal-data",dataCss:{},minHeight:null,minWidth:null,maxHeight:null,maxWidth:null,autoResize:!1,autoPosition:!0,zIndex:1e3,close:!0,closeHTML:'<a class="modalCloseImg" title="Close"></a>',closeClass:"simplemodal-close",escClose:!0,overlayClose:!1,fixed:!0,position:null,persist:!1,modal:!0,onOpen:null,onShow:null,onClose:null},e.modal.impl={d:{},init:function(t,n){var r=this;if(r.d.data)return!1;s=e.browser.msie&&!e.boxModel,r.o=e.extend({},e.modal.defaults,n),r.zIndex=r.o.zIndex,r.occb=!1;if(typeof t=="object")t=t instanceof jQuery?t:e(t),r.d.placeholder=!1,t.parent().parent().size()>0&&(t.before(e("<span></span>").attr("id","simplemodal-placeholder").css({display:"none"})),r.d.placeholder=!0,r.display=t.css("display"),r.o.persist||(r.d.orig=t.clone(!0)));else{if(typeof t!="string"&&typeof t!="number")return alert("SimpleModal Error: Unsupported data type: "+typeof t),r;t=e("<div></div>").html(t)}return r.create(t),t=null,r.open(),e.isFunction(r.o.onShow)&&r.o.onShow.apply(r,[r.d]),r},create:function(n){var i=this;i.getDimensions(),i.o.modal&&r&&(i.d.iframe=e('<iframe src="javascript:false;"></iframe>').css(e.extend(i.o.iframeCss,{display:"none",opacity:0,position:"fixed",height:u[0],width:u[1],zIndex:i.o.zIndex,top:0,left:0})).appendTo(i.o.appendTo)),i.d.overlay=e("<div></div>").attr("id",i.o.overlayId).addClass("simplemodal-overlay").css(e.extend(i.o.overlayCss,{display:"none",opacity:i.o.opacity/100,height:i.o.modal?t[0]:0,width:i.o.modal?t[1]:0,position:"fixed",left:0,top:0,zIndex:i.o.zIndex+1})).appendTo(i.o.appendTo),i.d.container=e("<div></div>").attr("id",i.o.containerId).addClass("simplemodal-container").css(e.extend({position:i.o.fixed?"fixed":"absolute"},i.o.containerCss,{display:"none",zIndex:i.o.zIndex+2})).append(i.o.close&&i.o.closeHTML?e(i.o.closeHTML).addClass(i.o.closeClass):"").appendTo(i.o.appendTo),i.d.wrap=e("<div></div>").attr("tabIndex",-1).addClass("simplemodal-wrap").css({height:"100%",outline:0,width:"100%"}).appendTo(i.d.container),i.d.data=n.attr("id",n.attr("id")||i.o.dataId).addClass("simplemodal-data").css(e.extend(i.o.dataCss,{display:"none"})).appendTo("body"),n=null,i.setContainerDimensions(),i.d.data.appendTo(i.d.wrap),(r||s)&&i.fixIE()},bindEvents:function(){var i=this;e("."+i.o.closeClass).bind("click.simplemodal",function(e){e.preventDefault(),i.close()}),i.o.modal&&i.o.close&&i.o.overlayClose&&i.d.overlay.bind("click.simplemodal",function(e){e.preventDefault(),i.close()}),n.bind("keydown.simplemodal",function(e){i.o.modal&&e.keyCode===9?i.watchTab(e):i.o.close&&i.o.escClose&&e.keyCode===27&&(e.preventDefault(),i.close())}),o.bind("resize.simplemodal orientationchange.simplemodal",function(){i.getDimensions(),i.o.autoResize?i.setContainerDimensions():i.o.autoPosition&&i.setPosition(),r||s?i.fixIE():i.o.modal&&(i.d.iframe&&i.d.iframe.css({height:u[0],width:u[1]}),i.d.overlay.css({height:t[0],width:t[1]}))})},unbindEvents:function(){e("."+this.o.closeClass).unbind("click.simplemodal"),n.unbind("keydown.simplemodal"),o.unbind(".simplemodal"),this.d.overlay.unbind("click.simplemodal")},fixIE:function(){var t=this,n=t.o.position;e.each([t.d.iframe||null,t.o.modal?t.d.overlay:null,t.d.container.css("position")==="fixed"?t.d.container:null],function(e,t){if(t){var r="document.body.clientHeight",i="document.body.clientWidth",s="document.body.scrollHeight",o="document.body.scrollLeft",u="document.body.scrollTop",a="document.body.scrollWidth",f="document.documentElement.clientHeight",l="document.documentElement.clientWidth",c="document.documentElement.scrollLeft",h="document.documentElement.scrollTop",d=t[0].style;d.position="absolute";if(e<2)d.removeExpression("height"),d.removeExpression("width"),d.setExpression("height",""+s+" > "+r+" ? "+s+" : "+r+' + "px"'),d.setExpression("width",""+a+" > "+i+" ? "+a+" : "+i+' + "px"');else{var v,m;if(n&&n.constructor===Array){var g=n[0]?typeof n[0]=="number"?n[0].toString():n[0].replace(/px/,""):t.css("top").replace(/px/,"");v=g.indexOf("%")===-1?g+" + (t = "+h+" ? "+h+" : "+u+') + "px"':parseInt(g.replace(/%/,""))+" * (("+f+" || "+r+") / 100) + (t = "+h+" ? "+h+" : "+u+') + "px"';if(n[1]){var y=typeof n[1]=="number"?n[1].toString():n[1].replace(/px/,"");m=y.indexOf("%")===-1?y+" + (t = "+c+" ? "+c+" : "+o+') + "px"':parseInt(y.replace(/%/,""))+" * (("+l+" || "+i+") / 100) + (t = "+c+" ? "+c+" : "+o+') + "px"'}}else v="("+f+" || "+r+") / 2 - (this.offsetHeight / 2) + (t = "+h+" ? "+h+" : "+u+') + "px"',m="("+l+" || "+i+") / 2 - (this.offsetWidth / 2) + (t = "+c+" ? "+c+" : "+o+') + "px"';d.removeExpression("top"),d.removeExpression("left"),d.setExpression("top",v),d.setExpression("left",m)}}})},focus:function(t){var n=this,r=t&&e.inArray(t,["first","last"])!==-1?t:"first",i=e(":input:enabled:visible:"+r,n.d.wrap);setTimeout(function(){i.length>0?i.focus():n.d.wrap.focus()},10)},getDimensions:function(){var r=this,i=e.browser.opera&&e.browser.version>"9.5"&&e.fn.jquery<"1.3"||e.browser.opera&&e.browser.version<"9.5"&&e.fn.jquery>"1.2.6"?o[0].innerHeight:o.height();t=[n.height(),n.width()],u=[i,o.width()]},getVal:function(e,t){return e?typeof e=="number"?e:e==="auto"?0:e.indexOf("%")>0?parseInt(e.replace(/%/,""))/100*(t==="h"?u[0]:u[1]):parseInt(e.replace(/px/,"")):null},update:function(e,t){var n=this;if(!n.d.data)return!1;n.d.origHeight=n.getVal(e,"h"),n.d.origWidth=n.getVal(t,"w"),n.d.data.hide(),e&&n.d.container.css("height",e),t&&n.d.container.css("width",t),n.setContainerDimensions(),n.d.data.show(),n.o.focus&&n.focus(),n.unbindEvents(),n.bindEvents()},setContainerDimensions:function(){var t=this,n=r||i,s=t.d.origHeight?t.d.origHeight:e.browser.opera?t.d.container.height():t.getVal(n?t.d.container[0].currentStyle.height:t.d.container.css("height"),"h"),o=t.d.origWidth?t.d.origWidth:e.browser.opera?t.d.container.width():t.getVal(n?t.d.container[0].currentStyle.width:t.d.container.css("width"),"w"),a=t.d.data.outerHeight(!0),f=t.d.data.outerWidth(!0);t.d.origHeight=t.d.origHeight||s,t.d.origWidth=t.d.origWidth||o;var l=t.o.maxHeight?t.getVal(t.o.maxHeight,"h"):null,c=t.o.maxWidth?t.getVal(t.o.maxWidth,"w"):null,h=l&&l<u[0]?l:u[0],p=c&&c<u[1]?c:u[1],d=t.o.minHeight?t.getVal(t.o.minHeight,"h"):"auto";s?s=t.o.autoResize&&s>h?h:s<d?d:s:a?a>h?s=h:t.o.minHeight&&d!=="auto"&&a<d?s=d:s=a:s=d;var v=t.o.minWidth?t.getVal(t.o.minWidth,"w"):"auto";o?o=t.o.autoResize&&o>p?p:o<v?v:o:f?f>p?o=p:t.o.minWidth&&v!=="auto"&&f<v?o=v:o=f:o=v,t.d.container.css({height:s,width:o}),t.d.wrap.css({overflow:a>s||f>o?"auto":"visible"}),t.o.autoPosition&&t.setPosition()},setPosition:function(){var e=this,t,n,r=u[0]/2-e.d.container.outerHeight(!0)/2,i=u[1]/2-e.d.container.outerWidth(!0)/2,s=e.d.container.css("position")!=="fixed"?o.scrollTop():0;e.o.position&&Object.prototype.toString.call(e.o.position)==="[object Array]"?(t=s+(e.o.position[0]||r),n=e.o.position[1]||i):(t=s+r,n=i),e.d.container.css({left:n,top:t})},watchTab:function(t){var n=this;if(e(t.target).parents(".simplemodal-container").length>0){n.inputs=e(":input:enabled:visible:first, :input:enabled:visible:last",n.d.data[0]);if(!t.shiftKey&&t.target===n.inputs[n.inputs.length-1]||t.shiftKey&&t.target===n.inputs[0]||n.inputs.length===0){t.preventDefault();var r=t.shiftKey?"last":"first";n.focus(r)}}else t.preventDefault(),n.focus()},open:function(){var t=this;t.d.iframe&&t.d.iframe.show(),e.isFunction(t.o.onOpen)?t.o.onOpen.apply(t,[t.d]):(t.d.overlay.show(),t.d.container.show(),t.d.data.show()),t.o.focus&&t.focus(),t.bindEvents()},close:function(){var t=this;if(!t.d.data)return!1;t.unbindEvents();if(e.isFunction(t.o.onClose)&&!t.occb)t.occb=!0,t.o.onClose.apply(t,[t.d]);else{if(t.d.placeholder){var n=e("#simplemodal-placeholder");t.o.persist?n.replaceWith(t.d.data.removeClass("simplemodal-data").css("display",t.display)):(t.d.data.hide().remove(),n.replaceWith(t.d.orig))}else t.d.data.hide().remove();t.d.container.hide().remove(),t.d.overlay.hide(),t.d.iframe&&t.d.iframe.hide().remove(),t.d.overlay.remove(),t.d={}}}}});