
$(document).ready(function() {
  $("#reviewer-table input[type=checkbox]").live("change", function() {
    if (this.checked) {
      $(this).closest("tr").addClass("selected");
    }
    else {
      $(this).closest("tr").removeClass("selected");
    }
  });

  setup_reviewer_autocomplete();
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
  $("#reviewer-select").chosen().change(function() {
    if (!$(this).val()) {
      return;
    }
    var review_event_id = $("#review_event_id").val();
    var user_id = $(this).val();
    $(this).val(0).trigger("liszt:updated");
    $("#reviewer-table > tbody > tr:last").after("<tr id=\"adding_"+user_id+"\" class=\"loading\"><td colspan=\"3\">Adding user...</td></tr>");
    $.getJSON("/reviewer/"+user_id+"?"+user_type+"="+review_event_id,
      function(data) {
        $("#adding_"+user_id).remove();
        if ($("#reviewer_"+data.user_id).length == 0) {
          $("#reviewer-table > tbody > tr:last").after(data.content);
        }
        else {
          $("#reviewer_"+data.user_id).fadeIn().find('input[type=checkbox]').
            attr('checked', '').change().next('input[type=hidden]').val('0');
        }
    });
  });

  $("#group-select").chosen().change(function() {
    if (!$(this).val()) {
      return;
    }
    var review_event_id = $("#review_event_id").val();
    var group_id = $(this).val();
    $(this).val(0).trigger("liszt:updated");
    $("#reviewer-table > tbody > tr:last").after("<tr id=\"adding_group_"+group_id+"\" class=\"loading\"><td colspan=\"3\">Adding group...</td></tr>");
    $.getJSON("/reviewer/group/"+group_id+"?"+user_type+"="+review_event_id,
      function(data) {
        $("#adding_group_"+group_id).remove();
        for (var idx in data) {
          if ($("#reviewer_"+data[idx].user_id).length == 0) {
            $("#reviewer-table > tbody > tr:last").after(data[idx].content);
          }
          else {
            $("#reviewer_"+data[idx].user_id).fadeIn().
              find('input[type=checkbox]').attr('checked', '').change().
              next('input[type=hidden]').val('0');
          }
        }
    });
  });
}

function remove_reviewer(reviewer) {
  $(reviewer).next('input[type=hidden]').val('1');
  $(reviewer).closest('tr').fadeOut();
}

function select_reviewers(checked) {
  if (checked) {
    $("#reviewer-table input[type=checkbox]").attr('checked', checked).change();
  }
  else {
    $("#reviewer-table input[type=checkbox]").removeAttr('checked').change();
  }
}

function remove_selected_reviewers() {
  $("#reviewer-table input[type=checkbox]:checked").each(function() {
    remove_reviewer(this);
  });
}
