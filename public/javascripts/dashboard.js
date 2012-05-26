// called via script in dashboard.erb.html
function setup_dashboard() {
  // dashboard inbox/outbox filters
  $(".filter").live('ajax:beforeSend', function(e, xhr, settings) {
    $.history.load($(this).attr('data-filter'));
    $("#search-txt").val("");
    return false;
  });

  $(".pagination a").live('ajax:beforeSend', function(e, xhr, settings) {
    var url = settings.url;
    var params = url.match(/(([^_?&]\w+)=\w+)/g);
    if (params == null) {
      params = [];
    }
    var name = url.match(/\/dashboard\/(\w+)/)[1];
    $.history.load(name+","+params.join(","));
    return false;
  });

  $.history.init(function(hash) {
    if (hash == "") { // initialize...
      $.history.load("inbox");
    } else {
      load_hash(hash);
    }
  },
  { 
    unescape: ",/" 
  });

  $("#search-txt").keypress(function(ev) {
    if (ev.which == 13) {
      $("#search-form").submit();
      ev.preventDefault();
      return false;
    }
  });
  $("#search-btn").click(search);
  $("#search-form").submit(search);
  $("#clear-search-btn").click(clear_search);
  $("#refresh-btn").click(function () {
    var hash = location.hash.replace('#','');
    hash = decodeURIComponent(hash);
    load_hash(hash);
    return false;
  });
}

function load_hash(hash) {
  $("#dashboard-right-loading").fadeIn();
  var page_array = hash.split(',');
  var url = "/dashboard/"+page_array[0];
  if (page_array.length > 1) {
    url += "?";
    for (var ii = 1; ii < page_array.length; ii++) {
      url += "&" + page_array[ii];

      // this sets the text in the search field for page reloads
      var keyvalue = page_array[ii].split('=');
      if (keyvalue[0] == "q") {
        $("#search-txt").val(keyvalue[1]);
      }
    }
  }
  $.getScript(url, function(data, status) {
    $("#dashboard-right-loading").fadeOut();
    $('[data-filter]').closest("li").removeClass("active");
    $('[data-filter="'+page_array[0]+'"]').closest("li").addClass("active");
  });
}

function remove_review_event_modal() {
  show_ajax_loader("#remove-review-dialog");
  var event_id = $("#remove-review-dialog").data("event-id");
  var loc = $("#remove-review-dialog").data("loc");
  $.ajax({
    url: "/review_events/"+event_id,
    type: "DELETE",
    dataType: "json",
    success: function(data) {
      if (data.status == "ok") {
        location.reload();
      }
      else {
        display_error(data.errors);
      }
    }
  });
}

function remove_review_event(loc, event_id) {
  hide_ajax_loader("#remove-review-dialog");
  $("#remove-review-dialog").data("event-id", event_id).
    data("loc", loc).modal('show');
}

var template_type = 'inbox';

function search(ev) {
  var query = $("#search-txt").val();
  $.history.load("search,q="+query+",filter="+template_type);
  return false;
}

function clear_search() {
  $.history.load(template_type);
  $("#search-txt").val("");
  return false;
}
