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
(function(a){a.fn.superfish=function(b){var c=a.fn.superfish,d=c.c,e=a(['<span class="',d.arrowClass,'"> &#187;</span>'].join("")),f=function(){var b=a(this),c=h(b);clearTimeout(c.sfTimer),b.showSuperfishUl().siblings().hideSuperfishUl()},g=function(){var b=a(this),d=h(b),e=c.op;clearTimeout(d.sfTimer),d.sfTimer=setTimeout(function(){e.retainPath=a.inArray(b[0],e.$path)>-1,b.hideSuperfishUl(),e.$path.length&&b.parents(["li.",e.hoverClass].join("")).length<1&&f.call(e.$path)},e.delay)},h=function(a){return a=a.parents(["ul.",d.menuClass,":first"].join(""))[0],c.op=c.o[a.serial],a};return this.each(function(){var h=this.serial=c.o.length,k=a.extend({},c.defaults,b);k.$path=a("li."+k.pathClass,this).slice(0,k.pathLevels).each(function(){a(this).addClass([k.hoverClass,d.bcClass].join(" ")).filter("li:has(ul)").removeClass(k.pathClass)}),c.o[h]=c.op=k,a("li:has(ul)",this)[a.fn.hoverIntent&&!k.disableHI?"hoverIntent":"hover"](f,g).each(function(){k.autoArrows&&a(">a:first-child",this).addClass(d.anchorClass).append(e.clone())}).not("."+d.bcClass).hideSuperfishUl();var l=a("a",this);l.each(function(a){var b=l.eq(a).parents("li");l.eq(a).focus(function(){f.call(b)}).blur(function(){g.call(b)})}),k.onInit.call(this)}).each(function(){var b=[d.menuClass];c.op.dropShadows&&!(a.browser.msie&&a.browser.version<7)&&b.push(d.shadowClass),a(this).addClass(b.join(" "))})};var b=a.fn.superfish;b.o=[],b.op={},b.IE7fix=function(){var c=b.op;a.browser.msie&&a.browser.version>6&&c.dropShadows&&c.animation.opacity!=void 0&&this.toggleClass(b.c.shadowClass+"-off")},b.c={bcClass:"sf-breadcrumb",menuClass:"sf-js-enabled",anchorClass:"sf-with-ul",arrowClass:"sf-sub-indicator",shadowClass:"sf-shadow"},b.defaults={hoverClass:"sfHover",pathClass:"overideThisToUse",pathLevels:1,delay:800,animation:{opacity:"show"},speed:"normal",autoArrows:!0,dropShadows:!0,disableHI:!1,onInit:function(){},onBeforeShow:function(){},onShow:function(){},onHide:function(){}},a.fn.extend({hideSuperfishUl:function(){var c=b.op,d=c.retainPath===!0?c.$path:"";return c.retainPath=!1,d=a(["li.",c.hoverClass].join(""),this).add(this).not(d).removeClass(c.hoverClass).find(">ul").hide().css("visibility","hidden"),c.onHide.call(d),this},showSuperfishUl:function(){var a=b.op,c=this.addClass(a.hoverClass).find(">ul:hidden").css("visibility","visible");return b.IE7fix.call(c),a.onBeforeShow.call(c),c.animate(a.animation,a.speed,function(){b.IE7fix.call(c),a.onShow.call(c)}),this}})})(jQuery)