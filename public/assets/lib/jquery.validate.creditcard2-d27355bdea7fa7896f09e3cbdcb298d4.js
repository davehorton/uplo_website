/*
* jQuery creditcard2 extension for the jQuery Validation plugin (http://plugins.jquery.com/project/validate).
* Ported from http://www.braemoor.co.uk/software/creditcard.shtml by John Gardner, with some enhancements.
*
* Author: Jack Killpatrick
* Copyright (c) 2010 iHwy, Inc.
*
* Version 1.0.1 (1/12/2010)
* Tested with jquery 1.2.6, but will probably work with earlier versions.
*
* History:
* 1.0.0 - released 2008-11-17
* 1.0.1 - released 2010-01-12 -> updated card prefixes based on data at: http://en.wikipedia.org/wiki/Credit_card_number and added support for LaserCard
*
* Visit http://www.ihwy.com/labs/jquery-validate-credit-card-extension.aspx for usage information
*
* Dual licensed under the MIT and GPL licenses:
*   http://www.opensource.org/licenses/mit-license.php
*   http://www.gnu.org/licenses/gpl.html
*/
jQuery.validator.addMethod("creditcard2",function(a,b,c){var d=c,e=new Array;e[0]={cardName:"Visa",lengths:"13,16",prefixes:"4",checkdigit:!0},e[1]={cardName:"MasterCard",lengths:"16",prefixes:"51,52,53,54,55",checkdigit:!0},e[2]={cardName:"DinersClub",lengths:"14,16",prefixes:"305,36,38,54,55",checkdigit:!0},e[3]={cardName:"CarteBlanche",lengths:"14",prefixes:"300,301,302,303,304,305",checkdigit:!0},e[4]={cardName:"AmEx",lengths:"15",prefixes:"34,37",checkdigit:!0},e[5]={cardName:"Discover",lengths:"16",prefixes:"6011,622,64,65",checkdigit:!0},e[6]={cardName:"JCB",lengths:"16",prefixes:"35",checkdigit:!0},e[7]={cardName:"enRoute",lengths:"15",prefixes:"2014,2149",checkdigit:!0},e[8]={cardName:"Solo",lengths:"16,18,19",prefixes:"6334, 6767",checkdigit:!0},e[9]={cardName:"Switch",lengths:"16,18,19",prefixes:"4903,4905,4911,4936,564182,633110,6333,6759",checkdigit:!0},e[10]={cardName:"Maestro",lengths:"12,13,14,15,16,18,19",prefixes:"5018,5020,5038,6304,6759,6761",checkdigit:!0},e[11]={cardName:"VisaElectron",lengths:"16",prefixes:"417500,4917,4913,4508,4844",checkdigit:!0},e[12]={cardName:"LaserCard",lengths:"16,17,18,19",prefixes:"6304,6706,6771,6709",checkdigit:!0};var f=-1;for(var g=0;g<e.length;g++)if(d.toLowerCase()==e[g].cardName.toLowerCase()){f=g;break}if(f==-1)return!1;a=a.replace(/[\s-]/g,"");if(a.length==0)return!1;var h=a,i=/^[0-9]{13,19}$/;if(!i.exec(h))return!1;h=h.replace(/\D/g,"");if(e[f].checkdigit){var j=0,k="",l=1,m;for(g=h.length-1;g>=0;g--)m=Number(h.charAt(g))*l,m>9&&(j+=1,m-=10),j+=m,l==1?l=2:l=1;if(j%10!=0)return!1}var n=!1,o=!1,p=new Array,q=new Array;p=e[f].prefixes.split(",");for(g=0;g<p.length;g++){var r=new RegExp("^"+p[g]);r.test(h)&&(o=!0)}if(!o)return!1;q=e[f].lengths.split(",");for(l=0;l<q.length;l++)h.length==q[l]&&(n=!0);return n?!0:!1},jQuery.validator.messages.creditcard);