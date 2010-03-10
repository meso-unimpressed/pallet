/*
 * This function replaces built-in confirm dialogs by styled jQuery modal dialogs.
 *
 * The built-in confirm dialog gets deactivated to return false always.
 * To all links containing a call to confirm() in onlick attribute, will be attached another click handler.
 *
 * WARNING: This may fail on some advanced confirm handlings, especially if waiting for a confirm to do
 *          something else than preventing link target being accessed.
 *          Rails link_to_remote with confirm should work anyway.
 *
 *
 * How to use:
 * Just load this script in the document header, all confirms will be handled modal then.
 *
 * If new links with confirm are created in the DOM i.e. by Ajax, modalize_confirm_links() has to be called again.
 *
 */

// overwrite built-in confirm method to do nothing (return false always)
window.confirm = function() { return false; };

// remember link, update text for confirm dialog, show confirm dialog
function modal_confirm(message, href, ajax) {
  $("#confirm_dialog").data('href', href);
  $("#confirm_dialog").data('ajax', ajax);
  $('#confirm_dialog').text(message);
  $('#confirm_dialog').dialog('open');
}

// sets additional on click handler to use modal confirm instead of built-in
function modalize_confirm_links(scope) {
  if (scope == undefined)
    scope = '';

  $(scope + " a").each(function() {
    if (!$(this).data('modalized_confirm_link')) {
      var onclick = $(this).attr('onclick') + ' ';
      if (onclick.indexOf('confirm(') != -1 && onclick.indexOf('modal_confirm(') == -1) {
        var href = $(this).attr('href');

        onclick = onclick.substring(onclick.indexOf('{') + 1, onclick.lastIndexOf('}') - 1);

        var ajax = onclick;
        ajax = ajax.substring(ajax.indexOf('jQuery.ajax('));
        ajax = ajax.substring(0, ajax.indexOf('})') + 2);
        ajax = ajax.replace(/\n/, '');

        var msg = onclick;
        msg = msg.substring(msg.indexOf('confirm(') + 9);
        msg = msg.substring(0, msg.indexOf(')') - 1);
        msg = sanitize_utf8_chars(msg);
        $(this).click(function() { modal_confirm(msg, href, ajax); });

        $(this).data('modalized_confirm_link', true);
      }
    }
  });
}

$(function() {
  // set modal confirm dialog for all links requiring confirmation
  modalize_confirm_links();

  // append dialog container before closing body
  //$("body").append('<div id="confirm_dialog" title="Please confirm" style="display:none">Are you sure?</div>');
  $("body").append('<div id="confirm_dialog" title="' + I18n.t('please_confirm') + '" style="display:none">' + I18n.t('are_you_sure') + '</div>');

  // initialize dialog
  $("#confirm_dialog").dialog({
    autoOpen: false,
    modal: true,
    buttons: I18n.modal_dialog_buttons({
      cancel: function() { $(this).dialog('close'); },
      ok: function() {
        $(this).dialog('close');
        if ($("#confirm_dialog").data('href') != '' && $("#confirm_dialog").data('href') != undefined)
          self.location = $("#confirm_dialog").data('href');
        eval(($("#confirm_dialog").data('ajax')));
      }
    })
  });
});

// sanitizes encoded UTF8 chars in given string by decoeded ones
function sanitize_utf8_chars(str) {
  var mapping = [ [/\\xC4/, 'Ä'], [/\\xE4/, 'ä'],
                  [/\\xD6/, 'Ö'], [/\\xF6/, 'ö'],
                  [/\\xDC/, 'Ü'], [/\\xFC/, 'ü'],
                  [/\\xDF/, 'ß'], [/\\xE8/, 'è'],
                  [/\\xB0/, '°']
                ];

  $(mapping).each(function() {
    str = str.replace(this[0], this[1]);
  });

  return str;
}
