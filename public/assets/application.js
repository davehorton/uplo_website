Array.prototype.remove=function(e){var t=this.indexOf(e);t!=-1&&this.splice(t,1)},global={date_format:"mm/dd/yy",date_format_dev:"yy-mm-dd",status_show_error:777,ga_code:function(){return"UA-30729550-1"}},helper={timerID:null,stopLoadmore:!1,showErrorMessage:function(e,t,n,r){var i;return r==null&&(r=""),e?($(t).siblings(".error").remove(),!0):($(t).siblings(".error").length===0?(i="<span class='error "+r+"'>"+n+"</span>",$(t).after(i)):$(t).siblings(".error").text(""+n),!1)},pluralize_without_count:function(e,t,n){return parseInt(e)==1?t:n},check_less_than_characters:function(e,t,n){return e.length<t?(n==null?helper.show_notification("Must be at least "+t+" character(s)"):n.call(),!1):!0},prevent_exceed_characters:function(e,t,n,r){if(!t)return!0;var i=e.value.substring(0,e.selectionStart),s=e.value.substring(e.selectionEnd,e.value.length),o=i+String.fromCharCode(t)+s;if(o.length>n){if(r==null)return!1;r.call()}return!0},endless_load_more:function(e){return $(window).scroll(function(){var t,n;n=$(".pagination .next_page").attr("href"),t=$(document).height()-$(window).height()-20;if(n&&$(window).scrollTop()>=t)return $(".pagination").removeClass("hidden"),$(".pagination").text("Loading...."),$.ajax({url:n,type:"GET",dataType:"html",success:function(t){if(helper.stopLoadmore)return;var n;n=$.parseJSON(t),$("#endless-pages").append(n.items),$(".pagination").replaceWith(n.pagination),e.call()}});$("#simplemodal-container").find("#mask").length>0&&$.modal.close()})},create_message_panel:function(e,t){var n=$("<div></div>");return $(n).attr("class","box box-"+e),$(n).text(t),$(n)},flash_message:function(e,t,n,r,i){var s=helper.create_message_panel(e,t);i||(i="#flash"),n?$(i).append(s):$(i).html(s),typeof r!="undefined"&&!isNaN(r)&&$(s).delay(r).fadeOut(function(){$(s).remove()})},auto_hide_flash_message:function(){clearInterval(helper.timerID),helper.timerID=setInterval(function(){$(".flash").stop(!0,!0).fadeOut("fast")},5e3)},show_notification:function(e){$(".flash").stop(!0,!0).fadeIn("fast");var t="<div class='icon_notification left'></div><div class='left message wordwrap'>"+e+"</div>";$(".flash").find(".notification-container").removeClass("hidden"),$(".flash").find(".messages").html(t),helper.auto_hide_flash_message()},is_valid_ip4_address:function(e){var t=/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;if(t.test(e)){var n=e.split(".");if(parseInt(parseFloat(n[0]))==0)return!1;for(var r=0;r<n.length;r++)if(parseInt(parseFloat(n[r]))>255)return!1;return!0}return!1},is_valid_ip4_addresses:function(e,t){if(!t||$.trim(t)=="")t=",";var n=e.split(t);for(var r=0;r<n.length;r++){var i=$.trim(n[r]);if(!helper.is_valid_ip4_address(i))return!1}return!0},setup_async_image_tag:function(e,t){e||(e="img.user-avatar"),$(e).livequery(function(){$(this).jail({selector:t,callbackAfterEachImage:function(e,t){$(e).parent().removeClass("default"),$(e).error(function(){$(this).parent().addClass("default")})}})})},is_equal_elements:function(e,t){return e==t||$.inArray(e,t)>=0},parse_date:function(e,t){var n=null;try{n=$.datepicker.parseDate(e,t)}catch(r){}return n},hide_require_signs:function(){$(".simple_form label.required abbr").livequery(function(){$(this).hide()})},scroll_to:function(e,t){t||(t=300),$("html, body").animate({scrollTop:$(e).offset().top-10},t)},rand_num:function(){var e=Math.random().toString();return e=e.replace("0.",""),parseInt(e)},alert_not_implement:function(){return helper.show_notification("This feature is coming soon"),!1},show_overlay:function(){$(".overlay").css("width",$(document).width()+"px"),$(".overlay").css("height",$(document).height()+"px")},setup_login:function(){$("#btn-login").click(function(){var e=$("#user_login").val().trim().length>0,t=$("#user_password").val().trim().length>0;helper.showErrorMessage(e,"#user_login","Can't be blank","text message highlight right"),helper.showErrorMessage(t,"#user_password","Can't be blank","text message highlight right");if(!e||!t)return!1;$("#frm-login").submit()}),$("#btn-request-inv").click(function(){$("#frm-request").submit()}),$("#login-overlay").click(function(){$(this).fadeOut(),$("#session-container").fadeOut()}),$("#user-box a").click(function(){$("#login-overlay").fadeIn(),$("#session-container").fadeIn()})},setup_filtering_search:function(){$(".button.search").click(function(){$("#filtering-search-box").submit()}),$("#filtered_by").change(function(){$("#sort_by").val(""),$("#filtering-search-box").submit()}),$("#sort_by").change(function(){$("#filtering-search-box").submit()})}};