/**
 * filtrr.js - Javascript Image Processing Library
 *
 * Copyright (C) 2011 Alex Michael
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 **/
/* The filtr object contains all the image processing functions,
  * and it is returned as a parameter to the callback passed in filtrr.
  */
var filtr=function(e){if(!e)throw"Canvas supplied to filtr was null or undefined.";var t=e,n=t.width,r=t.height,i=t.getContext("2d"),s=i.getImageData(0,0,n,r),o=function(e){return Math.min(255,Math.max(0,parseInt(e)))};this.duplicate=function(){return new filtr(t)},this.put=function(){i.putImageData(s,0,0)},this.canvas=function(){return t},this.getCurrentImageData=function(){return s},this.core={apply:function(e){var t=s.data,i=0,o=0;for(i=0;i<r;i++)for(o=0;o<n;o++){var u=i*n*4+o*4,a=e(t[u],t[u+1],t[u+2],t[u+3]);t[u]=a.r,t[u+1]=a.g,t[u+2]=a.b,t[u+3]=a.a}return this},convolve:function(e){if(!e)throw"Kernel was null in convolve function.";if(e.length===0)throw"Kernel length was 0 in convolve function.";var t=s;if(!i.createImageData)throw"createImageData is not supported.";var u=i.createImageData(t.width,t.height),a=u.data,f=s.data,l=parseInt(e.length/2),c=parseInt(e[0].length/2),p=0,d=0,v=0,m=0;for(p=0;p<r;p++)for(d=0;d<n;d++){var g=p*n*4+d*4,y=0,b=0,E=0;for(v=-l;v<=l;v++)for(m=-c;m<=c;m++)if(p+v>=0&&p+v<r&&d+m>=0&&d+m<n){var S=e[v+l][m+c];if(S===0)continue;var x=(p+v)*n*4+(d+m)*4;y+=f[x]*S,b+=f[x+1]*S,E+=f[x+2]*S}a[g]=o(y),a[g+1]=o(b),a[g+2]=o(E),a[g+3]=255}return u},edgeDetection:function(e){var t=s,u=s.data,a=0,f=0,l=0;if(e.toLowerCase()==="simple"){if(!i.createImageData)throw"createImageData is not supported.";var c=i.createImageData(t.width,t.height),p=c.data;for(a=0;a<r;a++)for(f=1;f<n;f++){l=a*n*4+f*4;var d=a*n*4+(f-1)*4;p[l]=o(Math.abs(u[l]-u[d])),p[l+1]=o(Math.abs(u[l+1]-u[d+1])),p[l+2]=o(Math.abs(u[l+2]-u[d+2])),p[l+3]=255}s=c}else if(e.toLowerCase()==="sobel"){var v=this.convolve([[-1,-2,-1],[0,0,0],[1,2,1]]),m=this.convolve([[-1,0,1],[-2,0,2],[-1,0,1]]),g=v.data,y=m.data;for(a=0;a<r;a++)for(f=0;f<n;f++){l=a*n*4+f*4;var b=g[l],E=y[l],S=g[l+1],x=y[l+1],T=g[l+2],N=y[l+2];u[l]=Math.sqrt(b*b+E*E),u[l+1]=Math.sqrt(S*S+x*x),u[l+2]=Math.sqrt(T*T+N*N)}s=t}else e.toLowerCase()==="canny";return this},adjust:function(e,t,n){return this.apply(function(r,i,s,u){return{r:o(r*(1+e)),g:o(i*(1+t)),b:o(s*(1+n)),a:u}}),e=t=n=null,this},brightness:function(e){return this.apply(function(t,n,r,i){return{r:o(t+e),g:o(n+e),b:o(r+e),a:i}}),e=null,this},fill:function(e,t,n){return this.apply(function(r,i,s,u){return{r:o(e),g:o(t),b:o(n),a:u}}),rf=t=n=null,this},opacity:function(e){return this.apply(function(t,n,r,i){return{r:t,g:n,b:r,a:o(e*i)}}),e=null,this},saturation:function(e){return this.apply(function(t,n,r,i){var s=(t+n+r)/3;return{r:o(s+e*(t-s)),g:o(s+e*(n-s)),b:o(s+e*(r-s)),a:i}}),e=null,this},threshold:function(e){return this.apply(function(t,n,r,i){var s=255;if(t<e||n<e||r<e)s=0;return{r:s,g:s,b:s,a:i}}),e=null,this},posterize:function(e){var t=Math.floor(255/e);return this.apply(function(e,n,r,i){return{r:o(Math.floor(e/t)*t),g:o(Math.floor(n/t)*t),b:o(Math.floor(r/t)*t),a:i}}),t=null,e=null,this},gamma:function(e){return this.apply(function(t,n,r,i){return{r:o(Math.pow(t,e)),g:o(Math.pow(n,e)),b:o(Math.pow(r,e)),a:i}}),e=null,this},negative:function(){return this.apply(function(e,t,n,r){return{r:o(255-e),g:o(255-t),b:o(255-n),a:r}}),this},grayScale:function(){return this.apply(function(e,t,n,r){var i=(e+t+n)/3;return{r:o(i),g:o(i),b:o(i),a:r}}),this},bump:function(){return s=this.convolve([[-1,-1,0],[-1,1,1],[0,1,1]]),this},tint:function(e,t){return this.apply(function(n,r,i,s){return{r:o((n-e[0])*(255/(t[0]-e[0]))),g:o((r-e[1])*(255/(t[1]-e[1]))),b:o((i-e[2])*(255/(t[2]-e[2]))),a:s}}),e=t=null,this},mask:function(e,t,n){return this.apply(function(r,i,s,u){return{r:o(r&e),g:o(i&t),b:o(s&n),a:u}}),e=t=n=null,this},sepia:function(){return this.apply(function(e,t,n,r){return{r:o(e*.393+t*.769+n*.189),g:o(e*.349+t*.686+n*.168),b:o(e*.272+t*.534+n*.131),a:r}}),this},bias:function(e){function t(e,t){return e/((1/t-1.9)*(.9-e)+1)}return this.apply(function(n,r,i,s){return{r:o(n*t(n/255,e)),g:o(r*t(r/255,e)),b:o(i*t(i/255,e)),a:s}}),e=null,this},contrast:function(e){function t(e,t){return(e-.5)*t+.5}return this.apply(function(n,r,i,s){return{r:o(255*t(n/255,e)),g:o(255*t(r/255,e)),b:o(255*t(i/255,e)),a:s}}),e=null,this},blur:function(){return s=this.convolve([[1,2,1],[2,2,2],[1,2,1]]),this},sharpen:function(){return s=this.convolve([[0,-0.2,0],[-0.2,1.8,-0.2],[0,-0.2,0]]),this},gaussianBlur:function(){return s=this.convolve([[1/273,4/273,7/273,4/273,1/273],[4/273,16/273,26/273,16/273,4/273],[7/273,26/273,41/273,26/273,7/273],[4/273,16/273,26/273,16/273,4/273],[1/273,4/273,7/273,4/273,1/273]]),this}},this.blend={apply:function(e,t){var i=e.getCurrentImageData(),o=i.data,u=s.data,a=0,f=0;for(a=0;a<r;a++)for(f=0;f<n;f++){var l=a*n*4+f*4,c=t({r:o[l],g:o[l+1],b:o[l+2],a:o[l+3]},{r:u[l],g:u[l+1],b:u[l+2],a:u[l+3]});u[l]=c.r,u[l+1]=c.g,u[l+2]=c.b,u[l+3]=c.a}},multiply:function(e){return this.apply(e,function(e,t){return{r:o(e.r*t.r/255),g:o(e.g*t.g/255),b:o(e.b*t.b/255),a:t.a}}),this},screen:function(e){return this.apply(e,function(e,t){return{r:o(255-(255-e.r)*(255-t.r)/255),g:o(255-(255-e.g)*(255-t.g)/255),b:o(255-(255-e.b)*(255-t.b)/255),a:t.a}}),this},overlay:function(e){function t(e,t){return e>128?255-2*(255-t)*(255-e)/255:e*t*2/255}return this.apply(e,function(e,n){return{r:o(t(n.r,e.r)),g:o(t(n.g,e.g)),b:o(t(n.b,e.b)),a:n.a}}),this},difference:function(e){return this.apply(e,function(e,t){return{r:o(Math.abs(e.r-t.r)),g:o(Math.abs(e.g-t.g)),b:o(Math.abs(e.b-t.b)),a:t.a}}),this},addition:function(e){return this.apply(e,function(e,t){return{r:o(e.r+t.r),g:o(e.g+t.g),b:o(e.b+t.b),a:t.a}}),this},exclusion:function(e){return this.apply(e,function(e,t){return{r:o(128-2*(t.r-128)*(e.r-128)/255),g:o(128-2*(t.g-128)*(e.g-128)/255),b:o(128-2*(t.b-128)*(e.b-128)/255),a:t.a}}),this},softLight:function(e){function t(e,t){return e>128?255-(255-e)*(255-(t-128))/255:e*(t+128)/255}return this.apply(e,function(e,n){return{r:o(t(n.r,e.r)),g:o(t(n.g,e.g)),b:o(t(n.b,e.b)),a:n.a}}),this}}},filtrr=new function(){var e=function(e){return typeof e=="string"||!isNaN(e)||e.substring},t=function(e){var t=0,n=0;if(e.offsetParent)for(;;){n+=e.offsetTop,t+=e.offsetLeft;if(!e.offsetParent)break;e=e.offsetParent}else e.x&&(t+=e.x),e.y&&(n+=e.y);return{top:n,left:t}};this.img=function(n,r){var i=e(n)?document.getElementById(n):n;if(!i)throw"Could not find image element with id: "+id;var s=new Image;s.onload=function(){var e=document.createElement("canvas");e.width=s.width,e.height=s.height,e.getContext("2d").drawImage(s,0,0);var n=t(i),o=t(i.offsetParent),u=$(i).parent();u.size()>0&&(u[0].appendChild(e),i.style.display="none"),s=null,i=null,r(new filtr(e))},s.src=i.getAttribute("src")},this.canvas=function(t,n){var r=e(t)?document.getElementById(t):t;if(!r)throw"Could not find element with id: "+id;n(new filtr(r))}};