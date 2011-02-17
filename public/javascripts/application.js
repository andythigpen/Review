
$(document).ready(function() {
  $(".diff tr").hover(
    function() { 
      $(this).find(".add-comment-button").animate({'opacity':1.0}, 100); 
    },
    function() { 
      $(this).find(".add-comment-button").animate({'opacity':0.0}, 100); 
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
              $("#error-dialog").html(data.error).dialog({
                resizable: false,
                modal: true,
                buttons: { "OK": function() { $(this).dialog("close"); } },
              });
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

