/*
 * jquery ui
 */
$(function(){
	// tabs
	$("#wd_tabs").tabs();
    
	//hover states on the static widgets
	$('.button, .button-icon-text, .button-text-icon, .ui-button').hover(
		function() { $(this).addClass('ui-state-hover'); },
		function() { $(this).removeClass('ui-state-hover'); }
	);
    /*
     * drop stack
     */
    $('#drop_stack').hover(
        function() {
            $('#drop_stack').animate({ top: "0px"}, 200);
        },
        function(){
            $('#drop_stack').animate({ top: "-187px" }, 200);  
        }
    );
	$('#bt-new-directory').click(function() {
		$('#new-directory').dialog('open');
	});
	$('#bt-share').click(function() {
		$('#share').dialog('open');
        return false;
	});
	$('#bt-upload').click(function() {
		$('#upload').dialog('open');
	});
	$("#new-directory").dialog({
			autoOpen: false,
			height: 200,
			width: 400,
			modal: true,
			buttons: {
				Cancel: function() {
					$(this).dialog('close');
				},
				Create: function() {
          $('#submit_button_new_directory').click();
				}
			},
			close: function() {

			}
		});
	$("#upload").dialog({
			autoOpen: false,
			height: 200,
			width: 400,
			modal: true,
			buttons: {
				Cancel: function() {
					$(this).dialog('close');
				},
				Upload: function() {
          $('#submit_button_file_upload').click();
				}
			},
			close: function() {

			}
		});

	$("#share").dialog({
			autoOpen: false,
			height: 200,
			width: 400,
			modal: true,
			buttons: {
				Cancel: function() {
					$(this).dialog('close');
				},
				Create: function() {
					$(this).dialog('close');
				}
			},
			close: function() {

			}
		});


    /*
     * MENUS 	
     * http://www.filamentgroup.com/lab/jquery_ipod_style_and_flyout_menus/
     */
		$('#bt-switch_pallet').menu({ 
			content: $('#bt-switch_pallet').next().html(), // grab content from this page
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
});

