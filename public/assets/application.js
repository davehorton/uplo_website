Array.prototype.remove=function(a){var b=this.indexOf(a);b!=-1&&this.splice(b,1)},global={date_format:"mm/dd/yy",date_format_dev:"yy-mm-dd",status_show_error:777},helper={create_message_panel:function(a,b){var c=$("<div></div>");return $(c).attr("class","box box-"+a),$(c).text(b),$(c)},flash_message:function(a,b,c,d,e){var f=helper.create_message_panel(a,b);e||(e="#flash"),c?$(e).append(f):$(e).html(f),typeof d!="undefined"&&!isNaN(d)&&$(f).delay(d).fadeOut(function(){$(f).remove()})},auto_hide_flash_message:function(){var a=!1;$(document).bind("click mousemove keypress",function(b){a||($("#flash").delay(5e3).slideUp(),a=!0)})},is_valid_ip4_address:function(a){var b=/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;if(b.test(a)){var c=a.split(".");if(parseInt(parseFloat(c[0]))==0)return!1;for(var d=0;d<c.length;d++)if(parseInt(parseFloat(c[d]))>255)return!1;return!0}return!1},is_valid_ip4_addresses:function(a,b){if(!b||$.trim(b)=="")b=",";var c=a.split(b);for(var d=0;d<c.length;d++){var e=$.trim(c[d]);if(!helper.is_valid_ip4_address(e))return!1}return!0},setup_async_image_tag:function(a,b){a||(a="img.user-avatar"),$(a).livequery(function(){$(this).jail({selector:b,callbackAfterEachImage:function(a,b){$(a).parent().removeClass("default"),$(a).error(function(){$(this).parent().addClass("default")})}})})},is_equal_elements:function(a,b){return a==b||$.inArray(a,b)>=0},parse_date:function(a,b){var c=null;try{c=$.datepicker.parseDate(a,b)}catch(d){}return c},hide_require_signs:function(){$(".simple_form label.required abbr").livequery(function(){$(this).hide()})},scroll_to:function(a,b){b||(b=300),$("html, body").animate({scrollTop:$(a).offset().top-10},b)},rand_num:function(){var a=Math.random().toString();return a=a.replace("0.",""),parseInt(a)}}