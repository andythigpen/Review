
$(document).ready(function() {
  setup_buttons();
  setup_profile_popups();
  setup_tooltips();
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

function setup_tooltips() {
  $(".tooltip").tipTip({ defaultPosition: "top" });
  $(".tooltip-below").tipTip({ defaultPosition: "bottom" });
  $(".showonload").tipTip('show');
}

function display_error(error) {
  $("#error-dialog").html(error).dialog({
    resizable: false,
    modal: true,
    buttons: { "OK": function() { $(this).dialog("close"); } }
  });
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

