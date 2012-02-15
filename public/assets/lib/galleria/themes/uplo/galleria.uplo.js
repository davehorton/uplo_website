/**
 * @preserve UPLO theme for Galleria
 * http://uplo.heroku.com
 *
 * Copyright (c) 2012, TPL
 * Licensed under the MIT license.
 */
/*global jQuery, Galleria */
Galleria.requires(1.25,"This version of Classic theme requires Galleria 1.2.5 or later"),function(a){Galleria.addTheme({name:"uplo",author:"Galleria",css:"galleria.uplo.css",defaults:{transition:"slide",thumbCrop:"height",_toggleInfo:!0},init:function(b){this.addElement("info-link","info-close"),this.append({info:["info-link","info-close"]});var c=this.$("info-link,info-close,info-text"),d=Galleria.TOUCH,e=d?"touchstart":"click";this.$("loader,counter").show().css("opacity",.2),this.remove("info-description"),d||(this.addIdleState(this.get("image-nav-left"),{left:-50}),this.addIdleState(this.get("image-nav-right"),{right:-50}),this.addIdleState(this.get("counter"),{opacity:0})),b._toggleInfo===!0?c.bind(e,function(){c.toggle()}):(c.show(),this.$("info-link, info-close").hide()),this.bind("thumbnail",function(b){d?a(b.thumbTarget).css("opacity",this.getIndex()?1:.4):(a(b.thumbTarget).css("opacity",.4).parent().hover(function(){a(this).not(".active").children().stop().fadeTo(100,1)},function(){a(this).not(".active").children().stop().fadeTo(400,.4)}),b.index===this.getIndex()&&a(b.thumbTarget).css("opacity",1))}),this.bind("loadstart",function(b){b.cached||this.$("loader").show().fadeTo(200,.4),this.$("info").toggle(this.hasInfo());var c=a(b.thumbTarget).css("opacity",1).parent().addClass("current");a(c).siblings().removeClass("current").children().css("opacity",.4)}),this.bind("loadfinish",function(a){this.$("loader").fadeOut(200)})}})}(jQuery)