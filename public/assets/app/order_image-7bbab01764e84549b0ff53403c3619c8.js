((function(){var a;a=function(){return $.ajax({url:"/images/get_price",type:"GET",dataType:"json",data:{image_id:image_id,size:$(".print-sizes-container input:radio:checked").attr("value")},success:function(a){return a.success?($("#image-price").text(a.price),$.modal.close()):(helper.show_notification(a.msg),window.location="/browse")}})},$(function(){return a(),$(".print-sizes-container input:radio").change(function(a,b){return $("#mask").modal(),$.ajax({url:"/images/get_price",type:"GET",dataType:"json",data:{image_id:image_id,size:$(a.target).attr("value")},success:function(a){return a.success?($("#image-price").text(a.price),$.modal.close()):(helper.show_notification(a.msg),window.location="/browse")}})})})})).call(this);