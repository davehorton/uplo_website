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
jQuery.fn.center=function(a){var b={vertical:!0,horizontal:!0};return op=jQuery.extend(b,a),this.each(function(){var a=jQuery(this),b=a.width(),c=a.height(),d=parseInt(a.css("padding-top")),e=parseInt(a.css("padding-bottom")),f=parseInt(a.css("border-top-width")),g=parseInt(a.css("border-bottom-width")),h=(f+g)/2,i=(d+e)/2,j=a.parent().css("position"),k=b/2*-1,l=c/2*-1-i-h,m={position:"absolute"};op.vertical&&(m.height=c,m.top="50%",m.marginTop=l),op.horizontal&&(m.width=b,m.left="50%",m.marginLeft=k),j=="static"&&a.parent().css("position","relative"),a.css(m)})},image_util={inch_to_px:function(a,b){return b||(b=72),a*b},detect_dpi:function(){var a=$('<div style="display: block; height: 1in; left: -100%;                     position: absolute; top: -100%;  width: 1in; padding:0; margin:0;"></div>');$("body").append(a);var b=$(a).width();return $(a).remove(),b},resize_image:function(a,b){b.ratio||(b.ratio=1.5);var c=b.width,d=b.height,e=c/b.ratio;if(e<d)c=d*b.ratio;else{var f=d*b.ratio;f<c&&(d=e)}$(a).width(c).height(d),$(a).css("max-width",c),$(a).css("max-height",d),$(a).center()},resize_frame:function(a,b){var c=$(a).parents(".image-container");b||(b={});if(b.auto)$(c).width("auto"),$(c).height("auto");else{var d=$(a).width();b.width>0&&d>b.width&&(d=b.width);var e=$(a).height();b.height>0&&e>b.height&&(e=b.height);var f=1;d||(d=parseFloat($(a).attr("data-width"),10));var g=parseFloat($(c).css("max-width"),10);d>0&&d<=g?$(c).width(d):d>0&&d>g&&(f=g/d,$(c).width(g)),e>0&&$(c).height(f*e),$(a).center()}}},order_preview={max_width:638,frame_alias:{1:"print_only",2:"canvas",3:"plexi",4:"black",5:"white",6:"light_wood",7:"rustic_wood"},frames:{canvas:{scalable:!1,url:"/assets/img-frames/canvas.png"},plexi:{scalable:!1,url:"/assets/img-frames/plexi.png"},black:{scalable:!0,url_top:"/assets/img-frames/black-top.png",url_right:"/assets/img-frames/black-right.png",url_bottom:"/assets/img-frames/black-bottom.png",url_left:"/assets/img-frames/black-left.png",margin_top:83,margin_left:83},white:{scalable:!0,url_top:"/assets/img-frames/white-top.png",url_right:"/assets/img-frames/white-right.png",url_bottom:"/assets/img-frames/white-bottom.png",url_left:"/assets/img-frames/white-left.png",margin_top:81,margin_left:81},light_wood:{scalable:!0,url_top:"/assets/img-frames/lightwood-top.png",url_right:"/assets/img-frames/lightwood-right.png",url_bottom:"/assets/img-frames/lightwood-bottom.png",url_left:"/assets/img-frames/lightwood-left.png",margin_top:107,margin_left:101,corner_width:118},rustic_wood:{scalable:!0,url_top:"/assets/img-frames/rustic-top.png",url_right:"/assets/img-frames/rustic-right.png",url_bottom:"/assets/img-frames/rustic-bottom.png",url_left:"/assets/img-frames/rustic-left.png",margin_top:122,margin_left:123,corner_width:350}},preload_images:function(){},adjust_image_frame_sizes_with_num:function(a){var b=order_preview.frame_alias[a];order_preview.adjust_image_frame_sizes(b)},adjust_image_frame_sizes:function(a){var b=order_preview.frames[a],c=$("#preview-frame .image-frame"),d=$("#preview-frame > img.image");a=="canvas"||a=="plexi"?($(d).css("display","none"),c.css({position:"relative"})):($(d).css({display:"inline-block",position:"static"}),c.css({left:0,position:"absolute",top:0}));if(!b)return $(c).find("img").remove(),$(d).width("auto"),$(d).height("auto"),!1;if(!b.scalable){var e=$('<img src="'+b.url+'"/>');c.html(e),$(e).load(function(){var a=$(this).height();$(e).parent().height(a),$("#preview-frame").height(a)}),$(e).prop("complete")&&$(e).load()}c.css("z-index",10),d.css("z-index",9);if(b.scalable){var f=parseFloat($(d).attr("data-original-width"),10),g=parseFloat($(d).attr("data-original-height"),10);if(!f||!g)f=$(d).width(),$(d).attr("data-original-width",f),g=$(d).height(),$(d).attr("data-original-height",g);if(f<=0||g<=0)return!1;f>order_preview.max_width&&(f=order_preview.max_width);var h=f+b.margin_left*2,i=g+b.margin_top*2;if(h>=order_preview.max_width){h=order_preview.max_width;var j=h-b.margin_left*2,k=g*(j/f);i=k+b.margin_top*2,f=j,g=k}$(c).width(h),$(c).height(i),$(d).width(f),$(d).height(g),order_preview.init_frame_elements(c,b,h,i),$(d).css({position:"absolute",top:b.margin_top,left:b.margin_left}),$("#preview-frame").width(h),$("#preview-frame").height(i)}},init_frame_elements:function(a,b,c,d){var e=b.url_top,f=b.url_right,g=b.url_bottom,h=b.url_left;$(a).html("");var i=$('<img id="frame-top" src="'+e+'"/>');a.html(i),i.css({position:"absolute",left:0,top:0}),i.width(c),i.height(b.margin_top),i=$('<img id="frame-right" src="'+f+'"/>'),a.append(i),i.css({position:"absolute",right:0,top:b.margin_top}),i.width(b.margin_left),i.height(d-b.margin_top*2),i=$('<img id="frame-bottom" src="'+g+'"/>'),a.append(i),i.css({position:"absolute",left:0,top:d-b.margin_top}),i.width(c),i.height(b.margin_top),i=$('<img id="frame-left" src="'+h+'"/>'),a.append(i),i.css({position:"absolute",left:0,top:b.margin_top}),i.width(b.margin_left),i.height(d-b.margin_top*2);var j=b.corner_width;if(!j||j<=0)j=b.margin_left;var k=$('<img id="frame-top-left" src="'+e+'"/>');k.css({position:"absolute",top:0,left:0}),$(k).height(b.margin_top),i=$("<div></div>").append(k),a.append(i),i.css({position:"absolute",overflow:"hidden",left:0,top:0,width:j,height:b.margin_top,"z-index":11});var k=$('<img id="frame-top-right" src="'+e+'"/>');k.css({position:"absolute",right:0,top:0}),$(k).height(b.margin_top),i=$("<div></div>").append(k),a.append(i),i.css({position:"absolute",overflow:"hidden",right:0,top:0,width:j,height:b.margin_top,"z-index":11});var k=$('<img id="frame-bottom-left" src="'+g+'"/>');k.css({position:"absolute",left:0,top:0}),$(k).height(b.margin_top),i=$("<div></div>").append(k),a.append(i),i.css({position:"absolute",overflow:"hidden",left:0,bottom:0,width:j,height:b.margin_top,"z-index":11});var k=$('<img id="frame-bottom-right" src="'+g+'"/>');k.css({position:"absolute",right:0,top:0}),$(k).height(b.margin_top),i=$("<div></div>").append(k),a.append(i),i.css({position:"absolute",overflow:"hidden",right:0,bottom:0,width:j,height:b.margin_top,"z-index":11})},setup:function(){$("#line_item_moulding").change(function(){order_preview.adjust_image_frame_sizes_with_num($(this).val())}),$("#line_item_size").change(function(){var a=$(this).find("option[value="+$(this).val()+"]").attr("data-url");if(a){var b=$("#preview-frame > img.image");$(b).attr("src",a)}});var a=$("#preview-frame > img.image");$(a).load(function(){$(a).attr("data-original-width",$(a).width()),$(a).attr("data-original-height",$(a).height()),order_preview.adjust_image_frame_sizes_with_num($("#line_item_moulding").val())}),$(a).prop("complete")&&$(a).load(),$("#line_item_size").change()}},function(){var a;a=function(){var a,b,c,d,e;return e=$("#line_item_size").val(),b=$("#line_item_moulding").val(),d=$("#line_item_quantity").val(),c=pricing[e]*d,a=c*moulding_discount[b],$("#discount .number").text("- $"+a.toFixed(2)),$("#total .number").text("$"+(c-a).toFixed(2))},$(function(){return a(),$("#line_item_size").selectmenu({style:"dropdown",change:function(b,c){return a()}}),$("#line_item_moulding").selectmenu({style:"dropdown",change:function(b,c){return a()}}),$(".add-to-cart").click(function(){return $("#order-details").submit()}),$("#line_item_quantity").keypress(function(a){var b,c;b=/^\d{1,5}$/;if(a.charCode!==0){c=a.currentTarget.value+String.fromCharCode(a.charCode);if(!b.test(c))return!1}}),$("#line_item_quantity").keyup(function(){return a()}),order_preview.setup()})}.call(this);