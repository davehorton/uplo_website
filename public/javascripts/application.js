Array.prototype.remove = function(s) {
  var i = this.indexOf(s);
  if(i != -1) this.splice(i, 1);
}

/**
 * GLOBAL SETUP.
 */
/* $(document).ready(function(){
  //Modify the URL of the project tab.
  //TODO: this's just a trick to track the user's favourite project.
  if(user_preferences.project_id()){
    var project_url = $("#menu .project-tab a").attr("href");
    if(project_url){
      var new_url = user_preferences.modify_project_url(project_url);
      $("#menu .project-tab a").attr("href", new_url);
    }
    
    var billing_url = $(".sub-menu .accounting a").attr("href");
    if(billing_url){
      $(".sub-menu .accounting a").attr("href", billing_url);
    }
  }
}); */

global = {
  date_format: "mm/dd/yy",
  date_format_dev: "yy-mm-dd",
  status_show_error: 777
};

/**
 * Helper methods.
 */
helper = {
  create_message_panel: function (type, message){
    var divMsg = $("<div></div>");
    $(divMsg).attr("class", "box box-" + type);
    $(divMsg).text(message);
    return $(divMsg);
  },

  // Append a message panel to #flash element.
  flash_message: function (type, message, append, delay_time, container){
    var msg = helper.create_message_panel(type, message);
    
    if(!container)
      container = "#flash";
    if(append)
      $(container).append(msg);
    else
      $(container).html(msg);
    
    if(typeof(delay_time) != "undefined" && !isNaN(delay_time)){
      $(msg).delay(delay_time).fadeOut(function(){
        $(msg).remove();
      });
    }
  },
  
  // Validate IPv4 address format
  is_valid_ip4_address: function (ipaddr) {
   var re = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;
   if (re.test(ipaddr)) {
      var parts = ipaddr.split(".");
      if (parseInt(parseFloat(parts[0])) == 0) { return false; }
      for (var i = 0; i < parts.length; i++) {
       if (parseInt(parseFloat(parts[i])) > 255) { return false; }
      }
      return true;
    } else {
      return false;
    }
  },
  
  // Validate list of IPv4 addresses format.
  is_valid_ip4_addresses: function (ipaddresses, separator) {
    if(!separator || $.trim(separator) == ""){
      separator = ","; // set default separator.
    }    
    var ips = ipaddresses.split(separator);
    for (var i = 0; i < ips.length; i++) {
      var ip = $.trim(ips[i]);
      if(!helper.is_valid_ip4_address(ip)){
        return false;
      }
    }    
    return true;
  },
  
  setup_async_image_tag: function(img_selector, container_selector){
    if(!img_selector)
      img_selector = "img.user-avatar";
    $(img_selector).livequery(function(){
      $(this).jail({
        effect : "fadeIn",
        selector: container_selector
      });
    });
  },
  
  is_equal_elements: function(elm1, elm2){
    return (elm1 == elm2 || $.inArray(elm1, elm2) >= 0)
  },
  
  parse_date: function(date_format, value){
    var result = null
    try{
      result = $.datepicker.parseDate(date_format, value);
    }
    catch(exc){      
    }
    return result;
  },
  
  hide_require_signs: function(){
    // Require Livequery
    $(".simple_form label.required abbr").livequery(function(){
      $(this).hide()
    });
  },
  
  scroll_to: function(element, delay_time){
    if (!delay_time)
      delay_time = 300;
    $('html, body').animate({ scrollTop: $(element).offset().top - 10}, delay_time);
  },
  
  rand_num: function(){
    var str_num = Math.random().toString();
    str_num = str_num.replace("0.", "");
    return parseInt(str_num);
  }
};
