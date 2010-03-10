function add_file_table_click_handling() {
  $('.file_table .drag_box').bind('click', function(e) {
    if (e.shiftKey)
      file_table_shift_click_handling($(this));
    else if (e.ctrlKey)
      file_table_strg_click_handling($(this));
    else
      file_table_click_handling($(this));
  });
  remove_file_table_link_click_handling();  
}

// add_file_table_click_handling() adds click a handler to the div
// this div happens to contain links. those links should not emulate (reach down, bubble) a click on the div.
// so we clear the event queue for those links
function remove_file_table_link_click_handling() {
  $('.file_table .drag_box a').bind("click", function(e) { clearEventQueue(e) });
}

function file_table_click_handling(row) {
  toggle_row_activation(row.attr('id'));
}

function file_table_strg_click_handling(row) {
  toggle_row_activation(row.attr('id'), false);
}

function file_table_shift_click_handling(row) {
  var last_row_activation = $('#wd_container').data('last_row_activation');
  if (!last_row_activation || last_row_activation == undefined)
    return;

  var click = parseInt(row.attr('id').substring(1));
  var lastclick = parseInt($('#wd_container').data('last_row_activation').substring(1));
  var start, end, index, row_id;

  if (click < lastclick) {
    start = click;
    end = lastclick;
  } else {
    start = lastclick;
    end = click;
  }

  $('.file_table .drag_box').each(function() {
    row_id = $(this).attr('id');
    index = parseInt(row_id.substring(1));
    if (index >= start && index <= end && index != lastclick)
      toggle_row_activation(row_id, false);
  });

  $('#wd_container').data('last_row_activation', false);
}

function reset_row_activation(reset) {
  if (!reset)
    return;

  get_selected_elements().each(function() {
    $(this).removeClass('active');
  });
  $('#selection_operation_buttons').hide();
}

function toggle_row_activation(row_id, reset) {
  if (reset == undefined)
    reset = true;

  var row = $('#' + row_id);
  if (row.hasClass('active')) {
    reset_row_activation(reset);
    row.removeClass('active');
    $('#wd_container').data('last_row_activation', false);
  } else {
    reset_row_activation(reset);
    if ($.trim(row.text()) != '..')
      row.addClass('active');
    $('#wd_container').data('last_row_activation', row_id);
  }

  var selected_element_count = get_selected_elements().length;
  if (selected_element_count > 0) {
    $('#selection_operation_buttons').show();
    $('#delete_selection_count').html(selected_element_count);
  } else
    $('#selection_operation_buttons').hide();
}


function delete_selected_files() {
  var directories = new Array();
  var files = new Array();
  var text;

  $('.file_table .active .directory').each(function() {
    text = $(this).text();
    if (text != '')
      directories.push(text);
  });

  $('.file_table .active .file').each(function() {
    text = $(this).text();
    if (text != '')
      files.push(text);
  });


  var params = '';
  params += 'pallet_id=' + PALLET_ID;
  params += '&sub_path=' + encodeURIComponent(SUB_PATH);
  params += '&selected_directories=' + escape($.toJSON(directories));
  params += '&selected_files=' + escape($.toJSON(files));
  params += '&operation=delete';
  params += '&' + encodeURIComponent(AUTH_TOKEN_PARAM);

  var url = '/pallets/collection_operation/' + PALLET_ID;

  document.location = url + '?' + params;
}


function get_selected_elements() {
  return $('.file_table .active');
}

function get_element_text(element_id) {
  return ($('#' + element_id + ' .file' + ', #' + element_id + ' .directory').text());
}


/*
 * drag and drop
 */

function set_drop_stack_hover(status) {
  if (status == 'enable') {
    $('#drop_stack, #drop_stack_hover_helper').hover(
            function() {
              /* first delete queue to prevent hover over/out trigger
               * when the mouse is passing from one the the other element
               */
              $('#drop_stack').queue("fx", []);
              $('#drop_stack').animate({ top: "53px" }, 200);
            },
            function() {
              $('#drop_stack').queue("fx", []);
              $('#drop_stack').animate({ top: "-244px" }, 200);
            }
            );
  } else if (status == 'disable') {
    $('#drop_stack, #drop_stack_hover_helper').unbind();
  }
}

function file_table_drag() {
  $('#wd_container .drag_box').draggable({
    start: function(event, ui) {
      //alert('start drag');
      set_drop_stack_hover("disable");
      $('#drop_stack').animate({ top: "53px" }, 200);
    },
    refreshPositions: true,
    helper: function() {
      return file_table_drag_helper(this);
    },
    distance: 6,
    cursorAt: { left: -5, bottom: -5 },
    stop: function() {
      set_drop_stack_hover('enable');
      $('#drop_stack').delay(500).animate({ top: "-244px" }, 200);
    }
  });
}


function file_table_drop() {
  $('#drop_stack_area').droppable({
    tolerance: 'touch',
    drop: function(event, ui) {
      drop_handling(event, ui);
    }
  });
}

function get_drag_div(element) {
  var element_id = $(element).attr('id');
  var text = get_element_text(element_id);
  var img_src = $('#' + element_id + ' img').attr('src');

  return '<div class="drag_helper_item"><img src="' + img_src + '"> ' + text + '</div>'
}

function file_table_drag_helper(element) {
  var drag_helper_div = '';
  var selected_elements = get_selected_elements();

  // if some elements are selected drag them
  if (selected_elements.length > 0) {
    selected_elements.each(function() {
      drag_helper_div += get_drag_div(this);
    });
    // drag element under pointer
  } else
    drag_helper_div += get_drag_div(element);

  drag_helper_div = '<div id="drag_helper">' + drag_helper_div + '</div>';

  $('#drag_helper').remove();
  $('body').append(drag_helper_div);

  return $('#drag_helper');
}

