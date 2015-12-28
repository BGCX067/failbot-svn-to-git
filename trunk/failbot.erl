%% Thanks to Jonathan Roes for http://blog.jroes.net/2007/08/simple-erlang-irc-bot.html
-module(failbot).
-export([connect/2]).
-define(nickname, "failbot").
-define(channel, "#failbot").

connect(Host, Port) ->
    {ok, Sock} = gen_tcp:connect(Host, Port, [{packet, line}]),
    gen_tcp:send(Sock, "NICK " ++ ?nickname ++ "\r\n"),
    gen_tcp:send(Sock, "USER " ++ ?nickname ++ " epic fail bot\r\n"),
    loop(Sock, Host, Port).

loop(Sock, Host, Port) ->
    receive
        {tcp, Sock, Data} ->
            parse(Sock, Host, Port, string:tokens(Data, ": ")),
            loop(Sock, Host, Port);
        quit ->
            gen_tcp:close(Sock),
            exit(stopped)
    end.

parse(Sock, _Host, _Port, [_,"376"|_]) ->
    gen_tcp:send(Sock, "JOIN :" ++ ?channel ++ "\r\n");
parse(Sock, _Host, _Port, ["PING"|Rest]) ->
    gen_tcp:send(Sock, "PONG " ++ Rest ++ "\r\n");
parse(Sock, Host, Port, [_User, "PRIVMSG", Channel, ?nickname | _]) ->
    gen_tcp:send(Sock, "PRIVMSG " ++ Channel ++ " :orz\r\n"),
    gen_tcp:close(Sock),
    Millisecs = 1000 * 60 * 30,
    timer:sleep(Millisecs + round(random:uniform() * Millisecs)),
    connect(Host, Port);
parse(_, _, _, _) ->
    ok.
