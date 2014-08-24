$(document).on("page:change", function() {
    $("#sheet_sort_order").change(function () {
        var sort_order = this.value;
        alert(sort_order);
    });
});