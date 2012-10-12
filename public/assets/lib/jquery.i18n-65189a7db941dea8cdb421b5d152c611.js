/*
 * jQuery i18n plugin
 * @requires jQuery v1.1 or later
 *
 * Examples at: http://recurser.com/articles/2008/02/21/jquery-i18n-translation-plugin/
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 *
 * Based on 'javascript i18n that almost doesn't suck' by markos
 * http://markos.gaivo.net/blog/?p=100
 *
 * Revision: $Id$
 * Version: 1.0.0  Feb-10-2008
 */
(function(e){e.i18n={dict:null,setDictionary:function(e){this.dict=e},_:function(e,t){var n=e;return this.dict&&this.dict[e]&&(n=this.dict[e]),this.printf(n,t)},toEntity:function(e){var t="";for(var n=0;n<e.length;n++)e.charCodeAt(n)>128?t+="&#"+e.charCodeAt(n)+";":t+=e.charAt(n);return t},stripStr:function(e){return e.replace(/^\s*/,"").replace(/\s*$/,"")},stripStrML:function(e){var t=e.split("\n");for(var n=0;n<t.length;n++)t[n]=stripStr(t[n]);return stripStr(t.join(" "))},printf:function(e,t){if(!t)return e;var n="",r=e.split("%s");for(var i=0;i<t.length;i++)r[i].lastIndexOf("%")==r[i].length-1&&i!=t.length-1&&(r[i]+="s"+r.splice(i+1,1)[0]),n+=r[i]+t[i];return n+r[r.length-1]}}})(jQuery);