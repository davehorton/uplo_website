((function(){var a;a=function(){var a,b,c,d,e;return e=$("#line_item_size").val(),b=$("#line_item_moulding").val(),d=$("#line_item_quantity").val(),c=pricing[e]*d,a=c*moulding_discount[b],$("#discount .number").text("- $"+a.toFixed(2)),$("#total .number").text("$"+(c-a).toFixed(2))},$(function(){return a(),$("#line_item_size").selectmenu({style:"dropdown",change:function(b,c){return a()}}),$("#line_item_moulding").selectmenu({style:"dropdown",change:function(b,c){return a()}}),$(".add-to-cart").click(function(){return $("#order-details").submit()}),$("#line_item_quantity").keypress(function(a){var b,c;b=/^\d{1,5}$/;if(a.charCode!==0){c=a.currentTarget.value+String.fromCharCode(a.charCode);if(!b.test(c))return!1}}),$("#line_item_quantity").keyup(function(){return a()})})})).call(this);