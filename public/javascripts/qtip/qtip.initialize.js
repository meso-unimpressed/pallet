/*
 * Wrapper for qTip initialisation
 *
 * Reads tooltip attribute from all elements and creates qTips for them.
 * Attribute tooltip_opt is compatible to qTip options object and will be parsed and merged into default options.
 *
 * Example:
 * <a href="test.html" tooltip="Hello" tooltip_opt="{ show: { delay: 500 } }">Test</a>
 *
 * For modal dialogs or under some circumstances it might be useful to skip initialisation for elements and
 * initilise those elements on special events. Use the skip_init option set to true, to have elements not initialized
 * automatically. Use init_qtips() with a special scope (i.e. element id) to initialize this element manually.
 *
 * Dependencies:
 * - jquery.qtip for basic functionallity
 * - qtip.themerollers for themed tool tips
 * - jquery.json-1.3 for parsing tooltop_opt options string
 *
 */


/*$(function(){
  init_qtips();
});*/

function init_qtips(scope) {
  var default_scope = '[tooltip]';
  var default_options;
  var options;

  if (scope == undefined)
    scope = default_scope;

  $(scope).each(function() {
    // default tool top options (if defined on a higher level, $.extend() seems to change this parameter, even if not used as target)
    default_options = {
                         content: { title: '', text: '' },
                         show: { delay: 140, solo: false },
                         //hide: { fixed: true }, // stay visible when mouse moves over tool tip
                         //hide: { when: 'unfocus' },
                         position: {
                           corner: {
                             target: 'bottomMiddle',
                             tooltip: 'topMiddle'
                           }
                         },
                         style: {
                           name: 'themeroller',
                           tip: true
                         }
                      };
    options = default_options;
    var element = $(this);
    var tooltip_text = element.attr('tooltip');
    if (tooltip_text.length > 0) {
      //debug(tooltip_text + ' - ' + tooltip_text.length);
      
      // use attributes from html qtip_opt
      var tooltip_options = element.attr('tooltip_opt');
      if (tooltip_options != undefined && tooltip_options != '') {
        //debug(tooltip_options);
        tooltip_options = $.evalJSON(tooltip_options);

        // automatically hide tooltip after specified time
        if(tooltip_options.auto_hide != undefined)
          window.setTimeout(function() { element.qtip('hide'); }, parseInt(tooltip_options.auto_hide));

        // merge default options with individual tooltip options
        $.extend(true, options, default_options, tooltip_options);
      }

      // set tooltip text
      options.content.text = tooltip_text;
      
      if (options.content.title.length < 1 || options.content.title == '')
        options.content.title = undefined;

      // if skip_init is set to true, this tooltip will not be initialized automatically.
      // it will be initialized, if an specific scope is used.
      // useful to i.e. initialize tooltips in modal dialogs
      if (tooltip_options == undefined || (!tooltip_options.skip_init && scope == default_scope) || scope != default_scope) {
        $(this).qtip(options);
      } else {
        //debug('IGNORED');
      }
    }
  });
}
