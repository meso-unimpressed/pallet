$(function(){
  $("#user_association_dialog").dialog({
    autoOpen: false, modal: true,
    width: 590, height: 400,
    bgiframe: BGIFRAME,
      buttons: I18n.modal_dialog_buttons({
        close: function() { $(this).dialog('close'); }
      }),
      close: function() { }
  });

  $("#role_association_dialog").dialog({
      autoOpen: false, modal: true,
      width: 590, height: 400,
      bgiframe: BGIFRAME,
      buttons: I18n.modal_dialog_buttons({
        close: function() { $(this).dialog('close'); }
      }),
      close: function() { }
  });
});
