$(function(){
	$("#file_table_element_rename").dialog({
			autoOpen: false,
			height: 135,
			width: 350,
			modal: true,
			buttons: {
				Cancel: function() { $(this).dialog('close'); },
				Rename: function() { 
          $('#submit_button_rename').click(); 
          $(this).dialog('close');
        }
			},
			close: function() {

			}
	});
});

function open_rename_dialog(sub_path, original_name) {
  $('#rename_sub_path').attr('value', sub_path);
  $('#rename_original_filename').attr('value', original_name);
  $('#rename_new_filename').attr('value', original_name);
  $('#file_table_element_rename').dialog('open');
  $('#rename_new_filename').focus();
}


/***** _one_click_access_list.html functions *****/

// creates a clipboard flash movie button and adds fake hover event
function create_clip(button, container, content) {
  var clip = new ZeroClipboard.Client();
  clip.setText(content);
  clip.addEventListener('mouseOver', function(client) { $('#' + button).toggleClass('ui-state-hover'); });
  // change tooltip to "copied!" on mouse click
  clip.addEventListener('onMouseUp', function(client) {
      $('#' + container).qtip("api").updateContent(I18n.t('pallets.one_click_access_list.tip.copied'), true);
      window.setTimeout(function() {
          $('#' + container).qtip('hide');
          window.setTimeout(function() {
              $('#' + container).qtip("api").updateContent(I18n.t('pallets.one_click_access_list.tip.copy'), true);
          }, 800);
      }, 2000);
  });
  clip.glue(button, container);
  return clip;
}

clip_list = Array();

function create_oca_clips() {
  var index = 0;
  var links = $('#oca_list .oca_link a');
  var token_url = '';

  // do nothing if no OCA present
  // NOTE: don't try to query links.length, since OCA help text contains an oca_link ...
  if ($('.oca_tokens').length < 1) { return; }

  //debug(links.length - 1);

  var last_button = $('#oca_clip_button_' + (links.length-1));
  //debug('#oca_clip_button_' + (links.length-1) + ': ' + last_button.width());
  if(last_button.width() == 0) {
    // if last button is not yet DOM-layouted, wait for it - necessary since AJAX seems to not fire .load() events
    window.setTimeout("create_oca_clips()", 100);
  } else {
    links.each(function() {
      token_url = $(this).attr('href');
      //debug(token_url);

      ZeroClipboard.setMoviePath('/javascripts/zero_clipboard/ZeroClipboard.swf');
      clip_list.push(create_clip('oca_clip_button_' + index, 'oca_clip_container_' + index, token_url));
      init_qtips('#oca_clip_container_' + index);

      index++;
    });
  }
}

function init_oca_buttons() {
  $(function() {
    // use "live" for binding the click event, so it persists after ajax reload
    $('#bt-add-oca').live("click", function() {
        $('.qtip').hide();
        $('#one_click_access div.flash_box').hide();
        $('#one_click_access').dialog('open');
        return false;
    });
    init_hover_states();

    create_oca_clips();
  });
}

/***** _one_click_access_list.html functions END *****/
