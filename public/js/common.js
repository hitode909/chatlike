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
        var p = $("<p>").addClass("message");
        p.append($("<span>").addClass("username").text(message.author)
        ).append($("<span>").addClass("body").text(message.body)
        ).append($("<span>").addClass("timestamp").text(message.created_at));
        $("#message").prepend(p);
        $('#message p:gt(5)').remove();
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
                    if (res.status == "ok") {
                        $("#register, #login").hide();
                        $("#main").show();
                        $.newSession(res.data);
                        $.startPolling();
                        $.getMembers();
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
                    if (res.status == "ok") {
                        $(":text", form).val("");
                        $.receiveChatMessage(res.data);
                    } else {
                        $.each(res.error, function() {
                            $.errorMessage(this.toString());
                        });
                    }
                },
                complete: function(res) {
                    //$(":submit, :text", form).attr("disabled", false);
                }
            });
            //$(":submit, :text", form).attr("disabled", true);
            return false;
        });
    },
    getMembers: function() {
        $.ajax({
            type: "get",
            url: "/api/members",
            data: {session: $.session.random_key},
            dataType: 'json',
            success: function(res) {
                $("#main #members").text(res.data.join(", "));
            }
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
            $.ajax({
                type: 'get',
                url: '/api/get',
                data: {session: key, timeout: 30},
                dataType: 'json',
                success: function(res) {
                    if (res.status == "ok") {
                        if (res.data) {
                            $.receiveChatMessage(res.data);
                            return(getMessage());
                        } else {
                            setTimeout(getMessage, 10000);
                        }
                    } else {
                        $.each(res.error, function() {
                            $.errorMessage(this.toString());
                        });
                        setTimeout(getMessage, 10000);
                    }
                    return true;
                },
                error: function(res, status) {
                    $.errorMessage(status);
                    setTimeout(getMessage, 10000);
                }
            });
        };
        getMessage();
    }
});
