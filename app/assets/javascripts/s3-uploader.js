$(document).on("page:change", function() {
    $("#s3-uploader").S3Uploader({
        additional_data: {
          sheet_id: gon.sheet_id
        }
    });

});