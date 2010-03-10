/*
 * I18n translations for buttons of modal dialogs
 *
 * Usage: Just put I18n.modal_dialog_buttons() around modal buttons definition object.
 *
 * Dependencies: i18n.js (Rails i18n-js plugin)
 *
 */

I18n.modal_dialog_buttons = function (button_definition) {
  var buttons = {};
  jQuery.each(button_definition, function(key, value) {
    buttons[I18n.t(key)] = value;
  });
  return buttons;
}

