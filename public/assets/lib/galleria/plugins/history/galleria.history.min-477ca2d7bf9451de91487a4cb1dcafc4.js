/*
 Galleria History Plugin 2011-08-01
 http://galleria.aino.se

 Copyright 2011, Aino
 Licensed under the MIT license.

*/
Galleria.requires(1.25,"The History Plugin requires Galleria version 1.2.5 or later."),function(e,t){Galleria.History=function(){var n=[],r=!1,i=t.location,s=t.document,o=Galleria.IE,u="onhashchange"in t&&(s.mode===void 0||s.mode>7),a,f=function(e){return e=a&&!u&&Galleria.IE?e||a.location:i,parseInt(e.hash.substr(2),10)},l=f(i),h=[],p=function(){e.each(h,function(e,n){n.call(t,f())})},d=function(){e.each(n,function(e,t){t()}),r=!0};return u&&o<8&&(u=!1),u?d():e(function(){t.setInterval(function(){var e=f();!isNaN(e)&&e!=l&&(l=e,i.hash="/"+e,p())},50),o?e('<iframe tabindex="-1" title="empty">').hide().attr("src","about:blank").one("load",function(){a=this.contentWindow,d()}).insertAfter(s.body):d()}),{change:function(e){h.push(e),u&&(t.onhashchange=p)},set:function(e){isNaN(e)||(!u&&o&&this.ready(function(){var t=a.document;t.open(),t.close(),a.location.hash="/"+e}),i.hash="/"+e)},ready:function(e){r?e():n.push(e)}}}()}(jQuery,this);