$(document).on("page:change", function() {
    $("#sheet_sort_order").change(function () {
        data = {
            "sort_order": this.value
        };
        $.get("/sheets", data, undefined, "script");
    });
});