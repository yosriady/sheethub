$(document).on("page:change", function() {
    var sheet_id = $("#s3-uploader").data("sheet-id");
    $("#s3-uploader").S3Uploader({
        additional_data: {
          sheet_id: sheet_id
        }
    });
});