((function(){var a,b,c,d,e;helper.endless_load_more(function(){return $(document).height()-20<=$(window).height()?$(window).scroll():$.modal.close()}),a=function(a,b){return $("#mask").modal(),$.ajax({url:a,type:"GET",dataType:"json",success:function(a){var c,d,e;return d=b.replace("-counter",""),e=d.replace(/[s]$/,""),c=helper.pluralize_without_count(a.counter,e,d),$("#container").html(a.html),$("#"+b).find(".info .number").text(a.counter),$("#"+b).find(".info .label").text(c),$(window).scroll()}})},c=function(a){var b;return b=$(a),$("#mask").modal(),$.ajax({url:"/unlike_image",type:"GET",data:{image_id:b.attr("data-id")},dataType:"json",success:function(a){var c;return a.success===!1?alert(a.msg):(c=helper.pluralize_without_count(a.likes,"Like","Likes"),$("#likes-counter .number").text(a.likes),$("#likes-counter .label").text(c),$("#counter").text("("+a.likes+")"),$(".container .head .label").text(c),b.closest(".image-section").remove()),$.modal.close()}})},d=function(a){var b,c,d;return d=$(a),b=d.attr("data-author-id"),c=d.attr("data-following"),$("#mask").modal(),$.ajax({url:"/users/follow",type:"GET",data:{user_id:b,unfollow:c},dataType:"json",success:function(a){return a.success===!1?alert(a.msg):c==="false"?(d.attr("data-following","true"),d.text("Unfollow"),$.parseJSON($("#counters").attr("data-current-user").toString())&&($("#following-counter .number").text(a.followings),$("#followers-counter .number").text(a.followers),$(".followings-container .head #counter").text("("+a.followings+")"),$(".followers-container .head #counter").text("("+a.followers+")"))):(d.attr("data-following","false"),d.text("Follow"),d.closest(".user-section.following").remove(),$.parseJSON($("#counters").attr("data-current-user").toString())&&($("#following-counter .number").text(a.followings),$("#followers-counter .number").text(a.followers),$(".followings-container .head #counter").text("("+a.followings+")"),$(".followers-container .head #counter").text("("+a.followers+")"))),$.modal.close()}})},b=function(a){return $.modal.close(),window.setTimeout("$('#delete-confirm-popup').modal()",300),$("#delete-confirm-popup #btn-ok").click(function(){var b;return $.modal.close(),window.setTimeout("$('#mask').modal()",300),b=$(a),$.ajax({url:b.attr("data-url"),type:"GET",data:{id:b.closest(".avatar").attr("data-id")},dataType:"json",success:function(a){return a.success===!1?(alert(a.msg),$.modal.close(),window.setTimeout("$('#edit-profile-photo-popup').modal()",300)):($("#edit-profile-photo-popup .current-photo .avatar").attr("src",a.extra_avatar_url),$("#user-section .avatar.large").attr("src",a.large_avatar_url),$("#edit-profile-photo-popup .held-photos .photos").html(a.profile_photos),alert("Delete successfully!"),$.modal.close(),window.setTimeout("$('#edit-profile-photo-popup').modal()",300))}})}),$("#delete-confirm-popup .button.cancel").click(function(){return window.setTimeout("$('#edit-profile-photo-popup').modal()",300)})},e=function(a){var b;return b=$(a),$.ajax({url:b.attr("data-url"),type:"GET",data:{id:b.closest(".avatar").attr("data-id")},dataType:"json",success:function(a){return a.success===!1?alert(a.msg):(alert("Update successfully!"),$("#edit-profile-photo-popup .current-photo .avatar").attr("src",a.extra_avatar_url),$("#user-section .avatar.large").attr("src",a.large_avatar_url))}})},$(function(){return $(".not-implement").click(function(){return helper.alert_not_implement()}),$("#container .edit-pane").click(function(){var b;return b=$(this).closest(".container").attr("id").replace("-section","-counter"),$("#counters .counter.current").removeClass("current"),$("#"+b).addClass("current"),a($(this).attr("data-url"),b)}),$('#container .list[data-url!="#"]').click(function(){var b;return b=$(this).closest(".container").attr("id").replace("-section","-counter"),$("#counters .counter.current").removeClass("current"),$("#"+b).addClass("current"),a($(this).attr("data-url"),b)}),$("#user-section .avatar .edit-pane").click(function(){return $("#edit-profile-photo-popup").modal({persist:!0})}),$("#user-section .info .edit-pane").click(function(){return $("#edit-profile-info-popup").modal({persist:!0})}),$("#edit-profile-photo-popup #fileupload").fileupload(),$("#edit-profile-photo-popup #fileupload").fileupload("option",{dataType:"text",maxFileSize:5e6,acceptFileTypes:/(\.|\/)(gif|jpe?g|png)$/i,add:function(a,b){return $.modal.close(),window.setTimeout("$('#mask').modal()",300),b.submit()},done:function(a,b){var c;return c=$.parseJSON(b.result),c.success===!1?(alert(c.msg),$.modal.close(),window.setTimeout("$('#edit-profile-photo-popup').modal()",300)):(alert("Update successfully!"),$("#edit-profile-photo-popup .held-photos .photos").html(c.profile_photos),$("#edit-profile-photo-popup .current-photo .avatar").attr("src",c.extra_avatar_url),$("#user-section .avatar.large").attr("src",c.large_avatar_url),$.modal.close(),window.setTimeout("$('#edit-profile-photo-popup').modal()",300))}}),$("body").delegate("#edit-profile-photo-popup .held-photos .delete","click",function(a){return b(a.target)}),$("body").delegate("#edit-profile-photo-popup .held-photos img","click",function(a){return e(a.target)}),$("#container").delegate(".follow","click",function(a){return d(a.target)}),$("#container").delegate(".like","click",function(a){return c(a.target)}),$("#counters .counter .info").click(function(){var b,c;c=$(this).attr("data-url"),b=$(this).closest(".counter");if(c!=="#"&&!b.hasClass("current"))return $("#counters .counter.current").removeClass("current"),b.addClass("current"),a(c,b.attr("id"))}),$("#btn-follow").click(function(){var a,b;return a=$(this).attr("data-author-id"),b=$(this).attr("data-following"),$("#mask").modal(),$.ajax({url:"/users/follow",type:"GET",data:{user_id:a,unfollow:b},dataType:"json",success:function(a){return a.success===!1?alert(a.msg):b==="false"?($("#btn-follow").attr("data-following","true"),$("#btn-follow").removeClass("follow"),$("#btn-follow").addClass("unfollow"),$(".note").fadeIn()):($("#btn-follow").attr("data-following","false"),$("#btn-follow").removeClass("unfollow"),$("#btn-follow").addClass("follow"),$(".note").fadeOut()),$.modal.close()}})}),$("#btn-update").click(function(){var a,b,c;return b=/^([0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*@(([0-9a-zA-Z])+([-\w]*[0-9a-zA-Z])*\.)+[a-zA-Z]{2,9})$/i,c=/(^$)|(^((http|https):\/\/){0,1}[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/i,b.test($("#user_email").val())===!1?alert("Email is invalid!"):c.test($("#user_website").val())===!1?alert("Website is invalid!"):$("#user_first_name").val().length<2||$("#user_first_name").val().length>30?alert("First name must be 2 - 30 characters in length"):$("#user_last_name").val().length<2||$("#user_last_name").val().length>30?alert("Last name must be 2 - 30 characters in length"):(a=$("#frm-edit-profile-info"),$.modal.close(),window.setTimeout("$('#mask').modal()",300),$.ajax({url:a.attr("action"),type:"POST",data:a.serialize(),dataType:"json",success:function(a){return a.success?(alert("Your profile has been updated!"),$("#user-section .name a").text(a.fullname),$.modal.close()):(alert(a.msg),$.modal.close(),window.setTimeout("$('#edit-profile-info-popup').modal()",300))}}))}),$("#user_first_name").keypress(function(a){return helper.prevent_exceed_characters(this,a.charCode,30)}),$("#user_last_name").keypress(function(a){return helper.prevent_exceed_characters(this,a.charCode,30)}),$("#user_first_name").blur(function(){return helper.check_less_than_characters(this.value,2,function(){return alert("First name must be at least 2 characters!")})}),$("#user_last_name").blur(function(){return helper.check_less_than_characters(this.value,2,function(){return alert("Last name must be at least 2 characters!")})})})})).call(this);