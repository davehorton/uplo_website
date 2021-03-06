var helper = {
  timerID: null,

  showErrorMessage: function(condit_value, elem, msg_text, cl) {
    var s;
    if (cl == null) {
      cl = '';
    }
    if (!condit_value) {
      if ($(elem).siblings('.error').length === 0) {
        s = "<span class='error " + cl + "'>" + msg_text + "</span>";
        $(elem).after(s);
      } else {
        $(elem).siblings('.error').text("" + msg_text);
      }
      return false;
    } else {
      $(elem).siblings('.error').remove();
      return true;
    }
  },

  pluralize_without_count: function(number, single_form, plural_form) {
    if(parseInt(number) == 1) {
      return single_form;
    } else {
      return plural_form;
    }
  },

  check_less_than_characters: function(string, min_chars, callback){
    if(string.length < min_chars) {
      if(callback == null) {
        helper.show_notification('Must be at least ' + min_chars + ' character(s)');
      } else {
        callback.call();
      }
      return false;
    }
    return true;
  },

  prevent_exceed_characters: function(node, charcode, max_chars, callback){
    if(!charcode) { return true }
    var part1 = node.value.substring(0, node.selectionStart);
    var part2 = node.value.substring(node.selectionEnd, node.value.length);
    var str = part1 + String.fromCharCode(charcode) + part2;
    if(str.length > max_chars) {
      if(callback == null){
        return false;
      } else {
        callback.call();
      }
    }
    return true;
  },

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

  auto_hide_flash_message: function(){
    clearInterval(helper.timerID);
    helper.timerID = setInterval(function() {
        $('.flash').stop(true, true).fadeOut('fast');
    }, 5000);
  },

  show_notification: function(message){
    $('.flash').stop(true, true).fadeIn('fast');
    var string = "<div class='icon_notification left'></div><div class='left message wordwrap'>" + message + "</div>";
    $(".flash").find(".notification-container").removeClass('error').removeClass("hidden");
    $(".flash").find('.messages').html(string);
    helper.auto_hide_flash_message();
  },

  show_error_notification: function(message){
    helper.show_notification(message);
    $('.notification-container').addClass('error');
  },

  // Validate IPv4 address format
  valid_ip4_address: function (ipaddr) {
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
  valid_ip4_addresses: function (ipaddresses, separator) {
    if(!separator || $.trim(separator) == ""){
      separator = ","; // set default separator.
    }
    var ips = ipaddresses.split(separator);
    for (var i = 0; i < ips.length; i++) {
      var ip = $.trim(ips[i]);
      if(!helper.valid_ip4_address(ip)){
        return false;
      }
    }
    return true;
  },

  equal_elements: function(elm1, elm2){
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
  },

  alert_not_implement: function(){
    helper.show_notification("This feature is coming soon");
    return false;
  },

  show_overlay: function(){
    $('.overlay').css('width', $(document).width() + 'px');
    $('.overlay').css('height', $(document).height() + 'px');
  },

  setup_login: function(){
    $('#btn-login').click(function(){
      var email_exist = ($('#user_login').val().trim().length > 0);
      var pass_exist = ($('#user_password').val().trim().length > 0);
      helper.showErrorMessage(email_exist, '#user_login', "Can't be blank", 'text message highlight right');
      helper.showErrorMessage(pass_exist, '#user_password', "Can't be blank", 'text message highlight right');
      if(email_exist && pass_exist){
        $('#frm-login').submit();
      }else {
        return false;
      }
    });
    $('#btn-request-inv').click(function(){
      $('#frm-request').submit();
    });
    $('#login-overlay').click(function(){
      $(this).fadeOut();
      $('#session-container').fadeOut();
    });
    $('#user-box a').click(function(){
      $('#login-overlay').fadeIn();
      $('#session-container').fadeIn();
    });
  },

  setup_filtering_search: function(){
    $('.button.search').click(function(){
      $('#filtering-search-box').submit();
    });
    $('#filtered_by').change(function(){
      $('#sort_by').val('');
      $('#filtering-search-box').submit();
    });
    $('#sort_by').change(function(){ $('#filtering-search-box').submit(); })
  }
}