$(document).on("page:change", function() {
    // TODO: http://stackoverflow.com/questions/22211680/typeahead-rails-not-working/22213397#22213397
    // http://twitter.github.io/typeahead.js/examples/#remote
    $("#search_form").typeahead({
        name: "sheet",
        remote: "/sheets/autocomplete?query=%QUERY"
      });
});