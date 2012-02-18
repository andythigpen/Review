/*
 * jQuery Caret Range plugin
 * Copyright (c) 2009 Matt Zabriskie
 * Released under the MIT and GPL licenses.
 */
(function($) {
  $.extend($.fn, {
    caret: function (start, end) {
      var elem = this[0];

      if (elem) {             
        // get caret range
        if (typeof start == "undefined") {
          if (typeof elem.selectionStart != 'undefined') {
            start = elem.selectionStart;
            end = elem.selectionEnd;
          }
          else if (typeof document.selection != 'undefined') {
            var val = this.val();
            var range = document.selection.createRange().duplicate();
            range.moveEnd("character", val.length)
            start = (range.text == "" ? val.length : val.lastIndexOf(range.text));

            range = document.selection.createRange().duplicate();
            range.moveStart("character", -val.length);
            end = range.text.length;
          }
        }
        // set caret range
        else {
          var val = this.val();

          if (typeof start != "number") start = -1;
          if (typeof end != "number") end = -1;
          if (start < 0) start = 0;
          if (end > val.length) end = val.length;
          if (end < start) end = start;
          if (start > end) start = end;

          elem.focus();

          if (typeof elem.selectionStart != 'undefined') {
            elem.selectionStart = start;
            elem.selectionEnd = end;
          }
          else if (typeof document.selection != 'undefined') {
            var range = elem.createTextRange();
            range.collapse(true);
            range.moveStart("character", start);
            range.moveEnd("character", end - start);
            range.select();
          }
        }

        return {start:start, end:end};
      }
    }
  });
})(jQuery);

$(document).ready(function() {
  setup_awesome_bar();
});

function submit_comment(loc) {
  var comment = $(loc).parents(".comment-box").find("form").serialize();
  $(loc).unbind().removeAttr('onclick').addClass("disabled");
  $(loc).bind('click', function() { return false; });
  $(loc).siblings(".button").each(function() {
    if ($(this).text().toLowerCase() == "close") {
      return 0;
    }
    $(this).unbind().removeAttr('onclick').addClass("disabled");
    $(this).bind('click', function() { return false; });
  });
  $.post("/comments/create", comment,
    function(data, textStatus, jqXHR) {
      if (data.status == "ok") {
        var margin = $(loc).parents(".comment-box").css('margin-left') || 0;
        margin = parseInt(margin, 10);
        $(loc).parents(".comment-box").parent().fadeOut(function() {
          $(this).append(data.content); 
          $(this).children(".comment").css('margin-left', margin+'px');
          $(this).children(".comment-box").remove();
          $(this).fadeIn();
          setup_profile_popups();
        });
      }
  }, "json");
}

//TODO refactor
function delete_comment_modal() {
  show_ajax_loader("#delete-confirm");
  var comment_id = $("#delete-confirm a[data-action='submit']").
    data("comment-id");
  $.post("/comments/destroy", { id : comment_id },
    function(data, textStatus, jqXHR) {
      $("#delete-confirm").modal("hide");
      if (data.status == "ok") {
        $("#comment_"+comment_id).fadeOut();
      }
      else {
        display_error(data.errors);
      }
    }, "json");
}

function delete_comment(loc, comment_id) {
  hide_ajax_loader("#delete-confirm");
  var comment_text = $(loc).parents(".comment").find(".comment-text").html();
  $("#delete-confirm").find(".comment").html(comment_text);
  $("#delete-confirm").modal('show');
  $("#delete-confirm a[data-action='submit']").
    data("comment-id", comment_id);
}

function add_comment_form(loc, commentable_id, commentable_type, leftline, rightline) {
  if ($(loc).children(".comment-box").length > 0) {
    $(loc).find("textarea").focus();
    return;
  }
  var content = $("#comment-form").html();
  var margin = $(loc).prev(".comment").css('margin-left');
  margin = parseInt(margin, 10) + 10;
  $(loc).
    append(content).
    children(".comment-box").
    css('margin-left', margin+'px').
    fadeIn(function() {
    $(this).find("textarea").focus();
    $(this).find("input[name='comment[commentable_id]']").val(commentable_id);
    $(this).find("input[name='comment[commentable_type]']").
      val(commentable_type);
    $(this).find("input[name='comment[leftline]']").val(leftline);
    $(this).find("input[name='comment[rightline]']").val(rightline);
  });
  setup_buttons();
}

function close_comment_form(loc) {
  $(loc).parents(".comment-box").fadeOut(function() { 
    $(this).remove(); 
  });
}

