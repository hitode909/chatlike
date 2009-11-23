jQuery.extend({
    message: function(body) {
        $("#message").prepend($("<p>").text(body));
    },
    errorMessage: function(body) {
        $("#message").prepend($("<p>").addClass("error").text("error: " + body));
    },
    messageReceived: function(message) {
        var p = $("<p>").addClass("message");
        if (message.is_system) {
            p.addClass("system");
        }
        p.append($("<span>").addClass("username").text(message.author)
        ).append($("<span>").addClass("body").text(message.body)
        ).append($("<span>").addClass("timestamp").text(message.created_at));
        $("#message").prepend(p);
    },
    sessionsReceived: function(sessions) {
        var ul = $("<ul>");
        var found = false;
        $.each(sessions, function() {
            var name = this.toString();
            var li = $("<li>");
            if (!found && name == $.session.user_name) {
                li.append($("<strong>").text(name));
                found = true;
            } else {
                li.append("<span>").text(name);
            }
            ul.append(li);
        });
        $("#main #sessions").empty().append($("<span>").text("sessions:")).append(ul);
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
                cache: false,
                success: function(res) {
                    if (res.status == "ok") {
                        $("#register, #login").hide();
                        $("#main").show();
                        $.newSession(res.session);
                        $.startPolling();
                        $.getSessions();
                    } else {
                        $.each(res.errors, function() {
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
                cache: false,
                success: function(res) {
                    if (res.status == "ok") {
                        $(":text", form).val("");
                        $.messageReceived(res.message);
                    } else {
                        $.each(res.errors, function() {
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
        $("#main .logout-form").submit(function() {
            var form = this;
            $.ajax({
                type: form.method,
                url: form.action,
                data: $(form).serialize() + "&session=" + $.session.random_key,
                dataType: 'json',
                cache: false,
                success: function(res) {
                    if (res.status == "ok") {
                        location.replace("/");
                    } else {
                        $.each(res.errors, function() {
                            $.errorMessage(this.toString());
                        });
                    }
                }
            });
            return false;
        });
    },
    getSessions: function() {
        $.ajax({
            type: "get",
            url: "/api/session/sessions",
            data: {session: $.session.random_key},
            dataType: 'json',
            cache: false,
            success: function(res) {
                if (res.status == "ok") {
                    $.sessionsReceived(res.sessions);
                } else {
                    $.each(res.errors, function() {
                        $.errorMessage(this.toString());
                    });
                }
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
                url: '/api/session/get',
                data: {session: key, timeout: 60},
                dataType: 'json',
                timeout: 40 * 1000,
                cache: false,
                success: function(res) {
                    if (res.status == "ok") {
                        if (res.message) {
                            $.messageReceived(res.message);
                            setTimeout(getMessage, 0);
                        } else {
                            setTimeout(getMessage, 10000);
                        }
                        if (res.sessions) {
                            $.sessionsReceived(res.sessions);
                        }
                    } else {
                        $.each(res.errors, function() {
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

$(function() {
      $(".togglable").each(function() {
          var context = this;
          $(".toggle-bar", context).click(function() {
              $(".toggle-content", context).toggle();
          });
      });

});