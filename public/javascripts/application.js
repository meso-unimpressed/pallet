$(function(){
  init_hover_states();
  init_flyout_menus();

  init_qtips();

  add_file_table_click_handling();

  set_drop_stack_hover('enable');
  file_table_drag();
  file_table_drop();

  $('#bt-switch-pallet').bind('click', function() { $('#bt-switch-pallet').qtip('destroy'); });
});

function init_hover_states() {
	//hover states on the static widgets

	$('.button, .button-icon-text, .button-text-icon, .ui-button').hover(
		function() { $(this).addClass('ui-state-hover'); },
	  function() { $(this).removeClass('ui-state-hover'); }
	);
  
}


/*
 * MENUS 	
 * http://www.filamentgroup.com/lab/jquery_ipod_style_and_flyout_menus/
 */
function init_flyout_menus() {
  $('#bt-switch_pallet').menu({ 
    content: $('#bt-switch_pallet').next().html(), // grab content from this page
    width: 200,
    maxheight: 300,
    showSpeed: 200 
  });
  $('#bt-pallet-settings').menu({ 
    content: $('#bt-pallet-settings').next().html(), // grab content from this page
    width: 200,
    maxheight: 300,
    showSpeed: 200 
  });
  $('#bt-system').menu({
    content: $('#bt-system').next().html(), // grab content from this page
    width: 200,
    maxheight: 300,
    showSpeed: 200 
  });

  // destroy tooltip on click, to prevent overlapping of menu and tooltip
  $('#bt-switch_pallet').bind('click', function() {
    $('#bt-switch_pallet').qtip('destroy');
  });
  // hide tooltip on click, to prevent overlapping of menu and tooltip
  $('#bt-pallet-settings').bind('click', function() {
    $('#bt-pallet-settings').qtip('hide');
  });
  $('#bt-system').bind('click', function() {
    $('#bt-system').qtip('hide');
  });

}

function permalink_format(string) {
  var permalink_value = string.toLowerCase();
  // spaces to underscores
  permalink_value = permalink_value.replace(/\s/g, '_');
  // german special chars to non special char correlation
  permalink_value = permalink_value.replace(/ä/g, 'ae');
  permalink_value = permalink_value.replace(/ö/g, 'oe');
  permalink_value = permalink_value.replace(/ü/g, 'ue');
  permalink_value = permalink_value.replace(/ß/g, 'ss');
  // only keep lower case letters (a-z), numbers and underscores
  permalink_value = permalink_value.replace(/[^a-z0-9_\.\-]*/g, '');
  // remove all double underscores
  permalink_value = permalink_value.replace('__', '_');
  permalink_value = permalink_value.replace('__', '_');
  return permalink_value;
}

function id_exists(id) {
  return $('#' + id).length > 0;
}

/*  stops event bubbling
 *  example:
 *    if you define a click handler for an element A and a second
 *    click handler for an element B being placed above/inside A,
 *    then you may want to call this function inside B's click handler
 *    to prevent A's click handler being triggered after B's handler
 *    ('event' is defined when calling this inside html onclick param)
 */
function clearEventQueue(event) {
  if((event == undefined) || (event == null)) return;

  if (event.stopPropagation) {  // real browsers
    event.stopPropagation();
  }
  else {  // IE
    event.cancelBubble = true;
  }
}
