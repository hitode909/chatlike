$(function() {
    $('form').submit(function() {
        var form = this;
        $.ajax({
            type: form.method,
            url: form.action,
            data: $(form).serialize(),
            dataType: 'json',
            success: function(res) {
                $(form).parent().hide();
                $(".main").show();
                $.startController(res.data);
                $.bindPostButton(res.data);
            }
        });
        return false;
    });
});
