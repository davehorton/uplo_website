(function(){var e,t,n,r,i;e=function(){var e,t,n,r;return r=$("#line_item_size").val(),e=$("#line_item_moulding").val(),n=$("#line_item_quantity").val(),t=moulding_price[e][tier][r]*n,$("#total .number").text("$"+t.toFixed(2))},r=function(e){var t,n,r;return t=!1,n=$("#line_item_moulding"),r=n.find("option"),$.each(moulding_constrain,function(n,i){var s;s=!0,$.each(i,function(t,n){if(e.toString()===""||e.toString()===n.toString())return s=!1});if(s)return r=r.not("option[value!="+n+"]"),t=!0}),r.prop("disabled",t),n.selectmenu()},i=function(e){var t,n,r;return t=!1,r=$("#line_item_size"),n=r.find("option"),moulding_constrain[e]&&$.each(moulding_constrain[e],function(e,r){return n=n.not("option[value="+r+"]"),t=!0}),n.prop("disabled",t),r.selectmenu()},t=function(){var t,n;return t=$("#line_item_moulding"),n=t.find("option"),$.each(n,function(e,t){var n;return n=$(t),n.prop("disabled",moulding_pending[n.val()])}),t.selectmenu({style:"dropdown",change:function(t,n){return e()}})},n=function(){return $("#line_item_size").selectmenu({style:"dropdown",change:function(t,n){return e()}})},$(function(){return $("#preview-frame").on("contextmenu",function(){return alert("These photos are copyrighted by their respective owners. All rights reserved. Unauthorized use prohibited."),!1}),$(".add-to-cart").click(function(){return $("#order-details").submit()}),n(),t(),$("#line_item_quantity").keyup(function(){return e()}),$("#line_item_quantity").keypress(function(e){var t,n,r,i;return r=/^\d{1,2}$/,e.charCode?(t=this.value.substring(0,this.selectionStart),n=this.value.substring(this.selectionEnd,this.value.length),i=t+String.fromCharCode(e.charCode)+n,r.test(i)?parseInt(i)<=10:!1):!0}),order_preview.setup(),e()})}).call(this);