$(document).on("page:change", function() {
    alert(gon.sheet_id);
    console.log(gon);
    $("#s3-uploader").S3Uploader({
        additional_data: {
          sheet_id: gon.sheet_id
        }
    });

});