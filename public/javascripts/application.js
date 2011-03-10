
$(document).ready(function() {
  $(".diff tr").hover(
    function() { 
      $(this).find(".add-comment-button").animate({'opacity':1.0}, 100); 
    },
    function() { 
      $(this).find(".add-comment-button").animate({'opacity':0.0}, 100); 
    }
  );
  $(".datepicker").datepicker();
  $(".review-event").hover(
    function() { 
      $(this).find(".review-event-actions").animate({'opacity':1.0}, 100); 
    },
    function() { 
      $(this).find(".review-event-actions").animate({'opacity':0.0}, 100); 
    }
  );

  
  setup_button_hover();
  setup_comment_hover();
  setup_reviewer_autocomplete();
});

function setup_button_hover() {
  $(".button").unbind().hover(
  	function() { $(this).addClass('ui-state-hover'); }, 
  	function() { $(this).removeClass('ui-state-hover'); }
  );
}

function setup_comment_hover() {
  $(".comment").unbind().hover(
    function() { 
      $(this).find(".comment-actions").animate({'opacity':1.0}, 100); 
    },
    function() { 
      $(this).find(".comment-actions").animate({'opacity':0.0}, 100); 
    }
  ); 
}

function display_error(error) {
  $("#error-dialog").html(error).dialog({
    resizable: false,
    modal: true,
    buttons: { "OK": function() { $(this).dialog("close"); } }
  });
}

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
  $(".reviewer_autocomplete").autocomplete('destroy').autocomplete({
    source: "/reviewers/show",
    change: change_reviewer_autocomplete,
    select: change_reviewer_autocomplete,
    delay: 100,
    selectFirst: true
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
  $(link).prevUntil("table").append("<tr><td colspan=\"2\">"+content.replace(re, now)+"</td></tr>");
  setup_reviewer_autocomplete();
  $(link).prevUntil("table").find("input[type=text]:last").focus();
  $(link).prev(".info").show();
}

function submit_comment(loc) {
  var comment = $(loc).parents(".comment-box").find("form").serialize();
  $.post("/comments/create", comment,
    function(data, textStatus, jqXHR) {
      if (data.status == "ok") {
        $(loc).parents(".comment-box").parent().fadeOut(function() {
          $(this).append(data.content);
          $(this).children(".comment-box").remove();
          $(this).fadeIn();
          setup_comment_hover();
        });
      }
  }, "json");
}

function delete_comment(comment_id) {
  $("#delete-confirm").dialog({
    resizable: false,
    modal: true,
    buttons: {
      "Delete": function() {
        $(this).dialog("close");
        $.post("/comments/destroy", { id : comment_id },
          function(data, textStatus, jqXHR) {
            if (data.status == "ok") {
              $("#comment_"+comment_id).fadeOut();
            }
            else {
              
            }
        }, "json");
      },
      "Cancel": function() {
        $(this).dialog("close");
      }
    }
  });
}

function add_comment_form(loc, content) {
  if ($(loc).children(".comment-box").length > 0) {
    $(loc).find("textarea").focus();
    return;
  }
  $(loc).append(content).children(".comment-box").fadeIn(function() {
    $(this).find("textarea").focus();
  });
  setup_button_hover();
}

function close_comment_form(loc) {
  $(loc).parents(".comment-box").fadeOut(function() { $(this).remove(); });
}

function create_changeset() {
  $("#create-changeset-dialog").dialog({
    modal: true,
    minWidth: 350,
    title: "Create Changeset",
    buttons: {
      "Create Changeset": function() {
        $.post("/changeset/create", $(this).children("form").serialize(),
               function(data, textStatus, jqXHR) {
                 if (data.status == "ok") {
                   location.href += "?changeset="+data.id;
                 }
                 else {
                   display_error(data.errors);
                 }
                 $(this).dialog('close');
        }, "json");
        $(this).dialog('disable');
      },
      "Cancel": function() {
        $(this).dialog('close');
      }
    },
    open: function() {
      $(this).find("input[type=text]").val("").focus();
      $(this).keydown(function(e) {
        if (e.keyCode == 13) {
          $(".ui-dialog").find("button:first").trigger("click");
          e.stopPropagation();
          return false;
        }
      });
    }
  });
}

function submit_changeset(changeset_id) {
  $("#submit-changeset-dialog").dialog({
    modal: true,
    title: "Submit for Review?",
    buttons: {
      "Submit": function() {
        $.post("/changeset/update/"+changeset_id, 
               $(this).children("form").serialize(),
          function(data, textStatus, jqXHR) {
            if (data.status == "ok") {
              /*$("#changeset_status").fadeOut(function() {
                $(this).after(data.content).remove();
                $("#changeset_status").hide().fadeIn();
              });*/
              location.reload();
            }
            else {
              display_error(data.errors);
            }
            $(this).dialog('close');
          }, "json");
        $(this).dialog('disable');
      },
      "Cancel": function() {
        $(this).dialog('close');
      }
    }
  });
}

function add_new_diff() {
  $("#add-diff-dialog").dialog({
    modal: true,
    minWidth: 450,
    title: "Add Diff",
    buttons: {
      "Add Diff": function() {
        $.post("/diffs/create", $(this).children("form").serialize(),
          function(data, textStatus, jqXHR) {
            if (data.status == "ok") {
              location.reload();
            }
            else {
              display_error(data.errors);
            }
            $(this).dialog('close');
          }, "json");
        $(this).dialog('disable');
      },
      "Cancel": function() {
        $(this).dialog('close');
      }
    }
  });
}

function remove_diff(diff_id) {
  $("#remove-diff-dialog").dialog({
    modal: true,
    title: "Delete Diff",
    buttons: {
      "Delete Diff": function() {
        $.post("/diffs/destroy/"+diff_id, 
          $(this).children("form").serialize(),
          function(data, textStatus, jqXHR) {
            if (data.status == "ok") {
              location.reload();
            }
            else {
              display_error(data.errors);
            }
            $(this).dialog('close');
          }, "json");
        $(this).dialog('disable');
      },
      "Cancel": function() {
        $(this).dialog('close');
      }
    }
  });
}

function remove_changeset(changeset_id, review_id) {
  $("#remove-changeset-dialog").dialog({
    modal: true,
    title: "Delete Changeset",
    buttons: {
      "Delete Changeset": function() {
        $.post("/changeset/destroy/"+changeset_id, 
          $(this).children("form").serialize(),
          function(data, textStatus, jqXHR) {
            if (data.status == "ok") {
              location.href = "/review_events/"+review_id;
            }
            else {
              display_error(data.errors);
            }
            $(this).dialog('close');
          }, "json");
        $(this).dialog('disable');
      },
      "Cancel": function() {
        $(this).dialog('close');
      }
    }
  });
}

function submit_changeset_status(changeset_id, user_id, accepted) {
  var statusText = accepted ? "Accept" : "Reject";
  var buttons = {};
  buttons[statusText] = function() {
    $.post("/changeset/status", { 
        changeset_user_status: {
          changeset_id: changeset_id,
          user_id: user_id,
          accepted: accepted
        }
      },
      function(data, textStatus, jqXHR) {
        if (data.status == "ok") {
          location.reload();
        }
        else {
          display_error(data.errors);
        }
        $(this).dialog('close');
    }, "json");
    $(this).dialog('disable');
  };
  buttons["Cancel"] = function() {
    $(this).dialog('close');
  };
  $("#status-changeset-dialog").html("Are you sure you wish to "+
      statusText.toLowerCase()+" this changeset?").
    dialog({
      modal: true,
      title: "Update Status",
      buttons: buttons
  });
}

function remove_review_event(loc, event_id) {
  $("#remove-review-dialog").dialog({
    modal: true,
    title: "Remove Review Event",
    buttons: {
      "Remove": function() {
        $.ajax({
          url: "/review_events/"+event_id,
          type: "DELETE",
          dataType: "json",
          success: function(msg) {
            $('#remove-review-dialog').dialog('close');
            if (msg.status == "ok") {
              $(loc).parents(".review-event").fadeOut();
            }
          }
        });
        $(this).dialog('disable');
      },
      "Cancel": function() {
        $(this).dialog('close');
      }
    }
  });
}

