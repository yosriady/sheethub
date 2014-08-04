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

});