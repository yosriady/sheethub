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

    $('#sheet_publishing_right').selectize({
        options: [{
            "label":'This title is my original composition',
            "value":'original'
        }, {
            "label":'I have acquired the necessary publishing and worldwide distribution rights',
            "value":'rights'
        }, {
            "label":'This is a public domain work',
            "value":'public_domain'
        }],
        valueField: 'value',
        labelField: 'label'
    });

    $('#sheet_sort_order').selectize({
        create: false,
        persist: false,
        render: {
            item: function(item, escape) {
                return '<div> Sort By ' + item.text + '</div>';
            },
            option: function(item, escape) {
                return '<div> Sort By ' + item.text + '</div>';
            }
        }
    });

});