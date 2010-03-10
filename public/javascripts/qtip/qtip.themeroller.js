// Inspired by: http://craigsworks.com/projects/qtip/forum/topic/254/external-styling-via-css-instead-of-javascript/

$.fn.qtip.styles['defaults'].background=undefined;
$.fn.qtip.styles['defaults'].color=undefined;
$.fn.qtip.styles['defaults'].tip.background=undefined;
$.fn.qtip.styles['defaults'].title.background=undefined;
$.fn.qtip.styles['defaults'].title.fontWeight = undefined;

$(function(){
  var borderRadius = parseInt(getCSS('.tooltip-radius','borderWidth'));
  var borderWidth = parseInt(getCSS('.tooltip','borderWidth'));
  var borderColor = getCSS('.tooltip','borderColor');
  var minWidth = parseInt(getCSS('.tooltip','minWidth'));
  var maxWidth = parseInt(getCSS('.tooltip','maxWidth'));
  
  $.fn.qtip.styles.themeroller = {
     border: {
         width: borderWidth,
         radius: borderRadius,
         color: borderColor
     },
     classes: {
         tooltip: 'ui-widget',
         tip: 'ui-widget',
         title: 'ui-widget-header',
         content: 'ui-widget-content'
     },
     width: {
         min: minWidth,
         max: maxWidth
     }
  };
});
