
$(document).ready(function() {
  if ($(".datepicker").length > 0) {
    $(".datepicker").datepicker();
    $("#ui-datepicker-div").hide();
  }
});

function change_reviewer_autocomplete(ev, ui) {
  if (ui.item) {
    $(this).prev("input[type=hidden]").val(ui.item.id).
      siblings(".ui-icon-check").show();
  }
  else {
    $(this).prev("input[type=hidden]").val("").
      siblings(".ui-icon-check").hide();
  }
}

function setup_reviewer_autocomplete() {
  $(".chosen").filter(":last").chosen().change(function() {
    if ($(".chosen").filter(":last").val()) {
      add_reviewer();
    }
  });
}

function remove_reviewer(reviewer) {
  $(reviewer).next('input[type=hidden]').val('1');
  $(reviewer).closest('tr').fadeOut();
}

function add_reviewer() {
  var now = new Date().getTime();
  var re = new RegExp("new_review_event_user", "g");
  $("#new_reviewers").append($("#new_reviewer_template").html().replace(re, now));
  setup_reviewer_autocomplete();
}


