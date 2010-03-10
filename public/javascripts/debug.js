// appends debug container to body and appends debug message on each call
function debug(debug) {
  if (!$('#debug').length > 0)
    $('body').append('<div id="debug" style="display:none; font-family: Courier, monospace;"></div>');
  $('#debug').append(debug + '<br />');
  $('#debug').show();
}