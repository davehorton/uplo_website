(function(e){var t=function(e,n){var r=/[^\-\w]/.test(e)?new Function(t.arg,("var _s=''"+t.helper+";_s+='"+e.replace(t.regexp,t.func)+"';return _s;").split("_s+='';").join("")):t.cache[e]=t.cache[e]||t(t.load(e));return r.tmpl=r.tmpl||t,n?r(n):r};t.cache={},t.load=function(e){return document.getElementById(e).innerHTML},t.regexp=/(\s+)|('|\\)(?![^%]*%\})|(?:\{%(=|#)(.+?)%\})|(\{%)|(%\})/g,t.func=function(e,t,n,r,i,s,o,u,a){if(t)return u&&u+e.length!==a.length?" ":"";if(n)return"\\"+e;if(r)return"="===r?"'+_e("+i+")+'":"'+("+i+"||'')+'";if(s)return"';";if(o)return"_s+='"},t.encReg=/[<>&"\x00]/g,t.encMap={"<":"&lt;",">":"&gt;","&":"&amp;",'"':"&quot;","\0":""},t.encode=function(e){return(""+(e||"")).replace(t.encReg,function(e){return t.encMap[e]})},t.arg="o",t.helper=",_t=arguments.callee.tmpl,_e=_t.encode,print=function(s,e){_s+=e&&(s||'')||_e(s);},include=function(s,d){_s+=_t(s,d);}","function"==typeof define&&define.amd?define("tmpl",function(){return t}):e.tmpl=t})(this);