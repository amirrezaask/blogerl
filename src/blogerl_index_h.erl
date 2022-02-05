-module(blogerl_index_h).
-export([init/2]).
-compile({inline, [headers/0]}).
-define(STORAGE, blogerl_storage_dets).

headers() ->
    #{<<"content-type">> => <<"text/plain; charset=utf-8">>}.

init(#{method := <<"POST">>} = Req, _) ->
    {ok, RawBody, _} = cowboy_req:read_body(Req),
    #{<<"title">> := Title, <<"body">> := Body} = jsone:decode(RawBody),
    add_post(Req, Title, Body);
    
init(#{method := <<"GET">>} = Req, _) ->    
    Title = cowboy_req:binding(title, Req),
    get_post(Req, Title).

add_post(Req, Title, Body) ->
    ?STORAGE:add(Title, Body),
    cowboy_req:reply(201, headers(), <<>>, Req).

get_post(Req, undefined) ->
    cowboy_req:reply(200, headers(), ?STORAGE:all_titles(), Req);


get_post(Req, Title) ->
    cowboy_req:reply(200, headers(), ?STORAGE:get(erlang:binary_to_list(Title)), Req).
