spotlights={setup_promote_popup:function(){$(".image-container").delegate(".promote-button","click",function(e){var t=e.target;spotlights.do_promote_photo(t)})},do_promote_photo:function(e){$("#promote-confirm-popup").modal();var t="",n=!0;$(e).hasClass("disabled")?(t=$("#promote-confirm-popup-container").attr("data-demote-confirm"),n=!1):(t=$("#promote-confirm-popup-container").attr("data-promote-confirm"),n=!0),$("#promote-confirm-popup").find("#confirm-message-container").text(t),$("#btn-ok").click(function(){$.modal.close(),window.setTimeout("$('#mask').modal()",200);var t=$(e).find("form.promote-photo-form"),r=$(t).attr("action"),i=$(t).serialize();if(!r||!i)return!1;$.ajax({url:r,type:"POST",data:i,success:function(i){if(i.status=="ok"){var s=$.url(r),o=s.param();n?($(e).addClass("disabled"),$(e).parents(".image-container").addClass("promoted"),o.demote=!0):($(e).removeClass("disabled"),$(e).parents(".image-container").removeClass("promoted"),delete o.demote),r=s.attr("path")+"?"+$.param(o),$(t).attr("action",r)}else jQuery.trim(i.message)!=""&&helper.show_notification(i.message);$.modal.close()}})})}};