/*
 * Poshy Tip jQuery plugin v1.1+
 * http://vadikom.com/tools/poshy-tip-jquery-plugin-for-stylish-tooltips/
 * Copyright 2010-2011, Vasil Dinkov, http://vadikom.com/
 */
(function(a){function f(){a.each(b,function(){this.refresh(!0)})}var b=[],c=/^url\(["']?([^"'\)]*)["']?\);?$/i,d=/\.png$/i,e=a.browser.msie&&a.browser.version==6;a(window).resize(f),a.Poshytip=function(b,c){this.$elm=a(b),this.opts=a.extend({},a.fn.poshytip.defaults,c),this.$tip=a(['<div class="',this.opts.className,'">','<div class="tip-inner tip-bg-image"></div>','<div class="tip-arrow tip-arrow-top tip-arrow-right tip-arrow-bottom tip-arrow-left"></div>',"</div>"].join("")).appendTo(document.body),this.$arrow=this.$tip.find("div.tip-arrow"),this.$inner=this.$tip.find("div.tip-inner"),this.disabled=!1,this.content=null,this.init()},a.Poshytip.prototype={init:function(){b.push(this);var c=this.$elm.attr("title");this.$elm.data("title.poshytip",c!==undefined?c:null).data("poshytip",this);if(this.opts.showOn!="none"){this.$elm.bind({"mouseenter.poshytip":a.proxy(this.mouseenter,this),"mouseleave.poshytip":a.proxy(this.mouseleave,this)});switch(this.opts.showOn){case"hover":this.opts.alignTo=="cursor"&&this.$elm.bind("mousemove.poshytip",a.proxy(this.mousemove,this)),this.opts.allowTipHover&&this.$tip.hover(a.proxy(this.clearTimeouts,this),a.proxy(this.mouseleave,this));break;case"focus":this.$elm.bind({"focus.poshytip":a.proxy(this.show,this),"blur.poshytip":a.proxy(this.hide,this)})}}},mouseenter:function(b){if(this.disabled)return!0;this.$elm.attr("title","");if(this.opts.showOn=="focus")return!0;this.clearTimeouts(),this.showTimeout=setTimeout(a.proxy(this.show,this),this.opts.showTimeout)},mouseleave:function(b){if(this.disabled||this.asyncAnimating&&(this.$tip[0]===b.relatedTarget||jQuery.contains(this.$tip[0],b.relatedTarget)))return!0;var c=this.$elm.data("title.poshytip");c!==null&&this.$elm.attr("title",c);if(this.opts.showOn=="focus")return!0;this.clearTimeouts(),this.hideTimeout=setTimeout(a.proxy(this.hide,this),this.opts.hideTimeout)},mousemove:function(a){if(this.disabled)return!0;this.eventX=a.pageX,this.eventY=a.pageY,this.opts.followCursor&&this.$tip.data("active")&&(this.calcPos(),this.$tip.css({left:this.pos.l,top:this.pos.t}),this.pos.arrow&&(this.$arrow[0].className="tip-arrow tip-arrow-"+this.pos.arrow))},show:function(){if(this.disabled||this.$tip.data("active"))return;this.reset(),this.update(),this.display(),this.opts.timeOnScreen&&(this.clearTimeouts(),this.hideTimeout=setTimeout(a.proxy(this.hide,this),this.opts.timeOnScreen))},hide:function(){if(this.disabled||!this.$tip.data("active"))return;this.display(!0)},reset:function(){this.$tip.queue([]).detach().css("visibility","hidden").data("active",!1),this.$inner.find("*").poshytip("hide"),this.opts.fade&&this.$tip.css("opacity",this.opacity),this.$arrow[0].className="tip-arrow tip-arrow-top tip-arrow-right tip-arrow-bottom tip-arrow-left",this.asyncAnimating=!1},update:function(a,b){if(this.disabled)return;var c=a!==undefined;if(c){b||(this.opts.content=a);if(!this.$tip.data("active"))return}else a=this.opts.content;var d=this,e=typeof a=="function"?a.call(this.$elm[0],function(a){d.update(a)}):a=="[title]"?this.$elm.data("title.poshytip"):a;this.content!==e&&(this.$inner.empty().append(e),this.content=e),this.refresh(c)},refresh:function(b){if(this.disabled)return;if(b){if(!this.$tip.data("active"))return;var f={left:this.$tip.css("left"),top:this.$tip.css("top")}}this.$tip.css({left:0,top:0}).appendTo(document.body),this.opacity===undefined&&(this.opacity=this.$tip.css("opacity"));var g=this.$tip.css("background-image").match(c),h=this.$arrow.css("background-image").match(c);if(g){var i=d.test(g[1]);e&&i?(this.$tip.css("background-image","none"),this.$inner.css({margin:0,border:0,padding:0}),g=i=!1):this.$tip.prepend('<table border="0" cellpadding="0" cellspacing="0"><tr><td class="tip-top tip-bg-image" colspan="2"><span></span></td><td class="tip-right tip-bg-image" rowspan="2"><span></span></td></tr><tr><td class="tip-left tip-bg-image" rowspan="2"><span></span></td><td></td></tr><tr><td class="tip-bottom tip-bg-image" colspan="2"><span></span></td></tr></table>').css({border:0,padding:0,"background-image":"none","background-color":"transparent"}).find(".tip-bg-image").css("background-image",'url("'+g[1]+'")').end().find("td").eq(3).append(this.$inner),i&&!a.support.opacity&&(this.opts.fade=!1)}h&&!a.support.opacity&&(e&&d.test(h[1])&&(h=!1,this.$arrow.css("background-image","none")),this.opts.fade=!1);var j=this.$tip.find("table");if(e){this.$tip[0].style.width="",j.width("auto").find("td").eq(3).width("auto");var k=this.$tip.width(),l=parseInt(this.$tip.css("min-width")),m=parseInt(this.$tip.css("max-width"));!isNaN(l)&&k<l?k=l:!isNaN(m)&&k>m&&(k=m),this.$tip.add(j).width(k).eq(0).find("td").eq(3).width("100%")}else j[0]&&j.width("auto").find("td").eq(3).width("auto").end().end().width(document.defaultView&&document.defaultView.getComputedStyle&&parseFloat(document.defaultView.getComputedStyle(this.$tip[0],null).width)||this.$tip.width()).find("td").eq(3).width("100%");this.tipOuterW=this.$tip.outerWidth(),this.tipOuterH=this.$tip.outerHeight(),this.calcPos(),h&&this.pos.arrow&&(this.$arrow[0].className="tip-arrow tip-arrow-"+this.pos.arrow,this.$arrow.css("visibility","inherit"));if(b&&this.opts.refreshAniDuration){this.asyncAnimating=!0;var n=this;this.$tip.css(f).animate({left:this.pos.l,top:this.pos.t},this.opts.refreshAniDuration,function(){n.asyncAnimating=!1})}else this.$tip.css({left:this.pos.l,top:this.pos.t})},display:function(b){var c=this.$tip.data("active");if(c&&!b||!c&&b)return;this.$tip.stop();if((this.opts.slide&&this.pos.arrow||this.opts.fade)&&(b&&this.opts.hideAniDuration||!b&&this.opts.showAniDuration)){var d={},e={};if(this.opts.slide&&this.pos.arrow){var f,g;this.pos.arrow=="bottom"||this.pos.arrow=="top"?(f="top",g="bottom"):(f="left",g="right");var h=parseInt(this.$tip.css(f));d[f]=h+(b?0:this.pos.arrow==g?-this.opts.slideOffset:this.opts.slideOffset),e[f]=h+(b?this.pos.arrow==g?this.opts.slideOffset:-this.opts.slideOffset:0)+"px"}this.opts.fade&&(d.opacity=b?this.$tip.css("opacity"):0,e.opacity=b?0:this.opacity),this.$tip.css(d).animate(e,this.opts[b?"hideAniDuration":"showAniDuration"])}b?this.$tip.queue(a.proxy(this.reset,this)):this.$tip.css("visibility","inherit"),this.$tip.data("active",!c)},disable:function(){this.reset(),this.disabled=!0},enable:function(){this.disabled=!1},destroy:function(){this.reset(),this.$tip.remove(),delete this.$tip,this.content=null,this.$elm.unbind(".poshytip").removeData("title.poshytip").removeData("poshytip"),b.splice(a.inArray(this,b),1)},clearTimeouts:function(){this.showTimeout&&(clearTimeout(this.showTimeout),this.showTimeout=0),this.hideTimeout&&(clearTimeout(this.hideTimeout),this.hideTimeout=0)},calcPos:function(){var b={l:0,t:0,arrow:""},c=a(window),d={l:c.scrollLeft(),t:c.scrollTop(),w:c.width(),h:c.height()},e,f,g,h,i,j;if(this.opts.alignTo=="cursor")e=f=g=this.eventX,h=i=j=this.eventY;else{var k=this.$elm.offset(),l={l:k.left,t:k.top,w:this.$elm.outerWidth(),h:this.$elm.outerHeight()};e=l.l+(this.opts.alignX!="inner-right"?0:l.w),f=e+Math.floor(l.w/2),g=e+(this.opts.alignX!="inner-left"?l.w:0),h=l.t+(this.opts.alignY!="inner-bottom"?0:l.h),i=h+Math.floor(l.h/2),j=h+(this.opts.alignY!="inner-top"?l.h:0)}switch(this.opts.alignX){case"right":case"inner-left":b.l=g+this.opts.offsetX,b.l+this.tipOuterW>d.l+d.w&&(b.l=d.l+d.w-this.tipOuterW);if(this.opts.alignX=="right"||this.opts.alignY=="center")b.arrow="left";break;case"center":b.l=f-Math.floor(this.tipOuterW/2),b.l+this.tipOuterW>d.l+d.w?b.l=d.l+d.w-this.tipOuterW:b.l<d.l&&(b.l=d.l);break;default:b.l=e-this.tipOuterW-this.opts.offsetX,b.l<d.l&&(b.l=d.l);if(this.opts.alignX=="left"||this.opts.alignY=="center")b.arrow="right"}switch(this.opts.alignY){case"bottom":case"inner-top":b.t=j+this.opts.offsetY;if(!b.arrow||this.opts.alignTo=="cursor")b.arrow="top";b.t+this.tipOuterH>d.t+d.h&&(b.t=h-this.tipOuterH-this.opts.offsetY,b.arrow=="top"&&(b.arrow="bottom"));break;case"center":b.t=i-Math.floor(this.tipOuterH/2),b.t+this.tipOuterH>d.t+d.h?b.t=d.t+d.h-this.tipOuterH:b.t<d.t&&(b.t=d.t);break;default:b.t=h-this.tipOuterH-this.opts.offsetY;if(!b.arrow||this.opts.alignTo=="cursor")b.arrow="bottom";b.t<d.t&&(b.t=j+this.opts.offsetY,b.arrow=="bottom"&&(b.arrow="top"))}this.pos=b}},a.fn.poshytip=function(b){if(typeof b=="string"){var c=arguments,d=b;return Array.prototype.shift.call(c),d=="destroy"&&this.die("mouseenter.poshytip").die("focus.poshytip"),this.each(function(){var b=a(this).data("poshytip");b&&b[d]&&b[d].apply(b,c)})}var e=a.extend({},a.fn.poshytip.defaults,b);a("#poshytip-css-"+e.className)[0]||a(['<style id="poshytip-css-',e.className,'" type="text/css">',"div.",e.className,"{visibility:hidden;position:absolute;top:0;left:0;}","div.",e.className," table, div.",e.className," td{margin:0;font-family:inherit;font-size:inherit;font-weight:inherit;font-style:inherit;font-variant:inherit;}","div.",e.className," td.tip-bg-image span{display:block;font:1px/1px sans-serif;height:",e.bgImageFrameSize,"px;width:",e.bgImageFrameSize,"px;overflow:hidden;}","div.",e.className," td.tip-right{background-position:100% 0;}","div.",e.className," td.tip-bottom{background-position:100% 100%;}","div.",e.className," td.tip-left{background-position:0 100%;}","div.",e.className," div.tip-inner{background-position:-",e.bgImageFrameSize,"px -",e.bgImageFrameSize,"px;}","div.",e.className," div.tip-arrow{visibility:hidden;position:absolute;overflow:hidden;font:1px/1px sans-serif;}","</style>"].join("")).appendTo("head");if(e.liveEvents&&e.showOn!="none"){var f=a.extend({},e,{liveEvents:!1});switch(e.showOn){case"hover":this.live("mouseenter.poshytip",function(){var b=a(this);b.data("poshytip")||b.poshytip(f).poshytip("mouseenter")});break;case"focus":this.live("focus.poshytip",function(){var b=a(this);b.data("poshytip")||b.poshytip(f).poshytip("show")})}return this}return this.each(function(){new a.Poshytip(this,e)})},a.fn.poshytip.defaults={content:"[title]",className:"tip-yellow",bgImageFrameSize:10,showTimeout:500,hideTimeout:100,timeOnScreen:0,showOn:"hover",liveEvents:!1,alignTo:"cursor",alignX:"right",alignY:"top",offsetX:-22,offsetY:18,allowTipHover:!0,followCursor:!1,fade:!0,slide:!0,slideOffset:8,showAniDuration:300,hideAniDuration:300,refreshAniDuration:200}})(jQuery);