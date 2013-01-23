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
jQuery.fn.inputHintOverlay=function(e,t,n){e=typeof e!="undefined"?e:0,t=typeof t!="undefined"?t:0,n=typeof n!="undefined"?n:!1;var r="jqiho";return this.each(function(){var i=jQuery(this),s=jQuery(this).find("textarea"),o=jQuery(this).find("input[type=password]");jQuery(this).find("input[type=text]").add(s).add(o).each(function(){var i=jQuery(this).attr("title"),s=jQuery(this).attr("value"),o=jQuery(this),u,a;if(i){u=i.replace(/[^a-zA-Z0-9]/g,""),jQuery(this).wrap("<div class='inputHintOverlay' style='position:relative' id='wrap"+u+r+"' />");var f=jQuery(this).parent(),l=jQuery(this).position();newZ=jQuery(this).css("z-index"),newZ=="auto"?newZ="2000":newZ+=20;var c={position:"absolute","z-index":newZ,left:l.left+t,top:l.top+e,cursor:"text"};a=jQuery(document.createElement("label")).appendTo(f).attr("for",jQuery(this).attr("id")).attr("id",u+r).addClass("inputHintOverlay").html(i).css(c).click(function(){jQuery(this).toggle(!1),o.trigger("focus")})}a&&(s&&a.toggle(!1),jQuery(this).focus(function(){a.toggle(!1)}),n?jQuery(this).change(function(){var e=jQuery(this);a.toggle(jQuery(this).attr("value")=="")}):jQuery(this).blur(function(){jQuery(this).attr("value")==""&&a.toggle(!0)}))})})};