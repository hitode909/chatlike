jQuery.extend({
    message: function(body) {
        $("#message").prepend($("<p>").text(body));
        $('#message p:gt(5)').remove();
    },
    errorMessage: function(body) {
        $("#message").prepend($("<p>").addClass("error").text("error: " + body));
        $('#message p:gt(5)').remove();
    },
    receiveChatMessage: function(message) {
        $.message(message.author + " said " + message.body + " at " + message.created_at);
    },
    newSession: function(session) {
        if (!session) return;
        $.extend({
            session: session
        });
    },
    setup: function() {
        $("#register .register-form, #login .login-form").submit(function() {
            var form = this;
            $.ajax({
                type: form.method,
                url: form.action,
                data: $(form).serialize(),
                dataType: 'json',
                success: function(res) {
                    console.log(res);
                    if (res.status == "ok") {
                        $("#register, #login").hide();
                        $("#main").show();
                        $.newSession(res.data);
                        $.startPolling();
                    } else {
                        $.each(res.error, function() {
                            $.errorMessage(this.toString());
                        });
                    }
                }
            });
            return false;
        });
        $("#main .post-form").submit(function() {
            var form = this;
            $.ajax({
                type: form.method,
                url: form.action,
                data: $(form).serialize() + "&session=" + $.session.random_key,
                dataType: 'json',
                success: function(res) {
                    console.log(res);
                    if (res.status == "ok") {
                        $.receiveChatMessage(res.data);
                    } else {
                        $.each(res.error, function() {
                            $.errorMessage(this.toString());
                        });
                    }
                }
            });
            return false;
        });
    },
    startPolling: function() {
        var getMessage = function() {
            var key = $.session.random_key;
            if (!key) {
                setTimeout(getMessage, 1000);
                return;
            }
            // XXX: failback
            $.getJSON('/api/get',
                {session: key, timeout: 30},
                function(res) {
                    if (res.status == "ok") {
                        if (res.data) {
                            $.receiveChatMessage(res.data);
                        } else {
                            $.message("no message" + new Date());
                        }
                    } else {
                        $.each(res.error, function() {
                            $.errorMessage(this.toString());
                        });
                    }
                    getMessage();
                });
        };
        getMessage();
    }
});
