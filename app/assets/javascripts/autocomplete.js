$(document).on("page:change", function() {
  if(!$('.twitter-typeahead').length){
    var sheets = new Bloodhound({
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('title'),
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      prefetch: {
          url: '/sheets/titles'
        },
      remote: '/sheets/autocomplete?query=%QUERY'
    });

    sheets.initialize();

    $('#scrollable-dropdown-menu .typeahead').typeahead(null, {
      name: 'sheets',
      displayKey: 'title',
      source: sheets.ttAdapter(),
      templates: {
        empty: [
        '<span class="no-results-message">',
        'No matches'
        ].join('\n')
      }
    }).on('typeahead:selected', function(event, datum) {
        window.location = datum.url
    });;

    $('#scrollable-dropdown-menu .typeahead.tt-input').keypress(function( event ) {
        if ( event.which == 13 ) {
            var destination = "/search?q=" + event.target.value;
            window.location.href = destination;
        }
    });

  }
});