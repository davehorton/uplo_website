((function(){var a,b,c,d;d=function(a,b,c){var d,e,f,g,h,i,j;return d=$(document.createElement("div")).addClass("clear"),i=$(document.createElement("div")).addClass("line-separator left"),g=$(document.createElement("div")),g.attr("title",c),g.addClass("image-container thumb no-padding"),g.append(b),e=$(document.createElement("div")),e.addClass("info-panel left"),j=$(document.createElement("div")),j.addClass("info-line left"),f=$(document.createElement("div")),f.addClass("label text black bold font12"),f.text(c),j.append(f),e.append(j),j=$(document.createElement("div")),j.addClass("progress info-line left"),h=$(document.createElement("div")),h.addClass("uploading"),j.append(h),e.append(j),a.addClass("upload-template container left"),a.append(g),a.append(e),a.append(d),a.append(i),a},c=function(a){var b;return b=$(document.createElement("div")),window.loadImage(a,function(c){return d(b,c,a.name),b.prependTo("#images-panel")},{maxWidth:155,maxHeight:155,canvas:!0}),b},b=function(a){return $("#delete-confirm-popup").modal(),$("#btn-ok").click(function(){return $.modal.close(),window.setTimeout("$('#mask').modal()",500),$.ajax({url:$(a).attr("data-url"),type:"GET",dataType:"json",success:function(a){return $("#images-panel")[0].innerHTML=a.items,$(".pagination-panel").each(function(b,c){return c.innerHTML=a.pagination}),$("#gallery_selector_id")[0].innerHTML=a.gallery_options,alert("Delete successfully!"),$.modal.close()}})})},a=function(a){return window.is_grid_changed===!0?($("#save-confirm-popup").modal(),$(".button.save-my-changes").click(function(){return $(".button.save-grid-changes").first().click(),a.call()}),$(".button.leave-not-saving").click(function(){return a.call()})):a.call()},$(function(){return window.is_grid_changed=!1,$("#fileupload").fileupload(),$("#fileupload").fileupload("option",{maxFileSize:5e6,acceptFileTypes:/(\.|\/)(gif|jpe?g|png)$/i,previewMaxWidth:180,previewMaxHeight:180,displayNumber:page_size,add:function(a,b){return b.context=c(b.files[0]),$("#mask").modal(),b.submit()},done:function(a,b){return $(b.context).replaceWith(b.result.item),$(".pagination-panel").each(function(a,c){return c.innerHTML=b.result.pagination}),$(".pagination-panel").find(".pagination").length>0&&$("#images-panel").children().last().remove(),$("#gallery_selector_id")[0].innerHTML=b.result.gallery_options,$.modal.close()},progress:function(a,b){var c,d;c=parseInt(b.loaded/b.total*100,10).toString()+"%";if(b.context)return d=function(){return $(b.context).find(".progress .uploading").css("width","80%")},window.setTimeout(d,300)}}),$(".button.save-grid-changes").click(function(){var a,b;return a=[],b=$("#images-panel .edit-template"),b.each(function(b,c){var d;return d=$(c),a.push({id:d.attr("data-id"),name:d.find("#image_name").val(),gallery_id:d.find("#image_gallery_id").val(),price:d.find("#image_price").val(),description:d.find("#image_description").val(),is_album_cover:d.find(".album-cover").is(":checked"),is_avatar:d.find(".user-avatar").is(":checked"),keyword:d.find("#image_key_words").val()})}),$("#mask").modal(),$.ajax({url:"/images/update_images",type:"POST",data:{images:$.toJSON(a),gallery_id:$("#gallery_selector_id").val()},dataType:"json",success:function(a){return $("#images-panel")[0].innerHTML=a.items,$(".pagination-panel").each(function(b,c){return c.innerHTML=a.pagination}),alert("Update successfully!"),window.is_grid_changed=!1,$.modal.close()}})}),$("#images-panel").delegate(".edit-template .album-cover","click",function(a){var b;return b=$("#images-panel .edit-template .album-cover").not(a.target),b.attr("checked",!1)}),$("#images-panel").delegate(".edit-template .user-avatar","click",function(a){var b;return b=$("#images-panel .edit-template .user-avatar").not(a.target),b.attr("checked",!1)}),$("#images-panel").delegate(".button.delete-photo","click",function(a){return b(a.target)}),$("#edit-gallery").click(function(){return $("#edit-gallery-popup").modal()}),$("body").delegate("#btn-gallery-save","click",function(a){return $.ajax({url:$("#frm-edit-gallery").attr("action"),type:"POST",data:$("#frm-edit-gallery").serialize(),dataType:"json",success:function(a){return a.success?(alert("Your gallery has been updated!"),$.modal.close(),$("#edit-gallery-popup").replaceWith(a.edit_popup),$("#gallery_selector_id")[0].innerHTML=a.gal_with_number_options,$(".edit-template #image_gallery_id").each(function(b,c){return c.innerHTML=a.gallery_options})):alert("Something went wrong!")}})}),$("#images-panel").delegate(".edit-template input","change",function(a){return window.is_grid_changed=!0}),$("#images-panel").delegate(".edit-template textarea","change",function(a){return window.is_grid_changed=!0}),$("#images-panel").delegate(".edit-template select","change",function(a){return window.is_grid_changed=!0}),$(".pagination-panel").delegate("a","click",function(b){return b.preventDefault(),a(function(){return window.location=$(b.target).attr("href")})}),$(".header-menu a").click(function(b){return b.preventDefault(),a(function(){return window.location=$(b.target).attr("href")})}),$("#my_links").unbind("change"),$("#my_links").bind("change",function(b){return a(function(){return window.location=$(b.target).val()})}),$("#gallery_selector_id").change(function(){return a(function(){return $.ajax({url:"edit_images",type:"GET",data:{gallery_id:$("#gallery_selector_id").val()},dataType:"json",success:function(a){return $("#images-panel")[0].innerHTML=a.items,$(".pagination-panel").each(function(b,c){return c.innerHTML=a.pagination}),$("#delete-gallery").attr("href",a.delete_url),$("#fileupload").attr("action",a.upload_url),$("#edit-gallery-popup").replaceWith(a.edit_popup),$.modal.close()}})})})})})).call(this);