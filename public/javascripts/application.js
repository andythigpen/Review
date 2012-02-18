
$(document).ready(function() {
  setup_profile_popups();
  setup_tooltips();
});

function setup_profile_popups() {
  $(".username").popover({
    html: true
  });
}

function setup_tooltips() {
  $(".tooltip").tooltip();
}

function display_error(error) {
  $(".modal").modal('hide');
  $("#error-dialog .dialog-content > p").html(error);
  $("#error-dialog").modal('show');
}

function show_ajax_loader(dialog_widget) {
  $(dialog_widget).find('.dialog-content').css('opacity', '0.2');
  $(dialog_widget).find('.ajax-loader').fadeIn();
  // disable non "Cancel" or "Close" buttons
  var buttons = $(dialog_widget).find(".btn");
  for (var i = 0; i < buttons.length; i++) {
    var button = $(buttons[i]);
    if (! button.attr('data-dismiss')) {
      if (button.data("events")) {
        button.data("save-click-events", button.data("events").click).
            unbind('click');
      }
      button.data("save-href", button.attr("href")).
          data("save-onclick", button.attr("onclick"));
      button.removeAttr("href").removeAttr("onclick");
      button.addClass("disabled");
    }
  }
}

function hide_ajax_loader(dialog_widget) {
  $(dialog_widget).find('.dialog-content').css('opacity', '1.0');
  $(dialog_widget).find('.ajax-loader').hide();
  var buttons = $(dialog_widget).find(".btn");
  for (var i = 0; i < buttons.length; i++) {
    var button = $(buttons[i]);
    if (! button.attr('data-dismiss')) {
      var handlers = button.data("save-click-events");
      if (handlers) {
          for (var obj in handlers) {
              button.bind('click', obj.handler);
          }
      }
      button.attr("href", button.data("save-href"));
      button.attr("onclick", button.data("save-onclick"));
      button.removeData("save-href").removeData("save-onclick").
          removeData("save-click-events").removeClass("disabled");
    }
  }
}

