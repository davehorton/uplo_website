((function(){var a,b,c,d,e;helper.endless_load_more(function(){return $(document).height()-20<=$(window).height()?$(window).scroll():$.modal.close()}),a=function(a,b){return $("#mask").modal(),$.ajax({url:a,type:"GET",dataType:"json",success:function(a){var c,d,e;return d=b.replace("-counter",""),d==="galleries"?e="gallery":e=d.replace(/[s]$/,""),c=helper.pluralize_without_count(a.counter,e,d),$("#container").html(a.html),$("#"+b).find(".info .number").text(a.counter),$("#"+b).find(".info .label").text(c),$(window).scroll()}})},c=function(b){var c;return c=$(b),$("#mask").modal(),$.ajax({url:"/unlike_image",type:"GET",data:{image_id:c.attr("data-id")},dataType:"json",success:function(b){var c,d;return b.success===!1?(helper.show_notification(b.msg),$.modal.close()):(c=$(".counter.current"),d=c.find(".info").attr("data-url"),a(d,c.attr("id")))}})},d=function(b){var c,d,e;return e=$(b),c=e.attr("data-author-id"),d=e.attr("data-following"),$("#mask").modal(),$.ajax({url:"/users/follow",type:"GET",data:{user_id:c,unfollow:d},dataType:"json",success:function(b){var c,f;if(b.success===!1)return helper.show_notification(b.msg),$.modal.close();if(d==="false"){e.attr("data-following","true"),e.removeClass("follow-small"),e.addClass("unfollow-small"),c=$(".counter.current"),f=c.find(".info").attr("data-url"),a(f,c.attr("id"));if(c.attr("id")==="followers-counter"&&$.parseJSON($("#counters").attr("data-current-user").toString()))return $("#following-counter .number").text(b.followings)}else{e.attr("data-following","false"),e.removeClass("unfollow-small"),e.addClass("follow-small"),c=$(".counter.current"),f=c.find(".info").attr("data-url"),a(f,c.attr("id"));if(c.attr("id")==="followers-counter"&&$.parseJSON($("#counters").attr("data-current-user").toString()))return $("#following-counter .number").text(b.followings)}}})},b=function(a){return $.modal.close(),window.setTimeout("$('#delete-confirm-popup').modal()",300),$("#delete-confirm-popup #btn-ok").click(function(){var b;return $.modal.close(),window.setTimeout("$('#mask').modal()",300),b=$(a),$.ajax({url:b.attr("data-url"),type:"GET",data:{id:b.closest(".avatar").attr("data-id")},dataType:"json",success:function(a){return a.success===!1?(helper.show_notification(a.msg),$.modal.close(),window.setTimeout("$('#edit-profile-photo-popup').modal()",300)):($("#edit-profile-photo-popup .current-photo .avatar").attr("src",a.extra_avatar_url),$("#user-section .avatar.large").attr("src",a.large_avatar_url),$("#edit-profile-photo-popup .held-photos .photos").html(a.profile_photos),helper.show_notification("Delete successfully!"),$.modal.close(),window.setTimeout("$('#edit-profile-photo-popup').modal()",300))}})}),$("#delete-confirm-popup .button.cancel").click(function(){return window.setTimeout("$('#edit-profile-photo-popup').modal()",300)})},e=function(a){var b;return b=$(a),$.ajax({url:b.attr("data-url"),type:"GET",data:{id:b.closest(".avatar").attr("data-id")},dataType:"json",success:function(a){return a.success===!1?helper.show_notification(a.msg):(helper.show_notification("Update successfully!"),$("#edit-profile-photo-popup .current-photo .avatar").attr("src",a.extra_avatar_url),$("#user-section .avatar.large").attr("src",a.large_avatar_url))}})},$(function(){var f;return f=["#likes-section .edit-pane","#following-section .edit-pane","#container .title","#followers-section .list"],$.each(f,function(b,c){return $(c).click(function(b){var d,e;return d=$(c).closest(".container").attr("id").replace("-section","-counter"),$("#counters .counter.current").removeClass("current"),$("#"+d).addClass("current"),e=$(c).attr("href"),a(e,d),!1})}),$("#user-section .avatar .edit-pane").click(function(){return $("#edit-profile-photo-popup").modal({persist:!0})}),$("#user-section .info .edit-pane").click(function(){return $("#edit-profile-info-popup").modal({persist:!0})}),$("#edit-profile-photo-popup #fileupload").fileupload(),$("#edit-profile-photo-popup #fileupload").fileupload("option",{dataType:"text",maxFileSize:5e6,acceptFileTypes:/(\.|\/)(gif|jpe?g|png)$/i,add:function(a,b){return $.modal.close(),window.setTimeout("$('#mask').modal()",300),b.submit()},done:function(a,b){var c;return c=$.parseJSON(b.result),c.success===!1?(helper.show_notification(c.msg),$.modal.close(),window.setTimeout("$('#edit-profile-photo-popup').modal()",300)):(helper.show_notification("Update successfully!"),$("#edit-profile-photo-popup .held-photos .photos").html(c.profile_photos),$("#edit-profile-photo-popup .current-photo .avatar").attr("src",c.extra_avatar_url),$("#user-section .avatar.large").attr("src",c.large_avatar_url),$.modal.close(),window.setTimeout("$('#edit-profile-photo-popup').modal()",300))}}),$("body").delegate("#edit-profile-photo-popup .held-photos .delete","click",function(a){return b(a.target)}),$("body").delegate("#edit-profile-photo-popup .held-photos img","click",function(a){return e(a.target)}),$("#container").delegate(".user-section .button","click",function(a){return d(a.target)}),$("#container").delegate(".image-section .button","click",function(a){return c(a.target)}),$("#counters .counter .info").click(function(){var b,c;c=$(this).attr("data-url"),b=$(this).closest(".counter");if(c!=="#"&&!b.hasClass("current"))return $("#counters .counter.current").removeClass("current"),b.addClass("current"),a(c,b.attr("id"))}),$("#btn-follow").click(function(){var b,c;return b=$(this).attr("data-author-id"),c=$(this).attr("data-following"),$("#mask").modal(),$.ajax({url:"/users/follow",type:"GET",data:{user_id:b,unfollow:c},dataType:"json",success:function(b){return b.success===!1?helper.show_notification(b.msg):c==="false"?($("#btn-follow").attr("data-following","true"),$("#btn-follow").removeClass("follow"),$("#btn-follow").addClass("unfollow"),$(".note").fadeIn(),$.parseJSON($("#counters").attr("data-current-user").toString())?$.modal.close():$(".counter.current").attr("id")==="followers-counter"?a($(".counter.current .info").attr("data-url"),"followers-counter"):($("#followers-counter .info .number").text(b.followee_followers),$("#followers-counter .info .label").text(helper.pluralize_without_count(b.followee_followers,"follower","followers")),$.modal.close())):($("#btn-follow").attr("data-following","false"),$("#btn-follow").removeClass("unfollow"),$("#btn-follow").addClass("follow"),$(".note").fadeOut(),$.parseJSON($("#counters").attr("data-current-user").toString())?$.modal.close():$(".counter.current").attr("id")==="followers-counter"?a($(".counter.current .info").attr("data-url"),"followers-counter"):($("#followers-counter .info .number").text(b.followee_followers),$("#followers-counter .info .label").text(helper.pluralize_without_count(b.followee_followers,"follower","followers")),$.modal.close()))}})}),$("#btn-update").click(function(){var a,b,c;return b=/^([0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*@(([0-9a-zA-Z])+([-\w]*[0-9a-zA-Z])*\.)+[a-zA-Z]{2,9})$/i,c=/(^$)|(^((http|https):\/\/){0,1}[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/i,b.test($("#user_email").val())===!1?helper.show_notification("Email is invalid!"):c.test($("#user_website").val())===!1?helper.show_notification("Website is invalid!"):$("#user_first_name").val().length<2||$("#user_first_name").val().length>30?helper.show_notification("First name must be 2 - 30 characters in length"):$("#user_last_name").val().length<2||$("#user_last_name").val().length>30?helper.show_notification("Last name must be 2 - 30 characters in length"):(a=$("#frm-edit-profile-info"),$.modal.close(),window.setTimeout("$('#mask').modal()",300),$.ajax({url:a.attr("action"),type:"POST",data:a.serialize(),dataType:"json",success:function(a){return a.success?(helper.show_notification("Your profile has been updated!"),$("#user-section .name a").text(a.fullname),$.modal.close()):(helper.show_notification(a.msg),$.modal.close(),window.setTimeout("$('#edit-profile-info-popup').modal()",300))}}))}),$("#user_first_name").keypress(function(a){return helper.prevent_exceed_characters(this,a.charCode,30)}),$("#user_last_name").keypress(function(a){return helper.prevent_exceed_characters(this,a.charCode,30)}),$("#user_first_name").blur(function(){return helper.check_less_than_characters(this.value,2,function(){return helper.show_notification("First name must be at least 2 characters!")})}),$("#user_last_name").blur(function(){return helper.check_less_than_characters(this.value,2,function(){return helper.show_notification("Last name must be at least 2 characters!")})})})})).call(this);