function collect_into_directory_and_file_list(element, file_directory_list) {
  var element_id = $(element).attr('id');
  var text;

  $('#' + element_id + ' .directory').each(function() {
    text = $(this).text();
    if (text != '')
      file_directory_list[0].push(text);
  });

  $('#' + element_id + ' .file').each(function() {
    text = $(this).text();
    if (text != '')
      file_directory_list[1].push(text);
  });

  return file_directory_list;
}

function drop_handling(event, ui) {

  $('#drop_stack').queue("fx", []);

  var file_directory_list = [
    [],
    []
  ];
  var elements = [];
  var selected_elements = get_selected_elements();

  if (selected_elements.length > 0) {
    selected_elements.each(function() {
      elements.push(get_drag_div(this));
      file_directory_list = collect_into_directory_and_file_list(this, file_directory_list);
    });
  } else {
    elements.push(get_drag_div(ui.draggable));
    file_directory_list = collect_into_directory_and_file_list(ui.draggable, file_directory_list);
  }

  reset_row_activation(true);

  $('#drop_stack_area').append(elements.join("\n"));
  collect_selected_files(file_directory_list[0], file_directory_list[1]);
}

function collect_selected_files(directories, files) {
  var text;

  var params = '';
  params += '&pallet_id=' + PALLET_ID;
  params += '&sub_path=' + encodeURIComponent(SUB_PATH);
  params += '&selected_directories=' + encodeURIComponent($.toJSON(directories));
  params += '&selected_files=' + encodeURIComponent($.toJSON(files));
  params += '&operation=collect';
  params += '&' + encodeURIComponent(AUTH_TOKEN_PARAM);

  var url = '/pallets/collection_operation/' + PALLET_ID;

  drop_stack_indicator('enable');
  
  $.ajax({
    url: url,
    data: params,
    success: function(data) {
      $('#drop_stack_area').html(data);
      stack_size = $('#drop_stack_area div').size();
      $('#drop_stack_size').html(stack_size);
      $('#drop_stack').delay(200).animate({ top: "-244px" }, 200);
      if (data != '') {
        set_stack_action_status('enable');
      }
    }
  })
}

function drop_stack_indicator(status){
  if ($.support.opacity) { // this will most likely exclude IE, but else strange stuff will occur
    if (status == 'enable') {
      $('#drop_stack_listel, #drop_stack .drop_stack_listel_bordure').animate({ opacity: 0.2 }, 200);
      $('#drop_stack_listel, #drop_stack .drop_stack_listel_bordure').animate({ opacity: 1 }, 200, false, drop_stack_indicator);
    }
    else {
      $('#drop_stack, #drop_stack .drop_stack_listel_bordure').queue("fx", []);
      $('#drop_stack, #drop_stack .drop_stack_listel_bordure').css({ "opacity": 1 });
    }
  }
  else {
    // IE Animation. pulsate?
  }
}

function collection_clear() {
  drop_stack_indicator('enable');

  var params = '';
  params += '&pallet_id=' + PALLET_ID;
  params += '&sub_path=' + SUB_PATH;
  params += '&operation=clear';
  params += '&' + AUTH_TOKEN_PARAM;

  var url = '/pallets/collection_operation/' + PALLET_ID;
  $.ajax({
    url: url,
    data: params,
    success: function(data) {
      $('#drop_stack_area').html('');
      stack_size = $('#drop_stack_area div').size();
      $('#drop_stack_size').html(stack_size);
      set_stack_action_status('disable');
    }
  })
}

function zip_selected_files() {
  var zip_filename = $('#zip_filename').attr('value');

  if ($.trim(zip_filename) == '')
    return;

  $('#collection_zip_loader').show();

  var params = '';
  params += '&pallet_id=' + PALLET_ID;
  params += '&sub_path=' + encodeURIComponent(SUB_PATH);
  params += '&zip_filename=' + encodeURIComponent(zip_filename);
  params += '&operation=zip';
  params += '&' + encodeURIComponent(AUTH_TOKEN_PARAM);

  var url = '/pallets/collection_operation/' + PALLET_ID;

  document.location = url + '?' + params;
}

function collection_paste() {
  var params = '';
  params += '&pallet_id=' + PALLET_ID;
  params += '&sub_path=' + SUB_PATH;
  params += '&operation=copy';
  params += '&' + AUTH_TOKEN_PARAM;

  var url = '/pallets/collection_operation/' + PALLET_ID;

  document.location = url + '?' + params;
}

function collection_move() {
  var params = '';
  params += '&pallet_id=' + PALLET_ID;
  params += '&sub_path=' + encodeURIComponent(SUB_PATH);
  params += '&operation=move';
  params += '&' + encodeURIComponent(AUTH_TOKEN_PARAM);

  var url = '/pallets/collection_operation/' + PALLET_ID;

  document.location = url + '?' + params;
}
function set_stack_action_status(status) {
  if (status == 'disable') {
    $('#drop_stack_actions a').each(function() {
      var t = $(this);
      t.unbind("click");
      t.addClass('ui-state-disabled');
    });
  } else {

    $('#bt-collection_paste').click(function(){ collection_paste(); });
    $('#bt-collection_move').click(function(){ collection_move(); });
    $('#bt-collection_zip').click(function(){ $('#collection_zip').dialog('open'); });
    $('#bt-collection_clear').click(function(){ collection_clear(); });
    $('#drop_stack_actions a').each(function() {
      $(this).removeClass('ui-state-disabled');
    });
  }
}
