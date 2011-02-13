
$(document).ready(function() {
  $(".button").hover(
  	function() { $(this).addClass('ui-state-hover'); }, 
  	function() { $(this).removeClass('ui-state-hover'); }
  );
  setup_reviewer_autocomplete();
});

function change_reviewer_autocomplete(event, ui) {
  $(this).prev("input[type=hidden]").val(ui.item.id);
}

function setup_reviewer_autocomplete() {
  $(".reviewer_autocomplete").autocomplete({
    source: "/reviewers/show",
    change: change_reviewer_autocomplete,
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
  $(reviewer).closest('li').fadeOut();
}

function add_reviewer(link, content) {
  var now = new Date().getTime();
  var re = new RegExp("new_review_event_id", "g");
  $(link).prev("ul").append("<li>"+content.replace(re, now)+"</li>");
  setup_reviewer_autocomplete();
}
