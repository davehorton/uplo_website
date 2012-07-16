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
(function(a){a.i18n={dict:null,setDictionary:function(a){this.dict=a},_:function(a,b){var c=a;return this.dict&&this.dict[a]&&(c=this.dict[a]),this.printf(c,b)},toEntity:function(a){var b="";for(var c=0;c<a.length;c++)a.charCodeAt(c)>128?b+="&#"+a.charCodeAt(c)+";":b+=a.charAt(c);return b},stripStr:function(a){return a.replace(/^\s*/,"").replace(/\s*$/,"")},stripStrML:function(a){var b=a.split("\n");for(var c=0;c<b.length;c++)b[c]=stripStr(b[c]);return stripStr(b.join(" "))},printf:function(a,b){if(!b)return a;var c="",d=a.split("%s");for(var e=0;e<b.length;e++)d[e].lastIndexOf("%")==d[e].length-1&&e!=b.length-1&&(d[e]+="s"+d.splice(e+1,1)[0]),c+=d[e]+b[e];return c+d[d.length-1]}}})(jQuery);