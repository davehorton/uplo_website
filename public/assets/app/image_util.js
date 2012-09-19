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
jQuery.fn.center=function(a){var b={vertical:!0,horizontal:!0};return op=jQuery.extend(b,a),this.each(function(){var a=jQuery(this),b=a.width(),c=a.height(),d=parseInt(a.css("padding-top")),e=parseInt(a.css("padding-bottom")),f=parseInt(a.css("border-top-width")),g=parseInt(a.css("border-bottom-width")),h=(f+g)/2,i=(d+e)/2,j=a.parent().css("position"),k=b/2*-1,l=c/2*-1-i-h,m={position:"absolute"};op.vertical&&(m.height=c,m.top="50%",m.marginTop=l),op.horizontal&&(m.width=b,m.left="50%",m.marginLeft=k),j=="static"&&a.parent().css("position","relative"),a.css(m)})},image_util={inch_to_px:function(a,b){return b||(b=72),a*b},detect_dpi:function(){var a=$('<div style="display: block; height: 1in; left: -100%;                     position: absolute; top: -100%;  width: 1in; padding:0; margin:0;"></div>');$("body").append(a);var b=$(a).width();return $(a).remove(),b},detect_image_size:function(a){var b=$('<img style="display: block; margin: 0; padding: 0; width: auto; height: auto;                       position: absolute; top: -100%; left: -100%;"                       src="'+$(a).attr("src")+'"/>');$("body").append(b);var c={width:$(b).width(),height:$(b).height()};return $(b).remove(),c},resize_image:function(a,b){b.ratio||(b.ratio=1.5);var c=b.width,d=b.height,e=c/b.ratio;if(e<d)c=d*b.ratio;else{var f=d*b.ratio;f<c&&(d=e)}return $(a).width(c).height(d),$(a).css("max-width",c),$(a).css("max-height",d),$(a).center(),{width:c,height:d}},resize_frame:function(a,b){var c=$(a).parents(".image-container");b||(b={});if(b.auto)$(c).width("auto"),$(c).height("auto");else{var d=$(a).width();b.width>0&&d>b.width&&(d=b.width);var e=$(a).height();b.height>0&&e>b.height&&(e=b.height);var f=1;d||(d=parseFloat($(a).attr("data-width")));var g=parseFloat($(c).css("max-width"));d>0&&d<=g?$(c).width(d):d>0&&d>g&&(f=g/d,$(c).width(g)),e>0&&$(c).height(f*e),$(a).center()}},ratio_from_size:function(a){var b=a.toLowerCase().split("x",2),c=0;return b.length==2&&(b[0]=parseFloat(b[0]),b[1]=parseFloat(b[1]),b[1]>0&&(c=b[0]/b[1])),c}},order_preview={max_width:638,padding:5,frame_alias:{1:"print_only",2:"canvas",3:"plexi",4:"black",5:"white",6:"light_wood",7:"rustic_wood"},frames:{canvas:{scalable:!1,url:"/assets/img-frames/canvas.png"},plexi:{scalable:!1,url:"/assets/img-frames/plexi.png"},black:{scalable:!0,url_top:"/assets/img-frames/black-top.png",url_right:"/assets/img-frames/black-right.png",url_bottom:"/assets/img-frames/black-bottom.png",url_left:"/assets/img-frames/black-left.png",margin_top:83,margin_left:83,corner_width:250},white:{scalable:!0,url_top:"/assets/img-frames/white-top.png",url_right:"/assets/img-frames/white-right.png",url_bottom:"/assets/img-frames/white-bottom.png",url_left:"/assets/img-frames/white-left.png",margin_top:81,margin_left:81},light_wood:{scalable:!0,url_top:"/assets/img-frames/lightwood-top.png",url_right:"/assets/img-frames/lightwood-right.png",url_bottom:"/assets/img-frames/lightwood-bottom.png",url_left:"/assets/img-frames/lightwood-left.png",margin_top:107,margin_left:101,corner_width:118},rustic_wood:{scalable:!0,url_top:"/assets/img-frames/rustic-top.png",url_right:"/assets/img-frames/rustic-right.png",url_bottom:"/assets/img-frames/rustic-bottom.png",url_left:"/assets/img-frames/rustic-left.png",margin_top:122,margin_left:123,corner_width:350}},preload_images:function(){},adjust_image_frame_sizes_with_num:function(a){var b=order_preview.frame_alias[a];order_preview.adjust_image_frame_sizes(b)},adjust_image_frame_sizes:function(a){var b=order_preview.frames[a],c=$("#preview-frame .image-frame"),d=$("#preview-frame > img.image");a=="canvas"||a=="plexi"?($(d).css("display","none"),c.css({position:"relative"})):($(d).css({display:"inline-block",position:"static"}),c.css({left:0,position:"absolute",top:0}));if(!b)return $(c).find("img").remove(),$(d).width("683px"),$(d).height("auto"),order_preview.toggle_waiting(!1),!1;if(!b.scalable){var e=$('<img src="'+b.url+'"/>');c.html(e),$(e).load(function(){var a=$(this).height();$(e).parent().height(a),$("#preview-frame").height(a),order_preview.toggle_waiting(!1)}),$(e).prop("complete")&&$(e).load()}c.css("z-index",10),d.css("z-index",9);if(b.scalable){var f=parseFloat($(d).attr("data-original-width")),g=parseFloat($(d).attr("data-original-height"));if(!f||!g){var h=image_util.detect_image_size($(d));f=h.width,$(d).attr("data-original-width",f),g=h.height,$(d).attr("data-original-height",g)}if(f<=0||g<=0)return!1;var i=image_util.ratio_from_size($("#line_item_size").val());i<=0&&(i=1),f<g&&(i=1/i),f>order_preview.max_width&&(f=order_preview.max_width,g=f*i);var j=f+b.margin_left*2,k=g+b.margin_top*2;if(j>=order_preview.max_width){j=order_preview.max_width;var l=j-b.margin_left*2,m=0;i>0&&i!=1?m=l*i:m=g*(l/f),k=m+b.margin_top*2,f=l,g=m}$(c).width(j),$(c).height(k),$(d).width(f),$(d).height(g),order_preview.init_frame_elements(c,b,j,k),$(d).css({position:"absolute",top:b.margin_top,left:b.margin_left}),$("#preview-frame").width(j),$("#preview-frame").height(k)}},init_frame_elements:function(a,b,c,d){var e=b.url_top,f=b.url_right,g=b.url_bottom,h=b.url_left,i=[];$(a).html("");var j=$('<img id="frame-top" src="'+e+'"/>');a.html(j),j.css({position:"absolute",left:0,top:0}),j.width(c),j.height(b.margin_top),i.push(j),j=$('<img id="frame-right" src="'+f+'"/>'),a.append(j),j.css({position:"absolute",right:0,top:b.margin_top}),j.width(b.margin_left),j.height(d-b.margin_top*2+order_preview.padding),i.push(j),j=$('<img id="frame-bottom" src="'+g+'"/>'),a.append(j),j.css({position:"absolute",left:0,top:d-b.margin_top}),j.width(c),j.height(b.margin_top),i.push(j),j=$('<img id="frame-left" src="'+h+'"/>'),a.append(j),j.css({position:"absolute",left:0,top:b.margin_top}),j.width(b.margin_left),j.height(d-b.margin_top*2+order_preview.padding),i.push(j);var k=b.corner_width;if(!k||k<=0)k=b.margin_left;var l=$('<img id="frame-top-left" src="'+e+'"/>');l.css({position:"absolute",top:0,left:0}),$(l).height(b.margin_top),i.push(l),j=$("<div></div>").append(l),a.append(j),j.css({position:"absolute",overflow:"hidden",left:0,top:0,width:k,height:b.margin_top,"z-index":11}),l=$('<img id="frame-top-right" src="'+e+'"/>'),l.css({position:"absolute",right:0,top:0}),$(l).height(b.margin_top),i.push(l),j=$("<div></div>").append(l),a.append(j),j.css({position:"absolute",overflow:"hidden",right:0,top:0,width:k,height:b.margin_top,"z-index":11}),l=$('<img id="frame-bottom-left" src="'+g+'"/>'),l.css({position:"absolute",left:0,top:0}),$(l).height(b.margin_top),i.push(l),j=$("<div></div>").append(l),a.append(j),j.css({position:"absolute",overflow:"hidden",left:0,bottom:0,width:k,height:b.margin_top,"z-index":11}),l=$('<img id="frame-bottom-right" src="'+g+'"/>'),l.css({position:"absolute",right:0,top:0}),$(l).height(b.margin_top),i.push(l),j=$("<div></div>").append(l),a.append(j),j.css({position:"absolute",overflow:"hidden",right:0,bottom:0,width:k,height:b.margin_top,"z-index":11}),order_preview.on_images_finish_loading(i,function(){order_preview.toggle_waiting(!1)})},toggle_waiting:function(a){var b=$("#preview-frame > #preview-waiting");if(a){var c=$("#preview-frame").width(),d=$("#preview-frame").height(),e=d/2-$(b).height()/2,f=c/2-$(b).width()/2;$(b).css({display:"block",top:e,left:f,position:"absolute"})}else $(b).hide()},on_images_finish_loading:function(a,b){var c=a.length,d=function(){c-=1,c==0&&b()};for(var e=0;e<a.length;++e){var f=a[e];$(f).load(function(){d()}),$(f).error(function(){d()}),$(f).prop("complete")&&d()}},setup:function(){$("#line_item_moulding").change(function(){order_preview.toggle_waiting(!0),order_preview.adjust_image_frame_sizes_with_num($(this).val())}),$("#line_item_size").change(function(){var a=$(this).find("option[value="+$(this).val()+"]").attr("data-url");if(a){order_preview.toggle_waiting(!0);var b=$("#preview-frame > img.image");$(b).attr("src",a)}});var a=$("#preview-frame > img.image");$(a).load(function(){var b=image_util.detect_image_size($(this));$(a).attr("data-original-width",b.width),$(a).attr("data-original-height",b.height),order_preview.adjust_image_frame_sizes_with_num($("#line_item_moulding").val()),order_preview.toggle_waiting(!1)}),$(a).prop("complete")&&$(a).load(),$("#line_item_size").change()}};