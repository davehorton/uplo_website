/*! Copyright (c) 2010 Brandon Aaron (http://brandonaaron.net)
 * Dual licensed under the MIT (MIT_LICENSE.txt)
 * and GPL Version 2 (GPL_LICENSE.txt) licenses.
 *
 * Version: 1.1.1
 * Requires jQuery 1.3+
 * Docs: http://docs.jquery.com/Plugins/livequery
 */
(function(a){a.extend(a.fn,{livequery:function(b,c,d){var e=this,f;return a.isFunction(b)&&(d=c,c=b,b=undefined),a.each(a.livequery.queries,function(a,g){if(e.selector==g.selector&&e.context==g.context&&b==g.type&&(!c||c.$lqguid==g.fn.$lqguid)&&(!d||d.$lqguid==g.fn2.$lqguid))return(f=g)&&!1}),f=f||new a.livequery(this.selector,this.context,b,c,d),f.stopped=!1,f.run(),this},expire:function(b,c,d){var e=this;return a.isFunction(b)&&(d=c,c=b,b=undefined),a.each(a.livequery.queries,function(f,g){e.selector==g.selector&&e.context==g.context&&(!b||b==g.type)&&(!c||c.$lqguid==g.fn.$lqguid)&&(!d||d.$lqguid==g.fn2.$lqguid)&&!this.stopped&&a.livequery.stop(g.id)}),this}}),a.livequery=function(b,c,d,e,f){return this.selector=b,this.context=c,this.type=d,this.fn=e,this.fn2=f,this.elements=[],this.stopped=!1,this.id=a.livequery.queries.push(this)-1,e.$lqguid=e.$lqguid||a.livequery.guid++,f&&(f.$lqguid=f.$lqguid||a.livequery.guid++),this},a.livequery.prototype={stop:function(){var a=this;this.type?this.elements.unbind(this.type,this.fn):this.fn2&&this.elements.each(function(b,c){a.fn2.apply(c)}),this.elements=[],this.stopped=!0},run:function(){if(this.stopped)return;var b=this,c=this.elements,d=a(this.selector,this.context),e=d.not(c);this.elements=d,this.type?(e.bind(this.type,this.fn),c.length>0&&a.each(c,function(c,e){a.inArray(e,d)<0&&a.event.remove(e,b.type,b.fn)})):(e.each(function(){b.fn.apply(this)}),this.fn2&&c.length>0&&a.each(c,function(c,e){a.inArray(e,d)<0&&b.fn2.apply(e)}))}},a.extend(a.livequery,{guid:0,queries:[],queue:[],running:!1,timeout:null,checkQueue:function(){if(a.livequery.running&&a.livequery.queue.length){var b=a.livequery.queue.length;while(b--)a.livequery.queries[a.livequery.queue.shift()].run()}},pause:function(){a.livequery.running=!1},play:function(){a.livequery.running=!0,a.livequery.run()},registerPlugin:function(){a.each(arguments,function(b,c){if(!a.fn[c])return;var d=a.fn[c];a.fn[c]=function(){var b=d.apply(this,arguments);return a.livequery.run(),b}})},run:function(b){b!=undefined?a.inArray(b,a.livequery.queue)<0&&a.livequery.queue.push(b):a.each(a.livequery.queries,function(b){a.inArray(b,a.livequery.queue)<0&&a.livequery.queue.push(b)}),a.livequery.timeout&&clearTimeout(a.livequery.timeout),a.livequery.timeout=setTimeout(a.livequery.checkQueue,20)},stop:function(b){b!=undefined?a.livequery.queries[b].stop():a.each(a.livequery.queries,function(b){a.livequery.queries[b].stop()})}}),a.livequery.registerPlugin("append","prepend","after","before","wrap","attr","removeAttr","addClass","removeClass","toggleClass","empty","remove","html"),a(function(){a.livequery.play()})})(jQuery)