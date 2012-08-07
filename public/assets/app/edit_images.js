((function(){var a,b,c,d,e,f;d=function(a,b,c){var d,e,f,g,h,i,j;return d=$(document.createElement("div")).addClass("clear"),i=$(document.createElement("div")).addClass("line-separator left"),g=$(document.createElement("div")),g.attr("title",c),g.addClass("image-container thumb no-padding"),g.append(b),e=$(document.createElement("div")),e.addClass("info-panel left"),j=$(document.createElement("div")),j.addClass("info-line left"),f=$(document.createElement("div")),f.addClass("label text black bold font12"),f.text(c),j.append(f),e.append(j),j=$(document.createElement("div")),j.addClass("progress info-line left"),h=$(document.createElement("div")),h.addClass("uploading"),j.append(h),e.append(j),a.addClass("upload-template container left"),a.append(g),a.append(e),a.append(d),a.append(i),a},c=function(a){var b;return b=$(document.createElement("div")),window.loadImage(a,function(c){return d(b,c,a.name),b.prependTo("#images-panel")},{maxWidth:155,maxHeight:155,canvas:!0}),b},b=function(a){return $("#delete-confirm-popup").modal(),$("#btn-ok").click(function(){return $.modal.close(),window.setTimeout("$('#mask').modal()",500),$.ajax({url:$(a).attr("data-url"),type:"GET",dataType:"json",success:function(a){return a.success?($("#images-panel").html(a.items),$(".pagination-panel").each(function(b,c){return $(c).html(a.pagination)}),$("#gallery_selector_id").html(a.gallery_options),$("select").selectmenu({style:"dropdown"}),helper.show_notification("Delete successfully!")):helper.show_notification(a.msg),$.modal.close()}})})},f=function(a){var b,c;return b=[],c=$("#images-panel .edit-template"),c.each(function(a,c){var d;return d=$(c),b.push({id:d.attr("data-id"),name:d.find("#image_name").val(),gallery_id:d.find("#image_gallery_id").val(),price:d.find("#image_price").val(),description:d.find("#image_description").val(),is_album_cover:d.find(".album-cover").is(":checked"),is_avatar:d.find(".user-avatar").is(":checked"),keyword:d.find("#image_key_words").val()})}),$("#mask").modal(),$.ajax({url:"/images/update_images",type:"POST",data:{images:$.toJSON(b),gallery_id:$("#gallery_selector_id").val()},dataType:"json",success:function(b){return $("#images-panel").html(b.items),$(".pagination-panel").each(function(a,c){return $(c).html(b.pagination)}),$("#gallery_selector_id").html(b.gallery_options),$("select").selectmenu({style:"dropdown"}),helper.show_notification("Update successfully!"),a&&a.call(),window.is_grid_changed=!1,$.modal.close()}})},a=function(a){return window.is_grid_changed===!0?($("#save-confirm-popup").modal(),$(".button.save-my-changes").click(function(){return f(a)}),$(".button.leave-not-saving").click(function(){return a.call()})):a.call()},e=function(a){var b,c;return c=$(a).closest(".edit-template").attr("data-id"),b=$("#frm-pricing").serialize(),$.modal.close(),window.setTimeout("$('#mask').modal()",300),$.ajax({url:"/images/update_tier?id="+c,type:"POST",data:b,dataType:"json",success:function(b){return b.success?(helper.show_notification("Price has been updated successfully!"),$(a).siblings().text("Tier "+b.tier),$.modal.close()):(helper.show_notification("Something went wrong!"),$("#pricing-form").modal())}})},$(function(){return window.is_grid_changed=!1,$("#fileupload").fileupload(),$("#fileupload").fileupload("option",{dataType:"text",maxFileSize:5e6,acceptFileTypes:/(\.|\/)(gif|jpe?g|png)$/i,previewMaxWidth:180,previewMaxHeight:180,add:function(a,b){return b.context=c(b.files[0]),b.submit()},done:function(a,b){var c;return c=$.parseJSON(b.result),c.success?($(b.context).replaceWith(c.item),$(".pagination-panel").each(function(a,b){return $(b).html(c.pagination)}),$(".pagination-panel").find(".pagination").length>0&&$("#images-panel").children().last().remove(),$("#gallery_selector_id").html(c.gallery_options),$(".empty-data").remove(),$("select[id=gallery_permission]").selectmenu({style:"dropdown"})):$(b.context).find(".progress").replaceWith("<div class='error info-line text italic font12 left'>"+c.msg+"</div>")},progress:function(a,b){var c,d;c=parseInt(b.loaded/b.total*100,10).toString()+"%";if(b.context)return d=function(){return $(b.context).find(".progress .uploading").css("width","80%")},window.setTimeout(d,300)},fail:function(a,b){return $(b.context).find(".progress").replaceWith("<div class='error info-line text italic font12 left'>Cannot upload this image right now! Please try again later!</div>")}}),$(".button.save-grid-changes").click(function(){return f()}),$("#images-panel").delegate(".edit-template .album-cover","click",function(a){var b;return b=$("#images-panel .edit-template .album-cover").not(a.target),b.attr("checked",!1)}),$("#images-panel").delegate(".edit-template .user-avatar","click",function(a){var b;return b=$("#images-panel .edit-template .user-avatar").not(a.target),b.attr("checked",!1)}),$("#images-panel").delegate(".button.delete-photo","click",function(a){return b(a.target)}),$("#edit-gallery").click(function(){return $("#edit-gallery-popup").modal()}),$("body").delegate("#btn-gallery-save","click",function(a){return $.ajax({url:$("#frm-edit-gallery").attr("action"),type:"POST",data:$("#frm-edit-gallery").serialize(),dataType:"json",success:function(a){return a.success?(helper.show_notification("Your gallery has been updated!"),$.modal.close(),$("#edit-gallery-popup").replaceWith(a.edit_popup),$("#gallery_selector_id").html(a.gal_with_number_options),$(".edit-template #image_gallery_id").each(function(b,c){return $(c).html(a.gallery_options)}),$("select[id=gallery_permission]").selectmenu({style:"dropdown"})):helper.show_notification(a.msg)}})}),$("#images-panel").delegate(".edit-template input","change",function(a){return window.is_grid_changed=!0}),$("#images-panel").delegate(".edit-template textarea","change",function(a){return window.is_grid_changed=!0}),$("#images-panel").delegate(".edit-template select","change",function(a){return window.is_grid_changed=!0}),$(".pagination-panel").delegate("a","click",function(b){return b.preventDefault(),a(function(){return window.location=$(b.target).attr("href")})}),$(".header-menu ul li > a").click(function(b){return b.preventDefault(),a(function(){return window.location=$(b.target).attr("href")})}),$("#my_links").selectmenu({style:"dropdown",select:function(b,c){return a(function(){return window.location=c.value})}}),$("#gallery_selector_id").change(function(){return a(function(){return $.ajax({url:"edit_images",type:"GET",data:{gallery_id:$("#gallery_selector_id").val()},dataType:"json",success:function(a){return $("#images-panel").html(a.items),$(".pagination-panel").each(function(b,c){return $(c).html(a.pagination)}),$("#delete-gallery").attr("href",a.delete_url),$("#fileupload").attr("action",a.upload_url),$("#edit-gallery-popup").replaceWith(a.edit_popup),$(this).html(a.gallery_options),$("select").selectmenu({style:"dropdown"}),$.modal.close()}})})}),$("#images-panel").delegate(".edit-template .price","click",function(a){var b,c,d,f;return d=a.target,b=$("#pricing-form"),c=a.clientX-60,f=a.clientY-b.height(),$("#pricing-form").modal({opacity:5,position:[f,c],escClose:!1,overlayClose:!0,onOpen:function(c){return c.overlay.fadeIn("slow",function(){return c.container.fadeIn("slow",function(){var g;return c.data.fadeIn(),$("#pricing-form .button").fadeOut(),g=$(d).closest(".edit-template").attr("data-id"),$.ajax({url:"/images/show_pricing",type:"GET",data:{id:g},dataType:"json",success:function(c){return c.success?($("#price-tiers").html(c.price_table),$("#pricing-form .button").fadeIn(),f=a.clientY-b.height(),b.closest(".simplemodal-container").css("top",""+f+"px"),$("#btn-done").click(function(){return e(d)})):($("#price-tiers").html(c.msg),$("#pricing-form .button.close").fadeIn(),f=a.clientY-b.height(),b.closest(".simplemodal-container").css("top",""+f+"px"))}})})})}})})})})).call(this);