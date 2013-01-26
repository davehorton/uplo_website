/*
 * Superfish v1.4.8 - jQuery menu widget
 * Copyright (c) 2008 Joel Birch
 *
 * Dual licensed under the MIT and GPL licenses:
 * 	http://www.opensource.org/licenses/mit-license.php
 * 	http://www.gnu.org/licenses/gpl.html
 *
 * CHANGELOG: http://users.tpg.com.au/j_birch/plugins/superfish/changelog.txt
 */
(function(e){e.fn.superfish=function(t){var n=e.fn.superfish,r=n.c,i=e(['<span class="',r.arrowClass,'"> &#187;</span>'].join("")),s=function(){var t=e(this),n=u(t);clearTimeout(n.sfTimer),t.showSuperfishUl().siblings().hideSuperfishUl()},o=function(){var t=e(this),r=u(t),i=n.op;clearTimeout(r.sfTimer),r.sfTimer=setTimeout(function(){i.retainPath=e.inArray(t[0],i.$path)>-1,t.hideSuperfishUl(),i.$path.length&&t.parents(["li.",i.hoverClass].join("")).length<1&&s.call(i.$path)},i.delay)},u=function(e){return e=e.parents(["ul.",r.menuClass,":first"].join(""))[0],n.op=n.o[e.serial],e};return this.each(function(){var u=this.serial=n.o.length,f=e.extend({},n.defaults,t);f.$path=e("li."+f.pathClass,this).slice(0,f.pathLevels).each(function(){e(this).addClass([f.hoverClass,r.bcClass].join(" ")).filter("li:has(ul)").removeClass(f.pathClass)}),n.o[u]=n.op=f,e("li:has(ul)",this)[e.fn.hoverIntent&&!f.disableHI?"hoverIntent":"hover"](s,o).each(function(){f.autoArrows&&e(">a:first-child",this).addClass(r.anchorClass).append(i.clone())}).not("."+r.bcClass).hideSuperfishUl();var l=e("a",this);l.each(function(e){var t=l.eq(e).parents("li");l.eq(e).focus(function(){s.call(t)}).blur(function(){o.call(t)})}),f.onInit.call(this)}).each(function(){var t=[r.menuClass];n.op.dropShadows&&!(e.browser.msie&&e.browser.version<7)&&t.push(r.shadowClass),e(this).addClass(t.join(" "))})};var t=e.fn.superfish;t.o=[],t.op={},t.IE7fix=function(){var n=t.op;e.browser.msie&&e.browser.version>6&&n.dropShadows&&n.animation.opacity!=void 0&&this.toggleClass(t.c.shadowClass+"-off")},t.c={bcClass:"sf-breadcrumb",menuClass:"sf-js-enabled",anchorClass:"sf-with-ul",arrowClass:"sf-sub-indicator",shadowClass:"sf-shadow"},t.defaults={hoverClass:"sfHover",pathClass:"overideThisToUse",pathLevels:1,delay:800,animation:{opacity:"show"},speed:"normal",autoArrows:!0,dropShadows:!0,disableHI:!1,onInit:function(){},onBeforeShow:function(){},onShow:function(){},onHide:function(){}},e.fn.extend({hideSuperfishUl:function(){var n=t.op,r=n.retainPath===!0?n.$path:"";return n.retainPath=!1,r=e(["li.",n.hoverClass].join(""),this).add(this).not(r).removeClass(n.hoverClass).find(">ul").hide().css("visibility","hidden"),n.onHide.call(r),this},showSuperfishUl:function(){var e=t.op,n=this.addClass(e.hoverClass).find(">ul:hidden").css("visibility","visible");return t.IE7fix.call(n),e.onBeforeShow.call(n),n.animate(e.animation,e.speed,function(){t.IE7fix.call(n),e.onShow.call(n)}),this}})})(jQuery);