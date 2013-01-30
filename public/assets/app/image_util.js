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
jQuery.fn.center=function(e){var t={vertical:!0,horizontal:!0};return op=jQuery.extend(t,e),this.each(function(){var e=jQuery(this),t=e.width(),n=e.height(),r=parseInt(e.css("padding-top")),i=parseInt(e.css("padding-bottom")),s=parseInt(e.css("border-top-width")),o=parseInt(e.css("border-bottom-width")),u=(s+o)/2,a=(r+i)/2,f=e.parent().css("position"),l=t/2*-1,c=n/2*-1-a-u,h={position:"absolute"};op.vertical&&(h.height=n,h.top="50%",h.marginTop=c),op.horizontal&&(h.width=t,h.left="50%",h.marginLeft=l),f=="static"&&e.parent().css("position","relative"),e.css(h)})},image_util={inch_to_px:function(e,t){return t||(t=150),e*t},detect_dpi:function(){var e=$('<div style="display: block; height: 1in; left: -100%;                     position: absolute; top: -100%;  width: 1in; padding:0; margin:0;"></div>');$("body").append(e);var t=$(e).width();return $(e).remove(),t},detect_image_size:function(e){var t=$('<img style="display: block; margin: 0; padding: 0; width: auto; height: auto;                       position: absolute; top: -100%; left: -100%;"                       src="'+$(e).attr("src")+'"/>');$("body").append(t);var n={width:$(t).width(),height:$(t).height()};return $(t).remove(),n},resize_image:function(e,t){t.ratio||(t.ratio=1.5);var n=t.width,r=t.height,i=n/t.ratio;if(i<r)n=r*t.ratio;else{var s=r*t.ratio;s<n&&(r=i)}return $(e).width(n).height(r),$(e).css("max-width",n),$(e).css("max-height",r),$(e).center(),{width:n,height:r}},resize_frame:function(e,t){var n=$(e).parents(".image-container");t||(t={});if(t.auto)$(n).width("auto"),$(n).height("auto");else{var r=$(e).width();t.width>0&&r>t.width&&(r=t.width);var i=$(e).height();t.height>0&&i>t.height&&(i=t.height);var s=1;r||(r=parseFloat($(e).attr("data-width")));var o=parseFloat($(n).css("max-width"));r>0&&r<=o?$(n).width(r):r>0&&r>o&&(s=o/r,$(n).width(o)),i>0&&$(n).height(s*i),$(e).center()}},ratio_from_size:function(e){var t=e.toLowerCase().split("x",2),n=0;return t.length==2&&(t[0]=parseFloat(t[0]),t[1]=parseFloat(t[1]),t[1]>0&&(n=t[0]/t[1])),n}},order_preview={max_width:638,padding:5,frame_alias:{1:"print_only_gloss",2:"canvas",3:"plexi",4:"black",5:"white",6:"light_wood",7:"rustic_wood",8:"print_only_luster"},frames:{canvas:{scalable:!1,url:"/assets/img-frames/canvas.png"},plexi:{scalable:!1,url:"/assets/img-frames/plexi.png"},black:{scalable:!0,url_top:"/assets/img-frames/black-top.png",url_right:"/assets/img-frames/black-right.png",url_bottom:"/assets/img-frames/black-bottom.png",url_left:"/assets/img-frames/black-left.png",margin_top:83,margin_left:83,corner_width:250},white:{scalable:!0,url_top:"/assets/img-frames/white-top.png",url_right:"/assets/img-frames/white-right.png",url_bottom:"/assets/img-frames/white-bottom.png",url_left:"/assets/img-frames/white-left.png",margin_top:81,margin_left:81},light_wood:{scalable:!0,url_top:"/assets/img-frames/lightwood-top.png",url_right:"/assets/img-frames/lightwood-right.png",url_bottom:"/assets/img-frames/lightwood-bottom.png",url_left:"/assets/img-frames/lightwood-left.png",margin_top:107,margin_left:101,corner_width:118},rustic_wood:{scalable:!0,url_top:"/assets/img-frames/rustic-top.png",url_right:"/assets/img-frames/rustic-right.png",url_bottom:"/assets/img-frames/rustic-bottom.png",url_left:"/assets/img-frames/rustic-left.png",margin_top:122,margin_left:123,corner_width:350}},preload_images:function(){},adjust_image_frame_sizes_with_num:function(e){var t=order_preview.frame_alias[e];order_preview.adjust_image_frame_sizes(t)},adjust_image_frame_sizes:function(e){var t=order_preview.frames[e],n=$("#preview-frame .image-frame"),r=$("#preview-frame > img.image");e=="canvas"||e=="plexi"?($(r).css("display","none"),n.css({position:"relative"})):($(r).css({display:"inline-block",position:"static"}),n.css({left:0,position:"absolute",top:0}));if(!t)return $(n).find("img").remove(),$(r).width("638px"),$(r).height("auto"),$("#preview-frame").height("auto"),order_preview.toggle_waiting(!1),!1;if(!t.scalable){var i=$('<img src="'+t.url+'"/>');n.html(i),$(i).load(function(){var e=$(this).height();$(i).parent().height(e),$("#preview-frame").height(e),order_preview.toggle_waiting(!1)}),$(i).prop("complete")&&$(i).load()}n.css("z-index",10),r.css("z-index",9);if(t.scalable){var s=parseFloat($(r).attr("data-original-width")),o=parseFloat($(r).attr("data-original-height"));if(!s||!o){var u=image_util.detect_image_size($(r));s=u.width,$(r).attr("data-original-width",s),o=u.height,$(r).attr("data-original-height",o)}if(s<=0||o<=0)return!1;var a=image_util.ratio_from_size($("#line_item_size").val());a<=0&&(a=1),s<o&&(a=1/a),s>order_preview.max_width&&(s=order_preview.max_width,o=s*a);var f=s+t.margin_left*2,l=o+t.margin_top*2;if(f>=order_preview.max_width){f=order_preview.max_width;var c=f-t.margin_left*2,h=0;a>0&&a!=1?h=c*a:h=o*(c/s),l=h+t.margin_top*2,s=c,o=h}$(n).width(f),$(n).height(l),$(r).width(s),$(r).height(o),order_preview.init_frame_elements(n,t,f,l),$(r).css({position:"absolute",top:t.margin_top,left:t.margin_left}),$("#preview-frame").width(f),$("#preview-frame").height(l)}},init_frame_elements:function(e,t,n,r){var i=t.url_top,s=t.url_right,o=t.url_bottom,u=t.url_left,a=[];$(e).html("");var f=$('<img id="frame-top" src="'+i+'"/>');e.html(f),f.css({position:"absolute",left:0,top:0}),f.width(n),f.height(t.margin_top),a.push(f),f=$('<img id="frame-right" src="'+s+'"/>'),e.append(f),f.css({position:"absolute",right:0,top:t.margin_top}),f.width(t.margin_left),f.height(r-t.margin_top*2+order_preview.padding),a.push(f),f=$('<img id="frame-bottom" src="'+o+'"/>'),e.append(f),f.css({position:"absolute",left:0,top:r-t.margin_top}),f.width(n),f.height(t.margin_top),a.push(f),f=$('<img id="frame-left" src="'+u+'"/>'),e.append(f),f.css({position:"absolute",left:0,top:t.margin_top}),f.width(t.margin_left),f.height(r-t.margin_top*2+order_preview.padding),a.push(f);var l=t.corner_width;if(!l||l<=0)l=t.margin_left;var c=$('<img id="frame-top-left" src="'+i+'"/>');c.css({position:"absolute",top:0,left:0}),$(c).height(t.margin_top),a.push(c),f=$("<div></div>").append(c),e.append(f),f.css({position:"absolute",overflow:"hidden",left:0,top:0,width:l,height:t.margin_top,"z-index":11}),c=$('<img id="frame-top-right" src="'+i+'"/>'),c.css({position:"absolute",right:0,top:0}),$(c).height(t.margin_top),a.push(c),f=$("<div></div>").append(c),e.append(f),f.css({position:"absolute",overflow:"hidden",right:0,top:0,width:l,height:t.margin_top,"z-index":11}),c=$('<img id="frame-bottom-left" src="'+o+'"/>'),c.css({position:"absolute",left:0,top:0}),$(c).height(t.margin_top),a.push(c),f=$("<div></div>").append(c),e.append(f),f.css({position:"absolute",overflow:"hidden",left:0,bottom:0,width:l,height:t.margin_top,"z-index":11}),c=$('<img id="frame-bottom-right" src="'+o+'"/>'),c.css({position:"absolute",right:0,top:0}),$(c).height(t.margin_top),a.push(c),f=$("<div></div>").append(c),e.append(f),f.css({position:"absolute",overflow:"hidden",right:0,bottom:0,width:l,height:t.margin_top,"z-index":11}),order_preview.on_images_finish_loading(a,function(){order_preview.toggle_waiting(!1)})},toggle_waiting:function(e){var t=$("#preview-frame > #preview-waiting");if(e){var n=$("#preview-frame").width(),r=$("#preview-frame").height(),i=r/2-$(t).height()/2,s=n/2-$(t).width()/2;$(t).css({display:"block",top:i,left:s,position:"absolute"})}else $(t).hide()},on_images_finish_loading:function(e,t){var n=e.length,r=function(){n-=1,n==0&&t()};for(var i=0;i<e.length;++i){var s=e[i];$(s).load(function(){r()}),$(s).error(function(){r()}),$(s).prop("complete")&&r()}},setup:function(){$("#line_item_moulding").change(function(){order_preview.toggle_waiting(!0),order_preview.adjust_image_frame_sizes_with_num($(this).val())}),$("#line_item_size").change(function(){var e=$(this).find("option[value="+$(this).val()+"]").attr("data-url");if(e){order_preview.toggle_waiting(!0);var t=$("#preview-frame > img.image");$(t).attr("src",e)}});var e=$("#preview-frame > img.image");$(e).load(function(){var t=image_util.detect_image_size($(this));$(e).attr("data-original-width",t.width),$(e).attr("data-original-height",t.height),order_preview.adjust_image_frame_sizes_with_num($("#line_item_moulding").val()),order_preview.toggle_waiting(!1)}),$(e).prop("complete")&&$(e).load(),$("#line_item_size").change()}};