(function(){var e,t;e=/^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$/,window.CARD_TYPE_VALIDATORS=[{value:"USA_express",reg:/^3[47][0-9]{13}$/},{value:"discover",reg:/^6(?:011|5[0-9]{2})[0-9]{12}$/},{value:"visa",reg:/^4[0-9]{12}(?:[0-9]{3})?$/},{value:"jcb",reg:/^(?:2131|1800|35\d{3})\d{11}$/},{value:"dinners_club",reg:/^3(?:0[0-5]|[68][0-9])[0-9]{11}$/},{value:"master_card",reg:/^5[1-5][0-9]{14}$/}],t=function(e){var t,n,r;r=!1,n=$("#grand-total"),$.each(regions_tax,function(t,i){var s,o,u;if(e===i.state_code)return r=!0,u=0,s=0,o=parseFloat($("#shipping_fee").text().replace(/[$]/g,"")),$.each($("#order-summary .price"),function(e,t){var n,r,o;return r=$(t),n=parseFloat(r.text().replace(/[$]/g,"")),o=n*i.tax,u+=o,s+=o+n,r.closest(".block").find(".tax").text("$"+o.toFixed(2))}),s+=o,$("#order-summary .summary .tax").text("$"+u.toFixed(2)),n.text("$"+s.toFixed(2))});if(!r)return t=0,$.each($("#order-summary .price"),function(e,n){var r,i;return i=$(n),r=parseFloat(i.text().replace(/[$]/g,"")),t+=r}),$("#order-summary .tax").text("--"),n.text("$"+t.toFixed(2))},$(function(){return $(".state").selectmenu({change:function(e,n){if(this.id!=="order_billing_address_attributes_state")return t(n.value);if($("#billing_ship_to_billing").is(":checked"))return t(n.value)}}),$("#card_card_number").change(function(){var e,t,n,r,i;e=$("#card_card_type").val();if(e==="")return helper.show_notification("Please choose card type!");i=[];for(n=0,r=CARD_TYPE_VALIDATORS.length;n<r;n++){t=CARD_TYPE_VALIDATORS[n];if(t.value===e){t.reg.test($(this).val())||helper.show_notification("Your card number does not match this card_type!");break}i.push(void 0)}return i}),$("#card_card_type").change(function(){var e,t,n,r,i;e=$("#card_card_number").val(),i=[];for(n=0,r=CARD_TYPE_VALIDATORS.length;n<r;n++){t=CARD_TYPE_VALIDATORS[n];if(t.value===$(this).val()){e!==""&&!t.reg.test(e)&&helper.show_notification("Your card number does not match this card_type!");break}i.push(void 0)}return i}),$("#cvv-explanation").click(function(e){var t,n,r;return t=$("#cvv-form"),n=e.clientX-155,r=e.clientY-t.height(),$("#cvv-form").modal({opacity:5,overlayClose:!0,position:[r,n]})}),$("#cvv-form .close").click(function(){return $.modal.close()}),$(".zip_input").keypress(function(e){var t,n,r;return r=/^\d{0,5}$/,e.charCode?(t=this.value.substring(0,this.selectionStart),n=this.value.substring(this.selectionEnd,this.value.length),r.test(t+String.fromCharCode(e.charCode)+n)):!0}),$("#shipping-address .edit a").click(function(){return $("#shipping-address .inputs").removeClass("hide").addClass("show"),$("#shipping-address .edit").removeClass("show").addClass("hide"),$("#billing_ship_to_billing").prop("checked",!1),$("#shipping-address .header .italic").removeClass("hide").addClass("show")}),$("#billing_ship_to_billing").change(function(){return $(this).is(":checked")?($("#shipping-address .inputs").removeClass("show").addClass("hide"),$("#shipping-address .header .italic").removeClass("show").addClass("hide"),$("#shipping-address .edit").removeClass("hide").addClass("show"),t($("#order_billing_address_attributes_state").val())):($("#shipping-address .inputs").removeClass("hide").addClass("show"),$("#shipping-address .header .italic").removeClass("hide").addClass("show"),$("#shipping-address .edit").removeClass("show").addClass("hide"),t($("#order_shipping_address_attributes_state").val()))}),$(".submit").click(function(){return $("#shipping-address .edit.hide").length===0&&$("#shipping-address .inputs").text(""),_gaq.push(["_trackEvent","UPLO Web / Check Out","Place Order","checkout",-1]),$("#order-shippings").submit()}),form_validation.setup($("form.simple_form .error"))})}).call(this);