function preview_comment(loc) {
  var val = $(loc).parents('.comment-box').find('textarea').val();

  var margin = $(loc).parents(".comment-box").css('margin-left');
  $(loc).parents('.comment-box').hide().after(function() {
    // this must match the format comment application helper
    var comment = val.replace(/\{\{\{/g, '<pre>');
    comment = comment.replace(/\}\}\}/g, '</pre>');
    comment = comment.replace(/'''(.*?)'''/g, '<strong>$1</strong>');
    var result = '<div class="comment comment-preview hidden" style="margin-left:'+
      margin+';">';
    result += '<div class="topbar">Comment Preview</div>';
    result += '<div class="comment-text">' + comment + '</div>'; 
    result += '<div class="field" style="margin:10px;"><a href="#" onclick="close_preview_comment(this);return false;" class="btn btn-small" style="margin-top:0.5em;">Close Preview</a></div>';
    result += '</div>';
    return result;
  });
  $(loc).parents('.comment-box').next('.comment-preview').fadeIn();
  setup_buttons();
}

function close_preview_comment(loc) {
  $(loc).parents('.comment-preview').prev('.comment-box').fadeIn();
  $(loc).parents('.comment-preview').remove();
}

function add_comment_code(loc) {
  var textarea = $(loc).parents('.comment-box').find('textarea');
  var range = textarea.caret();
  range.start = range.start || 0;
  range.end = range.end || 0;
  var val = textarea.val();

  textarea.val(val.substr(0, range.start) + '{{{ ' + 
               val.substr(range.start, range.end - range.start) + ' }}}' + 
               val.substr(range.end, val.length - range.start));
  textarea.caret(range.end + '{{{ '.length);
}

function add_comment_bold(loc) {
  var textarea = $(loc).parents('.comment-box').find('textarea');
  var range = textarea.caret();
  range.start = range.start || 0;
  range.end = range.end || 0;
  var val = textarea.val();

  textarea.val(val.substr(0, range.start) + "'''" + 
               val.substr(range.start, range.end - range.start) + "'''" + 
               val.substr(range.end, val.length - range.start));
  textarea.caret(range.end + "'''".length);
}

function create_changeset_modal() {
  show_ajax_loader("#create-changeset-dialog");
  $.post("/changeset/create", 
      $("#create-changeset-dialog").find("form").serialize(),
    function(data, textStatus, jqXHR) {
      $("#create-changeset-dialog").modal('hide');
      if (data.status == "ok") {
        var url = location.href;
        url = url.replace(/\?changeset=\d+/, "");
        location.href = url+"?changeset="+data.id;
      }
      else {
        display_error(data.errors);
      }
  }, "json");
}

function create_changeset() {
  hide_ajax_loader("#create-changeset-dialog");
  $("#create-changeset-dialog").modal('show');
}

function submit_changeset_modal() {
  show_ajax_loader("#submit-changeset-modal");
  var changeset_id = $("#submit-changeset-dialog a[data-action='submit']").
    data("changeset-id");
  $.post("/changeset/update/"+changeset_id, 
         $("#submit-changeset-dialog").find("form").serialize(),
    function(data, textStatus, jqXHR) {
      $("#submit-changeset-dialog").modal('hide');
      if (data.status == "ok") {
        location.reload();
      }
      else {
        display_error(data.errors);
      }
    }, "json");
}
function submit_changeset(changeset_id) {
  hide_ajax_loader("#submit-changeset-modal");
  $("#submit-changeset-dialog").modal('show');
  $("#submit-changeset-dialog a[data-action='submit']").
    data("changeset-id", changeset_id);
}

function remove_changeset_modal() {
  show_ajax_loader("#remove-changeset-dialog");
  var changeset_id = $("#remove-changeset-dialog").data("changeset-id");
  var review_id = $("#remove-changeset-dialog").data("review-id");
  $.post("/changeset/destroy/"+changeset_id, 
    $("#remove-changeset-dialog").find("form").serialize(),
    function(data, textStatus, jqXHR) {
      $("#remove-changeset-dialog").modal('hide');
      if (data.status == "ok") {
        location.href = "/review_events/"+review_id;
      }
      else {
        display_error(data.errors);
      }
    }, "json");
}

function remove_changeset(changeset_id, review_id) {
  hide_ajax_loader("#remove-changeset-dialog");
  $("#remove-changeset-dialog").
    data("changeset-id", changeset_id).
    data("review-id", review_id);
  $("#remove-changeset-dialog").modal('show');
}

function submit_changeset_status(user_id, changeset_id, statusText, statusType, defaultComment, dialogText) {
  var dialogText = dialogText || statusText;
  $("#status-changeset-dialog .status").html(dialogText.toLowerCase());
  $("#status-changeset-dialog textarea").html(defaultComment);
  hide_ajax_loader("#status-changeset-dialog");
  $("#status-changeset-dialog").modal('show');
  $("#status-changeset-dialog a[data-action='submit']").click(function (e) {
    e.preventDefault();
    if ($("#status-changeset-dialog textarea").val().length == 0) {
      $("#status-changeset-dialog .alert").fadeIn();
      return false;
    }

    show_ajax_loader("#status-changeset-dialog");
    $.post("/changeset/status", { 
        changeset_user_status: {
          "changeset_id": changeset_id,
          "status": statusType,
          "comments_attributes": [
            { 
              "content": $("#status-changeset-dialog textarea").val(),
              "user_id": user_id 
            }
          ]
        }
      },
      function(data, textStatus, jqXHR) {
        if (data.status == "ok") {
          location.reload();
        }
        else {
          $(this).modal('hide');
          display_error(data.errors);
        }
    }, "json");

    return false;
  });
}

