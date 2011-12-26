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
  date_format: "dd/mm/yy",
  date_format_dev: "yy-mm-dd",
  status_show_error: 777
};

/**
 * Contains properties and methods to store and retrieve user's preferences data.
 * Require: 
 *    jquery
 *    jquery.cookie
 */ 
user_preferences = {
  PREF_PROJECT_TYPE: "pref_project_type",
  PREF_PROJECT_ID: "pref_project_id",
  
  // Gets or sets the selected project type.
  project_type: function(value){
    return user_preferences.get_or_set(user_preferences.PREF_PROJECT_TYPE, value);  
  },
  
  // Gets or sets the selected project id.
  project_id: function(value){
    return user_preferences.get_or_set(user_preferences.PREF_PROJECT_ID, value);
  },
  
  // Retrieve the user's preference.
  get: function(key){
    return jQuery.cookie(key);
  },
  
  // Save user's preference.
  set: function(key, value){
    jQuery.cookie(key, value, {path: "/"});
  },
  
  get_or_set: function(key, value){
    if(typeof(value) != "undefined"){
      user_preferences.set(key, value);
    }
    else
      return user_preferences.get(key);
  },
  
  // Cheat code: change the URL of Project (Pilotage) tab.
  modify_project_url: function(url){
    var result = url;
    
    try{
      var pref_project_id = user_preferences.project_id();
      if(!pref_project_id || jQuery.trim(pref_project_id) == "")
        return result; // No change.
        
      var last_separator_index = url.lastIndexOf("/");
      var current_project_id = url.substring(last_separator_index + 1);
      if(isNaN(current_project_id)){
        // Retry.
        var match_string = current_project_id.match(/[?&]+project_id=[1-9]*/);
        if(match_string != null && match_string.length > 0){
          var new_project_id = match_string[0].replace(/project_id=[1-9]*/, "project_id=" + pref_project_id);
          new_project_id = current_project_id.replace(/[?&]+project_id=[1-9]*/, new_project_id);
          result = result.replace(current_project_id, new_project_id);
        }
      }
      else if(current_project_id != pref_project_id){
        // Change the URL.
        result = url.substring(0, last_separator_index);
        result += "/" + pref_project_id;
      }
    }
    catch(exc){
      console.log(exc);
    }
    
    return result;
  },
  
  // Cheat code: change the URL of the Suivi des temps > Temps de mes équipes tab.
  modify_team_timesheet_url: function(){
    var result  = "";
    try{
      var tab_team_timesheet = $(".sub-menu").find(".team_timesheet a");
      result = $(tab_team_timesheet).attr("href");
      
      var pref_project_id = user_preferences.project_id();
      if(!pref_project_id || jQuery.trim(pref_project_id) == "")
        return result; // No change.
      
      if(!isNaN(pref_project_id)){
        if(result.indexOf("?") < 0){
          result += "?";
        }
        else{
          result += "&";
        }
        
        result += "project_id=" + pref_project_id;
      }
      
      // Change the URL
      $(tab_team_timesheet).attr("href", result);
    }
    catch(exc){
      console.log(exc);
    }
    
    return result;
  },
  
  // Cheat code: change the URL of the admin billing tab.
  modify_billing_report_url: function(url){
    var result = url;
    
    try{
      var pref_project_id = user_preferences.project_id();
      if(!pref_project_id || jQuery.trim(pref_project_id) == "")
        return result; // No change.
        
      var match_string = url.match(/projects\/[1-9]*\/billing_reports/);
      if(match_string != null && match_string.length > 0){
        var new_project_id = "projects/" + pref_project_id + "/billing_reports";
        result = url.replace(/projects\/[1-9]*\/billing_reports/, new_project_id);
      }
    }
    catch(exc){
      console.log(exc);
    }
    
    return result;
  }
}

left_panel = {
  special_project_types: ['', 'open', 'closed'],
  
  // Setup all components.
  setup: function(selected_project_type, selected_project_id){
    left_panel.setup_project_types();
    left_panel.setup_projects();
    
    if(selected_project_type && selected_project_id){
      $("#project_type_select").val(selected_project_type);
      $("#project_type_select").change();
      var current_project = $("#my-project-content li.project-item.current");
      current_project.removeClass("current");
      current_project.removeClass("hover");
      var selected_project = $("#my-project-content li[data-project-id='" + selected_project_id + "']");
      selected_project.addClass("current");
      selected_project.addClass("hover");
    }
  },
  
  // Setup project type select box (general usage).
  setup_project_types: function(){
    $("#project_type_select").change(function(){
      var project_type = $(this).val();
      user_preferences.project_type(project_type);
      if(jQuery.inArray(project_type, left_panel.special_project_types) < 0){
        $("#my-project-content li[data-project-type!='" + project_type + "']").hide();
        $("#my-project-content li[data-project-type='" + project_type + "']").show();
      }
      else{
        $("#my-project-content li").hide();
        $("#my-project-content li[data-project-type$='_" + project_type + "']").show();
      }
    });
    
    // Force changing on the project types combobox.
    var stored_type = user_preferences.project_type();
    left_panel.check_project_select(stored_type);
  },
  
  // This method is particularly used for My TImesheet page.
  setup_my_timesheet_project_types: function(){
    $("#project_type_select").change(function(){
      var project_type = $(this).val();
      if(jQuery.inArray(project_type, left_panel.special_project_types) < 0){
        $("#my-project-content div[data-project-type!='" + project_type + "']").hide();
        $("#my-project-content div[data-project-type='" + project_type + "']").show();
      }
      else{
        $("#my-project-content div").hide();
        $("#my-project-content div[data-project-type$='_" + project_type + "']").show();
      }

      $("#my-project-content div[data-project-type='InternalProject']").show();
    });

    // Force changing on the project types combobox.
    var stored_type = user_preferences.project_type();
    $("#project_type_select").val(stored_type);
    $("#project_type_select").change();
  },
  
  // Setup project name items.
  setup_projects: function(){
    $('#project-type-content li').hover(function() {
        $(this).addClass('hover');
      }, function() {
        if(!$(this).hasClass('current'))
          $(this).removeClass('hover');
      }
    );
    
    $('li.project-item').hover(function() {
        $(this).addClass('hover');
      }, function() {
        if(!$(this).hasClass('current'))
          $(this).removeClass('hover');
      }
    );
    
    $('#my-project-content li.project-item').click(function(){
      user_preferences.project_id($(this).attr("data-project-id"));
    });
  },
  
  check_project_select: function (old_type){
    var current_type = $("#project_type_select").val();
    if(current_type != old_type){
      var match_string = current_type.match(/open$|closed$/)
      if(match_string != null && match_string.length > 0 && 
          $.inArray(match_string[0], left_panel.special_project_types) >= 0) {
        $("#project_type_select").val(match_string[0]);
      } else {
        $("#project_type_select").val("open"); // Select "all" option.
      }
    }
    else{
      $("#project_type_select").val(old_type);
    }
    
    $("#project_type_select").change();
  }
}

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
    $(".simple_form label.required abbr").hide();
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
