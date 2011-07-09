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
  $(".diff tr").hover(
    function() { 
      $(this).find(".add-comment-button").animate({'opacity':1.0}, 100); 
      $(this).find(".right-add-comment-button").animate({'opacity':1.0}, 100); 
    },
    function() { 
      $(this).find(".add-comment-button").animate({'opacity':0.0}, 100); 
      $(this).find(".right-add-comment-button").animate({'opacity':0.0}, 100); 
    }
  );
  if ($(".datepicker").length > 0) {
    $(".datepicker").datepicker();
    $("#ui-datepicker-div").hide();
  }
  $(".review-event").hover(
    function() { 
      $(this).find(".review-event-actions").animate({'opacity':1.0}, 100); 
    },
    function() { 
      $(this).find(".review-event-actions").animate({'opacity':0.0}, 100); 
    }
  );

  setup_buttons();
  setup_comment_hover();
  setup_reviewer_autocomplete();
  setup_awesome_bar();
  setup_profile_popups();
});

function setup_profile_popups() {
  var timer;
  var item;
  $(".username").unbind().
    hover(
      function() { 
          if (timer) {
              clearTimeout(timer);
              timer = null;
              $(".profile").addClass('hidden');
          }
          item = $(this);
          timer = setTimeout(function() {
              item.find(".profile").removeClass('hidden'); 
              timer = null;
          }, 500);
      },
      function() { 
          if (timer) {
              clearTimeout(timer);
              timer = null;
              $(".profile").addClass('hidden');
          }
          item = $(this);
          timer = setTimeout(function() {
              item.find(".profile").addClass('hidden'); 
              timer = null;
          }, 500);
      }
    );
}

function setup_buttons() {
  $(".button").unbind().
    hover(
      function() { $(this).addClass('ui-state-hover'); }, 
      function() { $(this).removeClass('ui-state-hover'); }
    ).
    mousedown(function(e) {
      $(this).addClass('ui-state-active');
    }).
    mouseleave(function(e) {
      $(this).removeClass('ui-state-active');
    }).
    mouseup(function(e) {
      $(this).removeClass('ui-state-active');
    });
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
  $(loc).unbind().removeAttr('onclick').addClass("ui-state-disabled");
  $(loc).bind('click', function() { return false; });
  $(loc).siblings(".button").each(function() {
    if ($(this).text().toLowerCase() == "close") {
      return 0;
    }
    $(this).unbind().removeAttr('onclick').addClass("ui-state-disabled");
    $(this).bind('click', function() { return false; });
  });
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
    title: "Delete Comment",
    buttons: {
      "Delete": function() {
        show_ajax_loader(this);
        $.post("/comments/destroy", { id : comment_id },
          function(data, textStatus, jqXHR) {
            $("#delete-confirm").dialog("close");
            if (data.status == "ok") {
              $("#comment_"+comment_id).fadeOut();
            }
            else {
              display_error(data.errors);
            }
        }, "json");
      },
      "Cancel": function() {
        $(this).dialog("close");
      }
    },
    open: function() {
      hide_ajax_loader(this);
    }
  });
}

