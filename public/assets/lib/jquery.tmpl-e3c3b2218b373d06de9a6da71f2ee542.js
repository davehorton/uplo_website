(function(a){function l(b,c,d,g){var h={data:g||(c?c.data:{}),_wrap:c?c._wrap:null,tmpl:null,parent:c||null,nodes:[],calls:t,nest:u,wrap:v,html:w,update:x};return b&&a.extend(h,b,{nodes:[],parent:c}),d&&(h.tmpl=d,h._ctnt=h._ctnt||h.tmpl(a,h),h.key=++i,(k.length?f:e)[i]=h),h}function m(b,d,e){var f,g=e?a.map(e,function(a){return typeof a=="string"?b.key?a.replace(/(<\w+)(?=[\s>])(?![^>]*_tmplitem)([^>]*)/g,"$1 "+c+'="'+b.key+'" $2'):a:m(a,b,a._ctnt)}):b;return d?g:(g=g.join(""),g.replace(/^\s*([^<\s][^<]*)?(<[\w\W]+>)([^>]*[^>\s])?\s*$/,function(b,c,d,e){f=a(d).get(),s(f),c&&(f=n(c).concat(f)),e&&(f=f.concat(n(e)))}),f?f:n(g))}function n(b){var c=document.createElement("div");return c.innerHTML=b,a.makeArray(c.childNodes)}function o(b){return new Function("jQuery","$item","var $=jQuery,call,_=[],$data=$item.data;with($data){_.push('"+a.trim(b).replace(/([\\'])/g,"\\$1").replace(/[\r\t\n]/g," ").replace(/\$\{([^\}]*)\}/g,"{{= $1}}").replace(/\{\{(\/?)(\w+|.)(?:\(((?:[^\}]|\}(?!\}))*?)?\))?(?:\s+(.*?)?)?(\(((?:[^\}]|\}(?!\}))*?)\))?\s*\}\}/g,function(b,c,d,e,f,g,h){var i=a.tmpl.tag[d],j,k,l;if(!i)throw"Template command not found: "+d;return j=i._default||[],g&&!/\w$/.test(f)&&(f+=g,g=""),f?(f=q(f),h=h?","+q(h)+")":g?")":"",k=g?f.indexOf(".")>-1?f+g:"("+f+").call($item"+h:f,l=g?k:"(typeof("+f+")==='function'?("+f+").call($item):("+f+"))"):l=k=j.$1||"null",e=q(e),"');"+i[c?"close":"open"].split("$notnull_1").join(f?"typeof("+f+")!=='undefined' && ("+f+")!=null":"true").split("$1a").join(l).split("$1").join(k).split("$2").join(e?e.replace(/\s*([^\(]+)\s*(\((.*?)\))?/g,function(a,b,c,d){return d=d?","+d+")":c?")":"",d?"("+b+").call($item"+d:a}):j.$2||"")+"_.push('"})+"');}return _;")}function p(b,c){b._wrap=m(b,!0,a.isArray(c)?c:[d.test(c)?c:a(c).html()]).join("")}function q(a){return a?a.replace(/\\'/g,"'").replace(/\\\\/g,"\\"):null}function r(a){var b=document.createElement("div");return b.appendChild(a.cloneNode(!0)),b.innerHTML}function s(b){function p(b){function p(a){a+=d,n=k[a]=k[a]||l(n,e[n.parent.key+d]||n.parent,null,!0)}var g,h=b,m,n,o;if(o=b.getAttribute(c)){while(h.parentNode&&(h=h.parentNode).nodeType===1&&!(g=h.getAttribute(c)));g!==o&&(h=h.parentNode?h.nodeType===11?0:h.getAttribute(c)||0:0,(n=e[o])||(n=f[o],n=l(n,e[h]||f[h],null,!0),n.key=++i,e[i]=n),j&&p(o)),b.removeAttribute(c)}else j&&(n=a.data(b,"tmplItem"))&&(p(n.key),e[n.key]=n,h=a.data(b.parentNode,"tmplItem"),h=h?h.key:0);if(n){m=n;while(m&&m.key!=h)m.nodes.push(b),m=m.parent;delete n._ctnt,delete n._wrap,a.data(b,"tmplItem",n)}}var d="_"+j,g,h,k={},m,n,o;for(m=0,n=b.length;m<n;m++){if((g=b[m]).nodeType!==1)continue;h=g.getElementsByTagName("*");for(o=h.length-1;o>=0;o--)p(h[o]);p(g)}}function t(a,b,c,d){if(!a)return k.pop();k.push({_:a,tmpl:b,item:this,data:c,options:d})}function u(b,c,d){return a.tmpl(a.template(b),c,d,this)}function v(b,c){var d=b.options||{};return d.wrapped=c,a.tmpl(a.template(b.tmpl),b.data,d,b.item)}function w(b,c){var d=this._wrap;return a.map(a(a.isArray(d)?d.join(""):d).filter(b||"*"),function(a){return c?a.innerText||a.textContent:a.outerHTML||r(a)})}function x(){var b=this.nodes;a.tmpl(null,null,null,this).insertBefore(b[0]),a(b).remove()}var b=a.fn.domManip,c="_tmplitem",d=/^[^<]*(<[\w\W]+>)[^>]*$|\{\{\! /,e={},f={},g,h={key:0,data:{}},i=0,j=0,k=[];a.each({appendTo:"append",prependTo:"prepend",insertBefore:"before",insertAfter:"after",replaceAll:"replaceWith"},function(b,c){a.fn[b]=function(d){var f=[],h=a(d),i,k,l,m,n=this.length===1&&this[0].parentNode;g=e||{};if(n&&n.nodeType===11&&n.childNodes.length===1&&h.length===1)h[c](this[0]),f=this;else{for(k=0,l=h.length;k<l;k++)j=k,i=(k>0?this.clone(!0):this).get(),a.fn[c].apply(a(h[k]),i),f=f.concat(i);j=0,f=this.pushStack(f,b,h.selector)}return m=g,g=null,a.tmpl.complete(m),f}}),a.fn.extend({tmpl:function(b,c,d){return a.tmpl(this[0],b,c,d)},tmplItem:function(){return a.tmplItem(this[0])},template:function(b){return a.template(b,this[0])},domManip:function(c,d,f){if(c[0]&&c[0].nodeType){var h=a.makeArray(arguments),i=c.length,k=0,l;while(k<i&&!(l=a.data(c[k++],"tmplItem")));i>1&&(h[0]=[a.makeArray(c)]),l&&j&&(h[2]=function(b){a.tmpl.afterManip(this,b,f)}),b.apply(this,h)}else b.apply(this,arguments);return j=0,!g&&a.tmpl.complete(e),this}}),a.extend({tmpl:function(b,c,d,g){var i,j=!g;if(j)g=h,b=a.template[b]||a.template(null,b),f={};else if(!b)return b=g.tmpl,e[g.key]=g,g.nodes=[],g.wrapped&&p(g,g.wrapped),a(m(g,null,g.tmpl(a,g)));return b?(typeof c=="function"&&(c=c.call(g||{})),d&&d.wrapped&&p(d,d.wrapped),i=a.isArray(c)?a.map(c,function(a){return a?l(d,g,b,a):null}):[l(d,g,b,c)],j?a(m(g,null,i)):i):[]},tmplItem:function(b){var c;b instanceof a&&(b=b[0]);while(b&&b.nodeType===1&&!(c=a.data(b,"tmplItem"))&&(b=b.parentNode));return c||h},template:function(b,c){return c?(typeof c=="string"?c=o(c):c instanceof a&&(c=c[0]||{}),c.nodeType&&(c=a.data(c,"tmpl")||a.data(c,"tmpl",o(c.innerHTML))),typeof b=="string"?a.template[b]=c:c):b?typeof b!="string"?a.template(null,b):a.template[b]||a.template(null,d.test(b)?b:a(b)):null},encode:function(a){return(""+a).split("<").join("&lt;").split(">").join("&gt;").split('"').join("&#34;").split("'").join("&#39;")}}),a.extend(a.tmpl,{tag:{tmpl:{_default:{$2:"null"},open:"if($notnull_1){_=_.concat($item.nest($1,$2));}"},wrap:{_default:{$2:"null"},open:"$item.calls(_,$1,$2);_=[];",close:"call=$item.calls();_=call._.concat($item.wrap(call,_));"},each:{_default:{$2:"$index, $value"},open:"if($notnull_1){$.each($1a,function($2){with(this){",close:"}});}"},"if":{open:"if(($notnull_1) && $1a){",close:"}"},"else":{_default:{$1:"true"},open:"}else if(($notnull_1) && $1a){"},html:{open:"if($notnull_1){_.push($1a);}"},"=":{_default:{$1:"$data"},open:"if($notnull_1){_.push($.encode($1a));}"},"!":{open:""}},complete:function(){e={}},afterManip:function(b,c,d){var e=c.nodeType===11?a.makeArray(c.childNodes):c.nodeType===1?[c]:[];d.call(b,c),s(e),j++}})})(jQuery)