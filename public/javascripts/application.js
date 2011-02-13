
$(document).ready(function() {
  $(".button").hover(
  	function() { $(this).addClass('ui-state-hover'); }, 
  	function() { $(this).removeClass('ui-state-hover'); }
  );
  setup_reviewer_autocomplete();
});

function change_reviewer_autocomplete(event, ui) {
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
  $(".reviewer_autocomplete").autocomplete('destroy').autocomplete({
    source: "/reviewers/show",
    change: change_reviewer_autocomplete,
    select: change_reviewer_autocomplete,
    delay: 100,
    selectFirst: true,
  }).keydown(function (e) {
    if (e.keyCode == 13) {
      e.preventDefault();
      return false;
    }
  });
}

function remove_reviewer(reviewer) {
  $(reviewer).next('input[type=hidden]').val('1');
  $(reviewer).closest('tr').fadeOut();
}

function add_reviewer(link, content) {
  var now = new Date().getTime();
  var re = new RegExp("new_review_event_user", "g");
  $(link).prev("table").append("<tr><td colspan=\"2\">"+content.replace(re, now)+"</td></tr>");
  setup_reviewer_autocomplete();
  $(link).prev("table").find("input[type=text]:last").focus();
}
