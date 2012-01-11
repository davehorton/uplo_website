/**
 * @preserve Galleria Flickr Plugin 2011-08-01
 * http://galleria.aino.se
 *
 * Copyright 2011, Aino
 * Licensed under the MIT license.
 */
/*global jQuery, Galleria, window */
Galleria.requires(1.25,"The Flickr Plugin requires Galleria version 1.2.5 or later."),function(a){var b=Galleria.utils.getScriptPath();Galleria.Flickr=function(a){this.api_key=a||"2a2ce06c15780ebeb0b706650fc890b2",this.options={max:30,imageSize:"medium",thumbSize:"thumb",sort:"interestingness-desc",description:!1,complete:function(){},backlink:!1}},Galleria.Flickr.prototype={constructor:Galleria.Flickr,search:function(a,b){return this._find({text:a},b)},tags:function(a,b){return this._find({tags:a},b)},user:function(a,b){return this._call({method:"flickr.urls.lookupUser",url:"flickr.com/photos/"+a},function(a){this._find({user_id:a.user.id,method:"flickr.people.getPublicPhotos"},b)})},set:function(a,b){return this._find({photoset_id:a,method:"flickr.photosets.getPhotos"},b)},gallery:function(a,b){return this._find({gallery_id:a,method:"flickr.galleries.getPhotos"},b)},groupsearch:function(a,b){return this._call({text:a,method:"flickr.groups.search"},function(a){this.group(a.groups.group[0].nsid,b)})},group:function(a,b){return this._find({group_id:a,method:"flickr.groups.pools.getPhotos"},b)},setOptions:function(b){return a.extend(this.options,b),this},_call:function(b,c){var d="http://api.flickr.com/services/rest/?",e=this;return b=a.extend({format:"json",jsoncallback:"?",api_key:this.api_key},b),a.each(b,function(a,b){d+="&"+a+"="+b}),a.getJSON(d,function(a){a.stat==="ok"?c.call(e,a):Galleria.raise(a.code.toString()+" "+a.stat+": "+a.message,!0)}),e},_getBig:function(a){return a.url_l?a.url_l:parseInt(a.width_o,10)>1280?"http://farm"+a.farm+".static.flickr.com/"+a.server+"/"+a.id+"_"+a.secret+"_b.jpg":a.url_o||a.url_z||a.url_m},_getSize:function(a,b){var c;switch(b){case"thumb":c=a.url_t;break;case"small":c=a.url_s;break;case"big":c=this._getBig(a);break;case"original":c=a.url_o?a.url_o:this._getBig(a);break;default:c=a.url_z||a.url_m}return c},_find:function(b,c){return b=a.extend({method:"flickr.photos.search",extras:"url_t,url_m,url_o,url_s,url_l,url_z,description",sort:this.options.sort},b),this._call(b,function(a){var b=[],d=a.photos?a.photos.photo:a.photoset.photo,e=Math.min(this.options.max,d.length),f,g;for(g=0;g<e;g++)f=d[g],b.push({thumb:this._getSize(f,this.options.thumbSize),image:this._getSize(f,this.options.imageSize),big:this._getBig(f),title:d[g].title,description:this.options.description&&d[g].description?d[g].description._content:"",link:this.options.backlink?"http://flickr.com/photos/"+f.owner+"/"+f.id:""});c.call(this,b)})}};var c=Galleria.prototype.load;Galleria.prototype.load=function(){if(arguments.length||typeof this._options.flickr!="string"){c.apply(this,Galleria.utils.array(arguments));return}var d=this,e=Galleria.utils.array(arguments),f=this._options.flickr.split(":"),g,h=a.extend({},d._options.flickrOptions),i=typeof h.loader!="undefined"?h.loader:a("<div>").css({width:48,height:48,opacity:.7,background:"#000 url("+b+"loader.gif) no-repeat 50% 50%"});if(f.length){if(typeof Galleria.Flickr.prototype[f[0]]!="function")return Galleria.raise(f[0]+" method not found in Flickr plugin"),c.apply(this,e);if(!f[1])return Galleria.raise("No flickr argument found"),c.apply(this,e);window.setTimeout(function(){d.$("target").append(i)},100),g=new Galleria.Flickr,typeof d._options.flickrOptions=="object"&&g.setOptions(d._options.flickrOptions),g[f[0]](f[1],function(a){d._data=a,i.remove(),d.trigger(Galleria.DATA),g.options.complete.call(g,a)})}else c.apply(this,e)}}(jQuery)