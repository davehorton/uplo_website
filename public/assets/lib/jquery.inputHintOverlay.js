/*
 * jQuery Input Hint Overlay plugin v1.1.14, 2010-12-14
 * Only tested with jQuery 1.4.1 (early versions - YMMV)
 * 
 *   http://jdeerhake.com/inputHintOverlay.php
 *   http://plugins.jquery.com/project/inputHintOverlay
 *   http://github.com/jdeerhake/inputHintOverlay
 *
 *
 * Copyright (c) 2010 John Deerhake
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 */
jQuery.fn.inputHintOverlay=function(a,b,c){a=typeof a!="undefined"?a:0,b=typeof b!="undefined"?b:0,c=typeof c!="undefined"?c:!1;var d="jqiho";return this.each(function(){var e=jQuery(this),f=jQuery(this).find("textarea"),g=jQuery(this).find("input[type=password]");jQuery(this).find("input[type=text]").add(f).add(g).each(function(){var e=jQuery(this).attr("title"),f=jQuery(this).attr("value"),g=jQuery(this),h,i;if(e){h=e.replace(/[^a-zA-Z0-9]/g,""),jQuery(this).wrap("<div class='inputHintOverlay' style='position:relative' id='wrap"+h+d+"' />");var j=jQuery(this).parent(),k=jQuery(this).position();newZ=jQuery(this).css("z-index"),newZ=="auto"?newZ="2000":newZ+=20;var l={position:"absolute","z-index":newZ,left:k.left+b,top:k.top+a,cursor:"text"};i=jQuery(document.createElement("label")).appendTo(j).attr("for",jQuery(this).attr("id")).attr("id",h+d).addClass("inputHintOverlay").html(e).css(l).click(function(){jQuery(this).toggle(!1),g.trigger("focus")})}i&&(f&&i.toggle(!1),jQuery(this).focus(function(){i.toggle(!1)}),c?jQuery(this).change(function(){var a=jQuery(this);i.toggle(jQuery(this).attr("value")=="")}):jQuery(this).blur(function(){jQuery(this).attr("value")==""&&i.toggle(!0)}))})})};