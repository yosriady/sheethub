$(document).ready(function() {
    $('#instruments-field').selectize({
        plugins: ['remove_button'],
        delimiter: ',',
        persist: false,
        create: false
    });
});