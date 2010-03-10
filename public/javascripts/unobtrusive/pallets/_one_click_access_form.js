function initialize_date_picker(language) {
  $(function() {
    var dp = $('#date_picker');

    dp.datepicker({
      numberOfMonths: 2,
      dateFormat: 'yy-mm-dd',
      regional: '<%= current_user.language -%>',
      onSelect: function(dateText, inst){
        $('#pallet_one_click_access_expires_at').val(dateText + " 23:59:59")
      }
    });
    $.datepicker.setDefaults($.extend($.datepicker.regional['']));

    if (language == 'en')
      $.datepicker.setDefaults($.extend($.datepicker.regional[language]));

    dp.datepicker('setDate', '+1d');

    $('#pallet_one_click_access_expires_at').val($.datepicker.formatDate("yy-mm-dd", dp.datepicker("getDate")) + " 23:59:59");

    init_qtips('#one_click_access [tooltip]');
  });
}

function enable_oca_file_download() {
  $(function() {
    var selection = $('#wd_container div.active a.file'); // selected filetable divs
    if (selection.length == 1) {                          // if exactly one item is selected
      $('#oca_download').removeClass('inactive');         // remove opacity
      $('#pallet_one_click_access_download').enable();    // enable checkbox

      var selected_filename = $('#wd_container div.active a.file').html(); // retrieve filename from dom
      $('#pallet_one_click_access_download').attr('value', selected_filename);
      $('#pallet_one_click_access_download_filename').html('(' + selected_filename + ')');
    }
  });
}
