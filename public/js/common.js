jQuery.extend({
    message: function(body) {
        $("#message").prepend($("<p>").text(body));
        $('#message p:gt(5)').remove();
    },
    bindPostButton: function(key) {
        $('button.post').click(function() {
            var body = $(this).val() || $(this).text();
            $.ajax({
                type: 'post',
                url: '/api/post',
                data: {key: key, data: body},
                dataType: 'json',
                success: function(res) {
                    $.message(res.data);
                }
            });
        });
    },
    startController: function(key) {
        $(".key").text("key = " + key);
        var getMessage = function() {
            $.getJSON('/api/get',
                {key: key},
                function(res) {
                    $.message(res.data);
                    getMessage();
                }
            );
        };
        getMessage();
    }
});
