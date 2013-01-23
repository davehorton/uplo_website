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
jQuery.fn.center=function(e){var t={vertical:!0,horizontal:!0};return op=jQuery.extend(t,e),this.each(function(){var e=jQuery(this),t=e.width(),n=e.height(),r=parseInt(e.css("padding-top")),i=parseInt(e.css("padding-bottom")),s=parseInt(e.css("border-top-width")),o=parseInt(e.css("border-bottom-width")),u=(s+o)/2,a=(r+i)/2,f=e.parent().css("position"),l=t/2*-1,c=n/2*-1-a-u,h={position:"absolute"};op.vertical&&(h.height=n,h.top="50%",h.marginTop=c),op.horizontal&&(h.width=t,h.left="50%",h.marginLeft=l),f=="static"&&e.parent().css("position","relative"),e.css(h)})};