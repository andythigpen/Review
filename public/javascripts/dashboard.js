// called via script in dashboard.erb.html
function setup_dashboard() {
  // dashboard inbox/outbox filters
  $(".filter").live('ajax:beforeSend', function(e, xhr, settings) {
    $.history.load($(this).attr('data-filter'));
    return false;
  });

  $(".pagination a").live('ajax:beforeSend', function(e, xhr, settings) {
    var page = settings.url.split("page=")[1];
    if (page === undefined) {
      page = "1";
    }
    $.history.load($('#dashboard-left li.active > a').attr('data-filter')+","+page);
    return false;
  });
  /*.live('ajax:success', function(xhr, data, status) {
    // $("#dashboard-right-contents").html(data);
    // $("#dashboard-right-loading").fadeOut();
    // $.history.load($('li.active > a').attr('data-filter')+",page=1");
  });*/

  $.history.init(function(hash) {
    $("#dashboard-right-loading").fadeIn();
    if (hash == "") {
      // initialize...
      $.history.load("inbox");
    } else {
      // $("#dashboard-right-contents").load("/dashboard/"+hash, function(response, text, xhr) {
      var page_array = hash.split(',');
      var url = "/dashboard/"+page_array[0];
      if (page_array[1] !== undefined) {
        url += "?page=" + page_array[1];
      }
      $.getScript(url, function(data, status) {
        $("#dashboard-right-loading").fadeOut();
        // $(".filter").parents("li").removeClass("active");
        $('[data-filter]').closest("li").removeClass("active");
        $('[data-filter="'+page_array[0]+'"]').closest("li").addClass("active");
      });
    }
  },
  { 
    unescape: ",/" 
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
              var prevBg = $(loc).parents(".review-event").css('backgroundColor');
              $(loc).parents(".review-event").animate({
                'opacity': 0,
              }, function() {
                var msg = "Review removed.";
                $(this).html('<td colspan="5"><span class="ui-icon ui-icon-close inline-icon" style="margin-right:0.3em"></span>'+msg+'</td>');
                $(this).animate({
                    'opacity': 1.0,
                    'color': '#777',
                });
              });
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
