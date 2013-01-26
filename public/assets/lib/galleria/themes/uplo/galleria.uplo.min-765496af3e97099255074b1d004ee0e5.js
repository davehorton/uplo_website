/**
 * @preserve UPLO theme for Galleria
 * http://uplo.heroku.com
 *
 * Copyright (c) 2012, TPL
 * Licensed under the MIT license.
 */
/*global jQuery, Galleria */
Galleria.requires(1.25,"This version of Classic theme requires Galleria 1.2.5 or later"),function(e){Galleria.addTheme({name:"uplo",author:"Galleria",css:"galleria.uplo.css",defaults:{transition:"slide",thumbCrop:"height",_toggleInfo:!0},init:function(t){var n=.6;this.addElement("info-link","info-close"),this.append({info:["info-link","info-close"]});var r=this.$("info-link,info-close,info-text"),i=Galleria.TOUCH,s=i?"touchstart":"click";this.$("loader,counter").show().css("opacity",.2),this.remove("info-description"),this.$("thumbnails").css({height:"84px"}),i||(this.addIdleState(this.get("image-nav-left"),{left:-50}),this.addIdleState(this.get("image-nav-right"),{right:-50}),this.addIdleState(this.get("counter"),{opacity:0})),t._toggleInfo===!0?r.bind(s,function(){r.toggle(400)}):(r.fadeIn(400),this.$("info-link, info-close").fadeOut(400)),this.bind("thumbnail",function(t){i?this.getIndex()?e(t.thumbTarget).parent().addClass("current"):e(t.thumbTarget).parent().removeClass("current"):(e(t.thumbTarget).parent().hover(function(){e(this).not(".active").children().stop().fadeTo(100,1)},function(){e(this).not(".active").children().stop().fadeTo(400,n)}),t.index===this.getIndex()&&e(t.thumbTarget).parent().addClass("current"))}),this.bind("loadstart",function(t){if(!t.cached){this.$("loader").show().fadeTo(200,n);var r=this.$("stage"),i=!1,s=this;e(r).find(".galleria-image").each(function(n,r){if(!i&&e(r).css("opacity")=="1"){i=!0;var o=e(r).find("img"),u=!1;if(!o||o.length<=0){var a=e(t.thumbTarget).clone();e(a).addClass("show-by-thumbnail"),e(r).append(a)}else{if(e(o).hasClass("show-by-thumbnail"))return u=!0,!1;e(o).attr("src",e(t.thumbTarget).attr("src")),e(o).addClass("show-by-thumbnail")}u||(s.show(t.index),s._queue={length:0});return}})}this.$("info").toggle(this.hasInfo());var o=e(t.thumbTarget).css("opacity",1).parent().addClass("current");e(o).siblings().removeClass("current")}),this.bind("loadfinish",function(e){this.$("loader").fadeOut(200)}),this.bind("image",function(e){})}})}(jQuery);