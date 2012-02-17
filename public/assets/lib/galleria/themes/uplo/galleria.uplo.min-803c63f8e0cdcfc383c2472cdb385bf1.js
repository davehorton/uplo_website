/**
 * @preserve UPLO theme for Galleria
 * http://uplo.heroku.com
 *
 * Copyright (c) 2012, TPL
 * Licensed under the MIT license.
 */
/*global jQuery, Galleria */
Galleria.requires(1.25,"This version of Classic theme requires Galleria 1.2.5 or later"),function(a){Galleria.addTheme({name:"uplo",author:"Galleria",css:"galleria.uplo.css",defaults:{transition:"slide",thumbCrop:"height",_toggleInfo:!0},init:function(b){var c=.6;this.addElement("info-link","info-close"),this.append({info:["info-link","info-close"]});var d=this.$("info-link,info-close,info-text"),e=Galleria.TOUCH,f=e?"touchstart":"click";this.$("loader,counter").show().css("opacity",.2),this.remove("info-description"),this.$("thumbnails").css({height:"84px"}),e||(this.addIdleState(this.get("image-nav-left"),{left:-50}),this.addIdleState(this.get("image-nav-right"),{right:-50}),this.addIdleState(this.get("counter"),{opacity:0})),b._toggleInfo===!0?d.bind(f,function(){d.toggle(400)}):(d.fadeIn(400),this.$("info-link, info-close").fadeOut(400)),this.bind("thumbnail",function(b){e?this.getIndex()?a(b.thumbTarget).parent().addClass("current"):a(b.thumbTarget).parent().removeClass("current"):(a(b.thumbTarget).parent().hover(function(){a(this).not(".active").children().stop().fadeTo(100,1)},function(){a(this).not(".active").children().stop().fadeTo(400,c)}),b.index===this.getIndex()&&a(b.thumbTarget).parent().addClass("current"))}),this.bind("loadstart",function(b){if(!b.cached){this.$("loader").show().fadeTo(200,c),console.log("wait for loading the image");var d=this.$("stage"),e=!1;a(d).find(".galleria-image").each(function(c,d){if(!e&&a(d).css("opacity")=="1"){e=!0;var f=a(d).find("img");!f||f.length<=0?(console.log("append the thumbnail"),a(d).append(a(b.thumbTarget).clone())):(console.log("change the image src"),a(f).attr("src",a(b.thumbTarget).attr("src")));return}})}this.$("info").toggle(this.hasInfo());var f=a(b.thumbTarget).css("opacity",1).parent().addClass("current");a(f).siblings().removeClass("current")}),this.bind("loadfinish",function(a){this.$("loader").fadeOut(200),console.log(">> finish load")})}})}(jQuery)