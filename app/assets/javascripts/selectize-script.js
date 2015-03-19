$(document).on("page:change", function() {
    $('#instruments-field').selectize({
        plugins: ['remove_button'],
        delimiter: ',',
        persist: false,
        create: false
    });

    $('#composers-field').selectize({
        plugins: ['remove_button'],
        delimiter: ',',
        persist: false,
        create: true,
        maxItems: 5
    });

    $('#genres-field').selectize({
        plugins: ['remove_button'],
        delimiter: ',',
        persist: false,
        create: true,
        maxItems: 5
    });

    $('#sources-field').selectize({
        plugins: ['remove_button'],
        delimiter: ',',
        persist: false,
        create: true,
        maxItems: 5
    });

    $('#sheet_difficulty').selectize({});

    // User Form Fields
    $('#user_timezone').selectize({});
    $('#user_billing_country').selectize({});

    $('#note_body_type').selectize({
         options: [{
             "label":'VexTab',
             "value":'vextab'
         }, {
             "label":'Plain Text',
             "value":'plaintext'
         }],
         valueField: 'value',
         labelField: 'label'
     });

    $('#note_visibility').selectize({
         options: [{
             "label":'Public',
             "value":'vpublic'
         }, {
             "label":'Private (Only Me)',
             "value":'vprivate'
         }],
         valueField: 'value',
         labelField: 'label'
     });

    $('#sheet_visibility').selectize({
         options: [{
             "label":'Public',
             "value":'vpublic'
         }, {
             "label":'Private (Only Me)',
             "value":'vprivate'
         }],
         valueField: 'value',
         labelField: 'label'
     });

    $('#sheet_license').selectize({
        options: [{
            "label":'All rights reserved. This title is my original work.',
            "value":'all_rights_reserved'
        }, {
            "label":'I have the permission to make, sell, and distribute this arrangement.',
            "value":'licensed_arrangement'
        }, {
            "label":'Creative Commons (Attribution-NonCommercial-ShareAlike)',
            "value":'creative_commons'
        }, {
            "label":'Creative Commons Zero. ',
            "value":'cc0'
        },
        {
            "label":'This is a public domain work.',
            "value":'public_domain'
        }],
        valueField: 'value',
        labelField: 'label'
    });
});