function delete_changeset_status_modal() {
  show_ajax_loader("#delete-status");
  var status_id = $("#delete-status").data("status-id");
  $.ajax({
    url: "/changeset/status/"+status_id,
    type: "DELETE",
    dataType: "json",
    success: function (msg) {
      location.reload();
    }
  });
}
function delete_changeset_status(status_id) {
  hide_ajax_loader("#delete-status");
  var changeset_html = $("#changeset_status").html();
  $("#delete-status").find(".comment").html(changeset_html);
  $("#delete-status").data("status-id", status_id).modal('show');
}

function add_new_diff_modal() {
  show_ajax_loader("#add-diff-dialog");
  $("#add-diff-dialog").find("form").submit();
}

function add_new_diff() {
  hide_ajax_loader("#add-diff-dialog");
  $("#add-diff-dialog").modal('show');
}

function remove_diff_modal() {
  show_ajax_loader("#remove-diff-dialog");
  var diff_id = $("#remove-diff-dialog").data("diff-id");
  $.post("/diffs/destroy/"+diff_id, 
    $("#remove-diff-dialog").find("form").serialize(),
    function(data, textStatus, jqXHR) {
      $("#remove-diff-dialog").modal('hide');
      if (data.status == "ok") {
        location.reload();
      }
      else {
        display_error(data.errors);
      }
    }, "json");
}

function remove_diff(diff_id) {
  hide_ajax_loader("#remove-diff-dialog");
  $("#remove-diff-dialog").data("diff-id", diff_id).modal('show');
}

function next_comment(loc) {
  var min = -1;
  var minitem = null;
  var wtop = $(window).scrollTop();
  var bar_height = $("#awesome-bar .contents").height();
  $(".comment").each(function() {
    var itop = $(this).offset().top;
    var diff = wtop - itop;
    diff = parseInt(diff, 10);
    if (diff >= -bar_height) {
      return true;
    }
    minitem = this;
    return false;
  });
  if (minitem != null) {
    $.scrollTo(minitem, {axis: 'y', offset:-bar_height});
  }
}

function prev_comment(loc) {
  var min = -1;
  var minitem = null;
  var wtop = $(window).scrollTop();
  var bar_height = $("#awesome-bar .contents").height();
  $(".comment").each(function() {
    var itop = $(this).offset().top;
    var diff = wtop - itop;
    diff = parseInt(diff, 10);
    if (diff <= 1) {    // 1px for FF
      return false;
    }
    minitem = this;
  });
  if (minitem != null) {
    $.scrollTo(minitem, {axis: 'y', offset:-bar_height});
  }
}

function next_file(loc) {
  var min = -1;
  var minitem = null;
  var wtop = $(window).scrollTop();
  $(".box").each(function() {
    var itop = $(this).offset().top;
    var diff = wtop - itop;
    diff = parseInt(diff, 10);
    if (diff >= 0) {
      return true;
    }
    minitem = this;
    return false;
  });
  if (minitem != null) {
    $.scrollTo(minitem, {axis: 'y', offset:1});
  }
}

function prev_file(loc) {
  var min = -1;
  var minitem = null;
  var previtem = null;
  var wtop = $(window).scrollTop();
  $(".box").each(function() {
    var itop = $(this).offset().top;
    var diff = wtop - itop;
    diff = parseInt(diff, 10);
    if (diff <= 1) {    // 1px for FF
      return false;
    }
    minitem = this;
  });
  if (minitem != null) {
    $.scrollTo(minitem, {axis: 'y', offset:1});
  }
}

// keeps track of where we are on page
var file_index = -1;
var comment_index = -1;

function setup_awesome_bar() {
  $(window).unbind('scroll').scroll(function() {
    var min = 0;
    var minitem = null;
    var wtop = $(window).scrollTop();
    var index = -1;
    $(".box").each(function() {
      var itop = $(this).offset().top;
      var diff = wtop - itop;
      index += 1;
      if (diff < 0) {
        return false;   // stop iterating
      }
      minitem = this;
    });
    if (minitem != null) {
      $("#awesome-bar").slideDown();
      var title = $(minitem).find(".filename").text();
      $("#awesome-bar .contents .filename").html(title);
    }
    else {
      $("#awesome-bar").slideUp();
    }
    file_index = index;
  });
}

function show_diff(loc) {
  $(loc).closest("tr").fadeOut(function() {
    $(this).siblings("tr:not(.comment-box-container)").fadeIn();
  });
}
