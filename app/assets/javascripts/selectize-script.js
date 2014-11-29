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

    $('#sheet_visibility').selectize({
        options: [{
            "label":'Public',
            "value":'vpublic'
        }, {
            "label":'Private (Visible only to me)',
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
            "label":'Creative Commons.',
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