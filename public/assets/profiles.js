((function(){var a;a=function(a,b){return $("#mask").modal(),$.ajax({url:a,type:"GET",dataType:"html",success:function(a){return $("#container")[0].innerHTML=a,helper.endless_load_more(function(){$(document).height()<=$(window).height()&&$(window).scroll()}),$(window).scroll(),$.modal.close()}})},$(function(){return $(".not-implement").click(function(){return helper.alert_not_implement()}),$('#container .edit-pane[data-url!="#"]').click(function(){return a($(this).attr("data-url"))}),$("#followers-section .list").click(function(){return a($(this).attr("data-url"))}),$("#container").delegate(".follow","click",function(a){var b,c,d;return d=$(a.target),b=d.attr("data-author-id"),c=d.attr("data-following"),$("#mask").modal(),$.ajax({url:"/users/follow",type:"GET",data:{user_id:b,unfollow:c},dataType:"json",success:function(a){return a.success===!1?alert(a.msg):c==="false"?(d.attr("data-following","true"),d.text("Unfollow")):(d.attr("data-following","false"),d.text("Follow")),$.modal.close()}})}),$("#counters .counter").click(function(){var b;b=$(this).attr("data-url");if(b!=="#")return a(b)})})})).call(this);