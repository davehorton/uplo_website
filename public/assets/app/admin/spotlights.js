spotlights={setup_promote_popup:function(){$(".image-container").delegate(".promote-button","click",function(a){var b=a.target;spotlights.do_promote_photo(b)})},do_promote_photo:function(a){$("#promote-confirm-popup").modal();var b="",c=!0;$(a).hasClass("disabled")?(b=$("#promote-confirm-popup-container").attr("data-demote-confirm"),c=!1):(b=$("#promote-confirm-popup-container").attr("data-promote-confirm"),c=!0),$("#promote-confirm-popup").find("#confirm-message-container").text(b),$("#btn-ok").click(function(){$.modal.close(),window.setTimeout("$('#mask').modal()",200);var b=$(a).find("form.promote-photo-form"),d=$(b).attr("action"),e=$(b).serialize();if(!d||!e)return!1;$.ajax({url:d,type:"POST",data:e,success:function(e){if(e.status=="ok"){var f=$.url(d),g=f.param();c?($(a).addClass("disabled"),$(a).parents(".image-container").addClass("promoted"),g.demote=!0):($(a).removeClass("disabled"),$(a).parents(".image-container").removeClass("promoted"),delete g.demote),d=f.attr("path")+"?"+$.param(g),$(b).attr("action",d)}else jQuery.trim(e.message)!=""&&alert(e.message);$.modal.close()}})})}};