function add_comment_form(loc, commentable_id, commentable_type, leftline, rightline) {
  if ($(loc).children(".comment-box").length > 0) {
    $(loc).find("textarea").focus();
    return;
  }
  var content = $("#comment-form").html();
  $(loc).append(content).children(".comment-box").fadeIn(function() {
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
  $(loc).parents('.comment-box').hide().after(function() {
    // this must match the format comment application helper
    var comment = val.replace(/\{\{\{/g, '<div class="comment-code">');
    comment = comment.replace(/\}\}\}/g, '</div>');
    comment = comment.replace(/'''(.*?)'''/g, '<strong>$1</strong>');
    var result = '<div class="comment comment-preview hidden"><h2>Preview</h2>' + comment; 
    result += '<div><a href="#" onclick="close_preview_comment(this);return false;" class="button ui-corner-all ui-state-default" style="margin-top:0.5em;">Close Preview</a></div>';
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

/* Modified from http://stackoverflow.com/questions/577548/how-can-i-disable-a-button-in-a-jquery-dialog-from-a-function */
function get_dialog_button(dialog_selector, button_name) {
  var buttons = $(dialog_selector).siblings('.ui-dialog-buttonpane').
      find('button');
  for (var i = 0; i < buttons.length; ++i) {
     var jButton = $(buttons[i]);
     if (jButton.text() == button_name) {
         return jButton;
     }
  }
  return null;
}

function show_ajax_loader(dialog_widget) {
  $(dialog_widget).find('.dialog-content').css('opacity', '0.2');
  $(dialog_widget).find('.ajax-loader').fadeIn();
  // disable non "Cancel" or "Close" buttons
  var buttons = $(dialog_widget).dialog('option', 'buttons');
  for (var name in buttons) {
    if (name.toLowerCase() != "cancel" && name.toLowerCase() != "close") {
      var button = get_dialog_button(dialog_widget, name);
      button.button('disable');
    }
  }
}

function hide_ajax_loader(dialog_widget) {
  $(dialog_widget).find('.dialog-content').css('opacity', '1.0');
  $(dialog_widget).find('.ajax-loader').hide();
  var buttons = $(dialog_widget).dialog('option', 'buttons');
  for (var name in buttons) {
    if (name.toLowerCase() != "cancel" && name.toLowerCase() != "close") {
      var button = get_dialog_button(dialog_widget, name);
      button.button('enable');
    }
  }
}

function create_changeset() {
  $("#create-changeset-dialog").dialog({
    modal: true,
    minWidth: 350,
    title: "Create Changeset",
    buttons: {
      "Create Changeset": function() {
        show_ajax_loader(this);
        $.post("/changeset/create", $(this).find("form").serialize(),
               function(data, textStatus, jqXHR) {
                 $(this).dialog('close');
                 if (data.status == "ok") {
                   var url = location.href;
                   url = url.replace(/\?changeset=\d+/, "");
                   location.href = url+"?changeset="+data.id;
                 }
                 else {
                   display_error(data.errors);
                 }
        }, "json");
      },
      "Cancel": function() {
        $(this).dialog('close');
      }
    },
    open: function() {
      hide_ajax_loader(this);
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
        show_ajax_loader(this);
        $.post("/changeset/update/"+changeset_id, 
               $(this).find("form").serialize(),
          function(data, textStatus, jqXHR) {
            $(this).dialog('close');
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
          }, "json");
      },
      "Cancel": function() {
        $(this).dialog('close');
      }
    },
    open: function() {
      hide_ajax_loader(this);
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
        show_ajax_loader(this);
        $(this).find("form").submit();
      },
      "Cancel": function() {
        $(this).dialog('close');
      }
    },
    open: function() {
      hide_ajax_loader(this);
    }
  });
}

function remove_diff(diff_id) {
  $("#remove-diff-dialog").dialog({
    modal: true,
    title: "Delete Diff",
    buttons: {
      "Delete Diff": function() {
        show_ajax_loader(this);
        $.post("/diffs/destroy/"+diff_id, 
          $(this).find("form").serialize(),
          function(data, textStatus, jqXHR) {
            $(this).dialog('close');
            if (data.status == "ok") {
              location.reload();
            }
            else {
              display_error(data.errors);
            }
          }, "json");
      },
      "Cancel": function() {
        $(this).dialog('close');
      }
    },
    open: function() {
      hide_ajax_loader(this);
    }
  });
}

function remove_changeset(changeset_id, review_id) {
  $("#remove-changeset-dialog").dialog({
    modal: true,
    title: "Delete Changeset",
    buttons: {
      "Delete Changeset": function() {
        show_ajax_loader(this);
        $.post("/changeset/destroy/"+changeset_id, 
          $(this).find("form").serialize(),
          function(data, textStatus, jqXHR) {
            $(this).dialog('close');
            if (data.status == "ok") {
              location.href = "/review_events/"+review_id;
            }
            else {
              display_error(data.errors);
            }
          }, "json");
      },
      "Cancel": function() {
        $(this).dialog('close');
      }
    },
    open: function() {
      hide_ajax_loader(this);
    }
  });
}

function submit_changeset_status(changeset_id, accepted) {
  var statusText = accepted ? "Accept" : "Reject";
  var buttons = {};
  buttons[statusText] = function() {
    show_ajax_loader(this);//$("#status-changeset-dialog").dialog('widget')[0]);
    $.post("/changeset/status", { 
        changeset_user_status: {
          changeset_id: changeset_id,
          accepted: accepted
        }
      },
      function(data, textStatus, jqXHR) {
        $(this).dialog('close');
        if (data.status == "ok") {
          location.reload();
        }
        else {
          display_error(data.errors);
        }
    }, "json");
  };
  buttons["Cancel"] = function() {
    $(this).dialog('close');
  };
  $("#status-changeset-dialog .dialog-content").
      html("Are you sure you wish to "+
      statusText.toLowerCase()+" this changeset?");
  $("#status-changeset-dialog").dialog({
    modal: true,
    title: "Update Status",
    buttons: buttons,
    open: function() {
      hide_ajax_loader(this);
    }
  });
}

function delete_changeset_status(status_id) {
  $.ajax({
    url: "/changeset/status/"+status_id,
    type: "DELETE",
    dataType: "json",
    success: function (msg) {
      location.reload();
    }
  });
}

function remove_review_event(loc, event_id) {
  $("#remove-review-dialog").dialog({
    modal: true,
    title: "Remove Review Event",
    buttons: {
      "Remove": function() {
        show_ajax_loader(this);
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
      },
      "Cancel": function() {
        $(this).dialog('close');
      }
    },
    open: function() {
      hide_ajax_loader(this);
    }
  });
}

function next_comment(loc) {
  var min = -1;
  var minitem = null;
  var nextitem = null;
  var wtop = $(window).scrollTop();
  $(".comment").each(function() {
    var itop = $(this).offset().top;
    var diff = wtop - itop;
    diff = parseInt(diff, 10);
    if (diff >= -30) {
      return true;
    }
    nextitem = minitem;
    minitem = this;
    if (nextitem != null) {
      return false;
    }
  });
  if (nextitem != null) {
    $.scrollTo(nextitem, {axis: 'y', offset:-30});
  }
}

function prev_comment(loc) {
  var min = -1;
  var minitem = null;
  //var previtem = null;
  var wtop = $(window).scrollTop();
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
    $.scrollTo(minitem, {axis: 'y', offset:-30});
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
    //if (diff < min || min == -1) {
      //min = diff;
      //previtem = minitem;
      minitem = this;
    //}
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
      //if (diff < min || min == 0) {
      //  min = diff;
        minitem = this;
      //}
    });
    if (minitem != null) {
      $("#awesome-bar").slideDown();
      var title = $(minitem).children('h1').children(".filename").text();
      $("#awesome-bar .contents .filename").html(title);
    }
    else {
      $("#awesome-bar").slideUp();
    }
    file_index = index;
  });
}


