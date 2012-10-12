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
(function(e){e.inline_label=function(t,n){var r=e(t),i,s;if(n.text)i=n.text;else if(n.use_title)i=r.attr("title"),s=e("<label></label>"),s.text(i),r.parent().append(s);else{if(!r.attr("id"))throw"No id attribute found!";s=e("label[for="+r.attr("id")+"]");if(s.length==0)throw"No label for "+r.attr("id")+"!";if(s.length>1)throw"Too many labels for "+r.attr("id")+"!";i=s.text(),n.hide_label&&s.hide()}s.addClass(n.css_class);var o=r.offset();s.offset(o),s.click(function(){r.focus()}),r.keypress(function(){return s.hide(),r}),r.blur(function(){return r.val()==""?s.show():s.hide(),r}),r.change(function(){return r.val()==""?s.show():s.hide(),r}),r.triggerHandler("change")},e.inline_label.version=1.2,e.inline_label.defaults={text:!1,use_title:!1,css_class:"inline_label",hide_label:!0},e.fn.inline_label=function(t){return t=e.extend({},e.inline_label.defaults,t||{}),this.each(function(){new e.inline_label(this,t)})}})(jQuery);