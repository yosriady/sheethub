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
        create: true
    });

    $('#genres-field').selectize({
        plugins: ['remove_button'],
        delimiter: ',',
        persist: false,
        create: true
    });

    $('#sources-field').selectize({
        plugins: ['remove_button'],
        delimiter: ',',
        persist: false,
        create: true
    });

    $('#sheet_difficulty').selectize({});
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