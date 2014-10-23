$(document).on("page:change", function() {
    $("#paypal-checkout-btn").one('click',function(e){
        $(this).on('click',function(ev){
          ev.preventDefault();
        });
        // Pop open modal
        $('#paypalProgressModal').modal('show');
    });
});