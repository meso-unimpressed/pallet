
function init_action_container_top_handlers(pallet_id, sub_path) {
  $('#bt-new-directory').click(function() {
    $('#new-directory').dialog('open');
    $('#dir_name').focus();
    return false;
  });


  $('#bt-upload').click(function() {
    $('#upload').dialog('open');
    return false;
  });


  $("#new-directory").dialog({
    autoOpen: false, modal: true,
    width: 400, height: 140,
    bgiframe: BGIFRAME,
    buttons: I18n.modal_dialog_buttons({
      cancel: function() { $(this).dialog('close'); },
      create: function() { $('#submit_button_new_directory').click() }
    }),
    close: function() { }
  });

  $('#bt-share').click(function() {
    return false;
  });

  $("#upload").dialog({
    autoOpen: false, modal: true,
    width: 520, height: 400,
    bgiframe: BGIFRAME,
    buttons: I18n.modal_dialog_buttons({
      close: function() { 
        $('#uploadify_button_qtip').qtip('hide');
        $(this).dialog('close'); 
      }
    }),
    open: function(event, ui) {
      $("#upload").html('<img src="/images/ajax-loader.gif" />');
      $.get("/pallets/dialog_upload/" + pallet_id + "?sub_path=" + sub_path, function(data) { 
        eval(data);
        window.setTimeout(function() {init_qtips('#uploadify_button_qtip'); }, 1000);
      });
    },
    close: function() {
      document.location.reload();
    }
  });


  $("#one_click_access").dialog({
    autoOpen: false, modal: true,
    width: 490, height: 535,
    bgiframe: BGIFRAME,
    buttons: I18n.modal_dialog_buttons({
      close: function() { 
        $(this).dialog('close'); 
      },
      create: function() { 
        $('#submit_button_one_click_access').click();
      }
    }),
    open: function(event, ui) {
      $("#one_click_access").html('<img src="/images/ajax-loader.gif" />');
      $.get("/pallets/dialog_one_click_access/" + pallet_id + "?sub_path=" + sub_path, function(data) { eval(data); });      
    },
    close: function() { }
  });
  
  $("#collection_zip").dialog({
    autoOpen: false, modal: true,
    width: 400, height: 160,
    bgiframe: BGIFRAME,
    buttons: I18n.modal_dialog_buttons({
      cancel: function() { $(this).dialog('close'); },
      create: function() { zip_selected_files(); }
    }),
    close: function() { }
  });
}
