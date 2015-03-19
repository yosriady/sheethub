$(document).on("page:change", function() {
    function getQueryParams() {
      var query = (window.location.search).substring(1);
      if (!query) {
        return {};
      }
      return _
      .chain(query.split('&'))
      .map(function(params) {
        var p = params.split('=');
        return [p[0], decodeURIComponent(p[1])];
      })
      .object()
      .value();
    }

    // Initialize Filter Widget
    var search_form = $('form.sheet_search');
    if(search_form.size() > 0){
        var search_date_input = $('#sheet_search_date').selectize({
            options: [{
                "label":'All Time',
                "value":'all-time'
            }, {
                "label":'This Month',
                "value":'month'
            }, {
                "label":'This Week',
                "value":'week'
            }, {
                "label":'Today',
                "value":'day'
            }],
            valueField: 'value',
            labelField: 'label'
        })[0].selectize;

        var search_sort_input = $('#sheet_search_sort').selectize({
            options: [{
                "label":'Most Recent',
                "value":'recent'
            }, {
                "label":'Most Likes',
                "value":'likes'
            }],
            valueField: 'value',
            labelField: 'label'
        })[0].selectize;

        var search_tags_input = $('#sheet_search_tags').selectize({
            plugins: ['remove_button'],
            delimiter: ',',
            persist: false
        })[0].selectize;

        var search_instruments_input = $('#sheet_search_instruments').selectize({
            plugins: ['remove_button'],
            delimiter: ',',
            persist: false
        })[0].selectize;

        // Sync Filter Widget with query string
        var query_string_params = getQueryParams();
        if(query_string_params['tags']){
            search_tags_input.setValue(query_string_params['tags'].split('+'));
        }
        if(query_string_params['instruments']){
            search_instruments_input.setValue(query_string_params['instruments'].split('+'));
        }
        search_date_input.setValue(query_string_params['date'] || 'all-time');
        search_sort_input.setValue(query_string_params['sort'] || 'recent');

        // Construct query string based on Filter Widget values
        var search_link = $('#btn-sheet-filter');
        search_link.click(function() {
            var search_params = {};

            var search_tags = search_tags_input.getValue().join("+");
            var search_instruments = search_instruments_input.getValue().join("+");
            var search_sort = search_sort_input.getValue();
            var search_date = search_date_input.getValue();
            if(!_.isEmpty(search_tags)){
                search_params['tags'] = search_tags;
            }
            if(!_.isEmpty(search_instruments)){
                search_params['instruments'] = search_instruments;
            }
            if(!_.isEmpty(search_sort)){
                search_params['sort'] = search_sort;
            }
            if(!_.isEmpty(search_date)){
                search_params['date'] = search_date;
            }

            window.location.href = window.location.pathname+"?"+decodeURIComponent($.param(search_params))
        });
    }
});