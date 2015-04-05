function insert_fields(link, method, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + method, "g");
  jQuery(link).before(content.replace(regexp, new_id));
}

function remove_fields(link, hide_class, removal_question) {
  if (removal_question == "" || confirm(removal_question)) {
    var hidden_field = jQuery(link).prev("input[type=hidden]").val("1");
    if (hidden_field) {
      hidden_field.value = '1';
    }
    jQuery(link).closest("." + hide_class).hide();
  }
}
