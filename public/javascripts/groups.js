function remove_group(group_id) {
  hide_ajax_loader("#remove-group-dialog");
  $("#remove-group-dialog").data("group-id", group_id).modal('show');
  // $("#remove-group-dialog").dialog({
  //   modal: true,
  //   title: "Remove Group",
  //   buttons: {
  //     "Remove": function() {
  //       show_ajax_loader(this);
  //       $.ajax({
  //         url: "/groups/"+group_id,
  //         type: "DELETE",
  //         dataType: "json",
  //         success: function(msg) {
  //           $('#remove-group-dialog').dialog('close');
  //           if (msg.status == "ok") {
  //             window.location.href = "/groups";
  //           }
  //         }
  //       });
  //     },
  //     "Cancel": function() {
  //       $(this).dialog('close');
  //     }
  //   },
  //   open: function() {
  //     hide_ajax_loader(this);
  //   }
  // });
}

function remove_group_modal() {
  show_ajax_loader("#remove-group-dialog");
  var group_id = $("#remove-group-dialog").data("group-id");
  $.ajax({
    url: "/groups/"+group_id,
    type: "DELETE",
    dataType: "json",
    success: function(msg) {
      $('#remove-group-dialog').modal('hide');
      if (msg.status == "ok") {
        window.location.href = "/groups";
      }
    }
  });
}
