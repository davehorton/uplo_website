/**
 * @preserve Galleria Classic Theme 2011-08-01
 * http://galleria.aino.se
 *
 * Copyright (c) 2011, Aino
 * Licensed under the MIT license.
 */
/*global jQuery, Galleria */
Galleria.requires(1.25,"This version of Classic theme requires Galleria 1.2.5 or later"),function(a){Galleria.addTheme({name:"classic",author:"Galleria",css:"galleria.classic.css",defaults:{transition:"slide",thumbCrop:"height",_toggleInfo:!0},init:function(b){this.addElement("info-link","info-close"),this.append({info:["info-link","info-close"]});var c=this.$("info-link,info-close,info-text"),d=Galleria.TOUCH,e=d?"touchstart":"click";this.$("loader,counter").show().css("opacity",.4),d||(this.addIdleState(this.get("image-nav-left"),{left:-50}),this.addIdleState(this.get("image-nav-right"),{right:-50}),this.addIdleState(this.get("counter"),{opacity:0})),b._toggleInfo===!0?c.bind(e,function(){c.toggle()}):(c.show(),this.$("info-link, info-close").hide()),this.bind("thumbnail",function(b){d?a(b.thumbTarget).css("opacity",this.getIndex()?1:.6):(a(b.thumbTarget).css("opacity",.6).parent().hover(function(){a(this).not(".active").children().stop().fadeTo(100,1)},function(){a(this).not(".active").children().stop().fadeTo(400,.6)}),b.index===this.getIndex()&&a(b.thumbTarget).css("opacity",1))}),this.bind("loadstart",function(b){b.cached||this.$("loader").show().fadeTo(200,.4),this.$("info").toggle(this.hasInfo()),a(b.thumbTarget).css("opacity",1).parent().siblings().children().css("opacity",.6)}),this.bind("loadfinish",function(a){this.$("loader").fadeOut(200)})}})}(jQuery);