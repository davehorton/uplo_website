/**
 * @preserve Galleria Flickr Plugin 2011-08-01
 * http://galleria.aino.se
 *
 * Copyright 2011, Aino
 * Licensed under the MIT license.
 */
/*global jQuery, Galleria, window */
Galleria.requires(1.25,"The Flickr Plugin requires Galleria version 1.2.5 or later."),function(e){var t=Galleria.utils.getScriptPath();Galleria.Flickr=function(e){this.api_key=e||"2a2ce06c15780ebeb0b706650fc890b2",this.options={max:30,imageSize:"medium",thumbSize:"thumb",sort:"interestingness-desc",description:!1,complete:function(){},backlink:!1}},Galleria.Flickr.prototype={constructor:Galleria.Flickr,search:function(e,t){return this._find({text:e},t)},tags:function(e,t){return this._find({tags:e},t)},user:function(e,t){return this._call({method:"flickr.urls.lookupUser",url:"flickr.com/photos/"+e},function(e){this._find({user_id:e.user.id,method:"flickr.people.getPublicPhotos"},t)})},set:function(e,t){return this._find({photoset_id:e,method:"flickr.photosets.getPhotos"},t)},gallery:function(e,t){return this._find({gallery_id:e,method:"flickr.galleries.getPhotos"},t)},groupsearch:function(e,t){return this._call({text:e,method:"flickr.groups.search"},function(e){this.group(e.groups.group[0].nsid,t)})},group:function(e,t){return this._find({group_id:e,method:"flickr.groups.pools.getPhotos"},t)},setOptions:function(t){return e.extend(this.options,t),this},_call:function(t,n){var r="http://api.flickr.com/services/rest/?",i=this;return t=e.extend({format:"json",jsoncallback:"?",api_key:this.api_key},t),e.each(t,function(e,t){r+="&"+e+"="+t}),e.getJSON(r,function(e){e.stat==="ok"?n.call(i,e):Galleria.raise(e.code.toString()+" "+e.stat+": "+e.message,!0)}),i},_getBig:function(e){return e.url_l?e.url_l:parseInt(e.width_o,10)>1280?"http://farm"+e.farm+".static.flickr.com/"+e.server+"/"+e.id+"_"+e.secret+"_b.jpg":e.url_o||e.url_z||e.url_m},_getSize:function(e,t){var n;switch(t){case"thumb":n=e.url_t;break;case"small":n=e.url_s;break;case"big":n=this._getBig(e);break;case"original":n=e.url_o?e.url_o:this._getBig(e);break;default:n=e.url_z||e.url_m}return n},_find:function(t,n){return t=e.extend({method:"flickr.photos.search",extras:"url_t,url_m,url_o,url_s,url_l,url_z,description",sort:this.options.sort},t),this._call(t,function(e){var t=[],r=e.photos?e.photos.photo:e.photoset.photo,i=Math.min(this.options.max,r.length),s,o;for(o=0;o<i;o++)s=r[o],t.push({thumb:this._getSize(s,this.options.thumbSize),image:this._getSize(s,this.options.imageSize),big:this._getBig(s),title:r[o].title,description:this.options.description&&r[o].description?r[o].description._content:"",link:this.options.backlink?"http://flickr.com/photos/"+s.owner+"/"+s.id:""});n.call(this,t)})}};var n=Galleria.prototype.load;Galleria.prototype.load=function(){if(arguments.length||typeof this._options.flickr!="string"){n.apply(this,Galleria.utils.array(arguments));return}var r=this,i=Galleria.utils.array(arguments),s=this._options.flickr.split(":"),o,u=e.extend({},r._options.flickrOptions),a=typeof u.loader!="undefined"?u.loader:e("<div>").css({width:48,height:48,opacity:.7,background:"#000 url("+t+"loader.gif) no-repeat 50% 50%"});if(s.length){if(typeof Galleria.Flickr.prototype[s[0]]!="function")return Galleria.raise(s[0]+" method not found in Flickr plugin"),n.apply(this,i);if(!s[1])return Galleria.raise("No flickr argument found"),n.apply(this,i);window.setTimeout(function(){r.$("target").append(a)},100),o=new Galleria.Flickr,typeof r._options.flickrOptions=="object"&&o.setOptions(r._options.flickrOptions),o[s[0]](s[1],function(e){r._data=e,a.remove(),r.trigger(Galleria.DATA),o.options.complete.call(o,e)})}else n.apply(this,i)}}(jQuery);