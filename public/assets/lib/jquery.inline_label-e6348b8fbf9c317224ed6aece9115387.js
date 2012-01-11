/**
 * Inline label v1.2.0
 * Tested with jQuery 1.3.x and 1.4.x.
 * Released under CC-BY-SA http://creativecommons.org/licenses/by-sa/2.5/se/
 * 
 * Usage: 	$('#id').inline_label();
 * 			$('#id').inline_label({text: "yada yada"}); // use text instead of label text
 * 			$('#id').inline_label({use_title: true}); // use the title instead of label text
 * 			$('#id').inline_label({css_class: "my_inline_label"}); // which css-class the field should use
 * 			$('#id').inline_label({hide_label: false}); // whether to hide the label or not
 * 
 * When using the text option, hide_label makes no difference.
 * 
 * Customized by Man Vuong - man.vuong@techpropulsionlabs.com
 * Reason of changes: not set the textbox value, use a <label> element instead.
 * 
 */
(function(a){a.inline_label=function(b,c){var d=a(b),e,f;if(c.text)e=c.text;else if(c.use_title)e=d.attr("title"),f=a("<label></label>"),f.text(e),d.parent().append(f);else{if(!d.attr("id"))throw"No id attribute found!";f=a("label[for="+d.attr("id")+"]");if(f.length==0)throw"No label for "+d.attr("id")+"!";if(f.length>1)throw"Too many labels for "+d.attr("id")+"!";e=f.text(),c.hide_label&&f.hide()}f.addClass(c.css_class);var g=d.offset();f.offset(g),f.click(function(){d.focus()}),d.keypress(function(){return f.hide(),d}),d.blur(function(){return d.val()==""?f.show():f.hide(),d}),d.change(function(){return d.val()==""?f.show():f.hide(),d}),d.triggerHandler("change")},a.inline_label.version=1.2,a.inline_label.defaults={text:!1,use_title:!1,css_class:"inline_label",hide_label:!0},a.fn.inline_label=function(b){return b=a.extend({},a.inline_label.defaults,b||{}),this.each(function(){new a.inline_label(this,b)})}})(jQuery)