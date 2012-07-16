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
jQuery.fn.center=function(a){var b={vertical:!0,horizontal:!0};return op=jQuery.extend(b,a),this.each(function(){var a=jQuery(this),b=a.width(),c=a.height(),d=parseInt(a.css("padding-top")),e=parseInt(a.css("padding-bottom")),f=parseInt(a.css("border-top-width")),g=parseInt(a.css("border-bottom-width")),h=(f+g)/2,i=(d+e)/2,j=a.parent().css("position"),k=b/2*-1,l=c/2*-1-i-h,m={position:"absolute"};op.vertical&&(m.height=c,m.top="50%",m.marginTop=l),op.horizontal&&(m.width=b,m.left="50%",m.marginLeft=k),j=="static"&&a.parent().css("position","relative"),a.css(m)})};