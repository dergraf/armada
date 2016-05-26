-module(fleet_auth_plugin).

-behaviour(auth_on_register_hook).
-behaviour(auth_on_subscribe_hook).
-behaviour(auth_on_publish_hook).

-export([start/0,
         stop/0]).

-export([auth_on_register/5,
         auth_on_publish/6,
         auth_on_subscribe/3]).

%% Plugin hooks

start() ->
    {ok, _} = application:ensure_all_started(fleet_auth_plugin),
    ok.

stop() ->
    application:stop(fleet_auth_plugin).

%% IMPORTANT:
%%  these hook functions run in the session context

auth_on_register(Peer, {_MountPoint, ClientId} = SubscriberId, ClientId, Password, CleanSession) ->
    error_logger:info_msg("blubb"),
    AdminUser = os:getenv("ADMIN_USER"),
    AdminPass = os:getenv("ADMIN_PASS"),
    if
        ClientId == AdminUser, Password == AdminPass ->
            error_logger:info_msg("admin user connected"),
            ok;
        true -> auth_on_register_internal(Peer, SubscriberId, ClientId, Password, CleanSession)
    end;

auth_on_register(_, _, _, _, _) ->
    error_logger:info_msg("auth_on_register failed: client_id was not identical to username"),
    {error, invalid_credentials}.

auth_on_register_internal(Peer, SubscriberId, ClientId, Password, CleanSession) ->
    %% do a simple request with pylon headers
    URL     = "http://fleet.superscale.io/v1/pylon/auth",
    Headers = [{"pylon-name", ClientId}, {"pylon-key", Password}],

    case httpc:request(get, {URL, Headers}, [{timeout, 5000}], []) of
        {ok, {{_, Code, _}, _, _}} when Code >= 200, Code < 300 ->
            error_logger:info_msg("auth_on_register succeeded: ~p ~p ~p ~p ~p",
                                  [Peer, SubscriberId, ClientId, CleanSession]),
            ok;
        _ ->
            error_logger:info_msg("auth_on_register failed: ~p ~p ~p ~p",
                                  [Peer, SubscriberId, ClientId, CleanSession]),
            {error, invalid_credentials}
    end.

auth_on_publish(_UserName, {_MountPoint, _ClientId} = _SubscriberId, _QoS, _Topic, _Payload, _IsRetain) ->
    %% do whatever you like with the params, all that matters
    %% iaddss the return value of this function
    %sd%asd
    %%ad 1. return 'ok' -> PUBLISH is authorized
    % 2. return 'next' -> leave it to other plugins to decide
    %% 3. return {ok, NewPayload::binary} -> PUBLISH is authorized, but we changed the payload
    %% 4. return {ok, [{ModifierKey, NewVal}...]} -> PUBLISH is authorized, but we might have changed different Publish Options:
    %%     - {topic, NewTopic::string}
    %%     - {payload, NewPayload::binary}
    %%     - {qos, NewQoS::0..2}
    %%     - {retain, NewRetainFlag::boolean}
    %% 5. return {error, whatever} -> auth chain is stopped, and message is silently dropped (unless it is a Last Will message)
    %%
    %% we return 'ok'
    ok.

auth_on_subscribe(_UserName, _ClientId, [{_Topic, _QoS}|_] = _Topics) ->
    %% do whatever you like with the params, all that matters
    %% is the return value of this function
    %%
    %% 1. return 'ok' -> SUBSCRIBE is authorized
    %% 2. return 'next' -> leave it to other plugins to decide
    %% 3. return {error, whatever} -> auth chain is stopped, and no SUBACK is sent

    %% we return 'ok'
    ok.
