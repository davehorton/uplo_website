flagged_users={setup_forms:function(){$(".action-container").delegate(".button.reinstate","click",function(a){var b=a.target;$(b).hasClass("disabled")||flagged_users.do_action(b)}),$(".action-container").delegate(".button.remove","click",function(a){var b=a.target;$(b).hasClass("disabled")||flagged_users.do_action(b)}),$(".action-container").delegate("#remove_flagged_users","click",function(a){var b=a.target;$(b).hasClass("disabled")||flagged_users.do_action(b)}),$(".action-container").delegate("#reinstate_flagged_users","click",function(a){var b=a.target;$(b).hasClass("disabled")||flagged_users.do_action(b)}),$(".button.tooltip").poshytip({className:"tip-yellowsimple",showTimeout:100,alignTo:"target",alignX:"center",offsetY:5,allowTipHover:!1})},do_action:function(a){$("#flagged-users-confirm-popup").modal();var b=$(a).attr("data-confirm");$("#flagged-users-confirm-popup").find("#confirm-message-container").text(b),$("#btn-ok").click(function(){$.modal.close(),window.setTimeout("$('#mask').modal()",200);var b=$(a).find("form.action-form"),c=$(b).attr("action"),d=$(b).serialize();if(!c||!d)return!1;$.ajax({url:c,type:"POST",data:d,success:function(b){if(b.status=="ok"){$(a).addClass("disabled");var c=$.trim(b.redirect_url);c&&c!=""&&(window.location.href=c)}else jQuery.trim(b.message)!=""&&helper.show_notification(b.message);$.modal.close()}})})}};