var user = {
  setup_datepicker: function(){
    var format = "mm/dd/yy";

    $(".datepicker").datepicker({
      altFormat: format,
      dateFormat: format
    });
  }
}