(function(){var e,t,n,r,i;helper.endless_load_more(function(){if($(document).height()-20<=$(window).height())return $(window).scroll();if($("#simplemodal-container").find("#mask").length>0)return $.modal.close()}),e=function(e,t){return helper.stopLoadmore=!0,$("#mask").modal(),$.ajax({url:e,type:"GET",dataType:"json",success:function(e){var n,r,i;return r=t.replace("-counter",""),r==="galleries"?i="gallery":i=r.replace(/[s]$/,""),n=helper.pluralize_without_count(e.counter,i,r),$("#container").html(e.html),$("#"+t).find(".info .number").text(e.counter),$("#"+t).find(".info .label").text(n),helper.stopLoadmore=!1,$(window).scroll()}})},n=function(t){var n;return n=$(t),$("#mask").modal(),$.ajax({url:"/unlike_image",type:"GET",data:{image_id:n.attr("data-id")},dataType:"json",success:function(t){var n,r;return t.success===!1?(helper.show_notification(t.msg),$.modal.close()):(n=$(".counter.current"),r=n.find(".info").attr("data-url"),e(r,n.attr("id")))}})},r=function(t){var n,r,i;return i=$(t),n=i.attr("data-author-id"),r=i.attr("data-following"),$("#mask").modal(),$.ajax({url:"/users/follow",type:"GET",data:{user_id:n,unfollow:r},dataType:"json",success:function(t){var n,s;if(t.success===!1)return helper.show_notification(t.msg),$.modal.close();if(r==="false"){i.attr("data-following","true"),i.removeClass("follow-small"),i.addClass("unfollow-small"),n=$(".counter.current"),s=n.find(".info").attr("data-url"),e(s,n.attr("id"));if(n.attr("id")==="followers-counter"&&$.parseJSON($("#counters").attr("data-current-user").toString()))return $("#following-counter .number").text(t.followings)}else{i.attr("data-following","false"),i.removeClass("unfollow-small"),i.addClass("follow-small"),n=$(".counter.current"),s=n.find(".info").attr("data-url"),e(s,n.attr("id"));if(n.attr("id")==="followers-counter"&&$.parseJSON($("#counters").attr("data-current-user").toString()))return $("#following-counter .number").text(t.followings)}}})},t=function(e){return $.modal.close(),window.setTimeout("$('#delete-confirm-popup').modal()",300),$("#delete-confirm-popup #btn-ok").click(function(){var t;return $.modal.close(),window.setTimeout("$('#mask').modal()",300),t=$(e),$.ajax({url:t.attr("data-url"),type:"GET",data:{id:t.closest(".avatar").attr("data-id")},dataType:"json",success:function(e){return e.success===!1?(helper.show_notification(e.msg),$.modal.close(),window.setTimeout("$('#edit-profile-photo-popup').modal()",300)):($("#edit-profile-photo-popup .current-photo .avatar").attr("src",e.extra_avatar_url),$("#user-section .avatar.large").attr("src",e.large_avatar_url),$("#edit-profile-photo-popup .held-photos .photos").html(e.profile_photos),helper.show_notification("Delete successfully!"),$.modal.close(),window.setTimeout("$('#edit-profile-photo-popup').modal()",300))}})}),$("#delete-confirm-popup .button.cancel").click(function(){return window.setTimeout("$('#edit-profile-photo-popup').modal()",300)})},i=function(e){var t;return t=$(e),$.ajax({url:t.attr("data-url"),type:"GET",data:{id:t.closest(".avatar").attr("data-id")},dataType:"json",success:function(e){return e.success===!1?helper.show_notification(e.msg):(helper.show_notification("Update successfully!"),$("#edit-profile-photo-popup .current-photo .avatar").attr("src",e.extra_avatar_url),$("#user-section .avatar.large").attr("src",e.large_avatar_url))}})},$(function(){var s;return $.ajaxSetup({error:function(e){if(e.status===401||e.status===403)return window.location.reload()}}),s=["#likes-section .edit-pane","#following-section .edit-pane","#container .title",".list"],$.each(s,function(t,n){return $(n).click(function(t){var n,r;return n=$(this).closest(".container").attr("id").replace("-section","-counter"),$("#counters .counter.current").removeClass("current"),$("#"+n).addClass("current"),r=$(this).attr("href"),e(r,n),!1})}),$("#user-section .avatar .edit-pane").click(function(){return $("#edit-profile-photo-popup").modal({persist:!0})}),$("#user-section .info .edit-pane").click(function(){return $("#edit-profile-info-popup").modal({persist:!0})}),$("#edit-profile-photo-popup #fileupload").fileupload(),$("#edit-profile-photo-popup #fileupload").fileupload("option",{dataType:"text",maxFileSize:5e6,acceptFileTypes:/(\.|\/)(gif|jpe?g|png)$/i,add:function(e,t){return $.modal.close(),window.setTimeout("$('#mask').modal()",300),t.submit()},done:function(e,t){var n;return n=$.parseJSON(t.result),n.success===!1?(helper.show_notification(n.msg),$.modal.close(),window.setTimeout("$('#edit-profile-photo-popup').modal()",300)):(helper.show_notification("Update successfully!"),$("#edit-profile-photo-popup .held-photos .photos").html(n.profile_photos),$("#edit-profile-photo-popup .current-photo .avatar").attr("src",n.extra_avatar_url),$("#user-section .avatar.large").attr("src",n.large_avatar_url),$.modal.close(),window.setTimeout("$('#edit-profile-photo-popup').modal()",300))}}),$("body").delegate("#edit-profile-photo-popup .held-photos .delete","click",function(e){return t(e.target)}),$("body").delegate("#edit-profile-photo-popup .held-photos img","click",function(e){return i(e.target)}),$("#container").delegate(".user-section .button","click",function(e){return r(e.target)}),$("#container").delegate(".image-section .button","click",function(e){return n(e.target)}),$("#counters .counter .info").click(function(){var t,n;n=$(this).attr("data-url"),t=$(this).closest(".counter");if(n!=="#"&&!t.hasClass("current"))return $("#counters .counter.current").removeClass("current"),t.addClass("current"),e(n,t.attr("id"))}),$("#btn-follow").click(function(){var t,n;return t=$(this).attr("data-author-id"),n=$(this).attr("data-following"),$("#mask").modal(),$.ajax({url:"/users/follow",type:"GET",data:{user_id:t,unfollow:n},dataType:"json",success:function(t){return t.success===!1?(helper.show_notification(t.msg),$.modal.close()):n==="false"?($("#btn-follow").attr("data-following","true"),$("#btn-follow").removeClass("follow"),$("#btn-follow").addClass("unfollow"),$(".note").fadeIn(),$.parseJSON($("#counters").attr("data-current-user").toString())?$.modal.close():$(".counter.current").attr("id")==="followers-counter"?e($(".counter.current .info").attr("data-url"),"followers-counter"):($("#followers-counter .info .number").text(t.followee_followers),$("#followers-counter .info .label").text(helper.pluralize_without_count(t.followee_followers,"follower","followers")),$.modal.close())):($("#btn-follow").attr("data-following","false"),$("#btn-follow").removeClass("unfollow"),$("#btn-follow").addClass("follow"),$(".note").fadeOut(),$.parseJSON($("#counters").attr("data-current-user").toString())?$.modal.close():$(".counter.current").attr("id")==="followers-counter"?e($(".counter.current .info").attr("data-url"),"followers-counter"):($("#followers-counter .info .number").text(t.followee_followers),$("#followers-counter .info .label").text(helper.pluralize_without_count(t.followee_followers,"follower","followers")),$.modal.close()))}})}),$("#btn-update").click(function(){var e,t,n;$("#frm-edit-profile-info").submit();return}),$("#user_first_name").keypress(function(e){return helper.prevent_exceed_characters(this,e.charCode,30)}),$("#user_last_name").keypress(function(e){return helper.prevent_exceed_characters(this,e.charCode,30)}),$("#user_first_name").blur(function(){return helper.check_less_than_characters(this.value,2,function(){return helper.show_notification("First name must be at least 2 characters!")})}),$("#user_last_name").blur(function(){return helper.check_less_than_characters(this.value,2,function(){return helper.show_notification("Last name must be at least 2 characters!")})})})}).call(this);