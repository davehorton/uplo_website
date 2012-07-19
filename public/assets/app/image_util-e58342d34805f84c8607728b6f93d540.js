/**
 * @author Alexandre Magno
 * @desc Center a element with jQuery
 * @version 1.0
 * @example
 * $("element").center({
 *
 * 		vertical: true,
 *      horizontal: true
 *
 * });
 * @obs With no arguments, the default is above
 * @license free
 * @param bool vertical, bool horizontal
 * @contribution Paulo Radichi
 *
 */
jQuery.fn.center=function(a){var b={vertical:!0,horizontal:!0};return op=jQuery.extend(b,a),this.each(function(){var a=jQuery(this),b=a.width(),c=a.height(),d=parseInt(a.css("padding-top")),e=parseInt(a.css("padding-bottom")),f=parseInt(a.css("border-top-width")),g=parseInt(a.css("border-bottom-width")),h=(f+g)/2,i=(d+e)/2,j=a.parent().css("position"),k=b/2*-1,l=c/2*-1-i-h,m={position:"absolute"};op.vertical&&(m.height=c,m.top="50%",m.marginTop=l),op.horizontal&&(m.width=b,m.left="50%",m.marginLeft=k),j=="static"&&a.parent().css("position","relative"),a.css(m)})},image_util={inch_to_px:function(a,b){return b||(b=72),a*b},detect_dpi:function(){var a=$('<div style="display: block; height: 1in; left: -100%;                     position: absolute; top: -100%;  width: 1in; padding:0; margin:0;"></div>');$("body").append(a);var b=$(a).width();return $(a).remove(),b},resize_image:function(a,b){b.ratio||(b.ratio=1.5);var c=b.width,d=b.height,e=c/b.ratio;if(e<d)c=d*b.ratio;else{var f=d*b.ratio;f<c&&(d=e)}$(a).width(c).height(d),$(a).css("max-width",c),$(a).css("max-height",d),$(a).center()},resize_frame:function(a,b){var c=$(a).parents(".image-container");b||(b={});if(b.auto)$(c).width("auto"),$(c).height("auto");else{var d=$(a).width();b.width>0&&d>b.width&&(d=b.width);var e=$(a).height();b.height>0&&e>b.height&&(e=b.height);var f=1;d||(d=parseFloat($(a).attr("data-width"),10));var g=parseFloat($(c).css("max-width"),10);d>0&&d<=g?$(c).width(d):d>0&&d>g&&(f=g/d,$(c).width(g)),e>0&&$(c).height(f*e),$(a).center()}}};