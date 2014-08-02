$(document).on("page:change", function() {
    $('#instruments-field').selectize({
        plugins: ['remove_button'],
        delimiter: ',',
        persist: false,
        create: false
    });

    $('#tags-field').selectize({
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

});