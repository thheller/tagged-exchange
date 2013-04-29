%% The contents of this file are subject to the Mozilla Public License
%% Version 1.1 (the "License"); you may not use this file except in
%% compliance with the License. You may obtain a copy of the License
%% at http://www.mozilla.org/MPL/
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and
%% limitations under the License.
%%
%% The Original Code is RabbitMQ.
%%
%% The Initial Developer of the Original Code is VMware, Inc.
%% Copyright (c) 2007-2013 VMware, Inc.  All rights reserved.
%%

-module(rabbit_exchange_type_tagged).
-include("rabbit.hrl").
-include("rabbit_framing.hrl").

-behaviour(rabbit_exchange_type).

-export([description/0, serialise_events/0, route/2]).
-export([validate/1, validate_binding/2,
         create/2, delete/3, policy_changed/2, policy_changed/3,
         add_binding/3, remove_bindings/3, assert_args_equivalence/2]).

-rabbit_boot_step({?MODULE,
                   [{description, "exchange type tagged"},
                    {mfa,         {rabbit_registry, register,
                                   [exchange, <<"tagged">>, ?MODULE]}},
                    {requires,    rabbit_registry},
                    {enables,     kernel_ready}]}).

description() ->
    [{description, <<"AMQP tagged exchange">>}].

serialise_events() -> false.

get_tags(undefined) ->
  sets:new();

get_tags(Headers) ->
  case rabbit_misc:table_lookup(Headers, <<"tags">>) of
    undefined ->
      sets:new();
    {longstr, TagBin} ->
      sets:from_list(binary:split(TagBin, <<",">>))
  end.

route(#exchange{name = Name},
      #delivery{message = #basic_message{content = Content}}) ->

  Props = Content#content.properties,
  MsgTags = get_tags(Props#'P_basic'.headers),

  rabbit_router:match_bindings(
    Name,
    fun (#binding{args = Spec}) ->
      %% test if the binding tags is a subset of the msg tags
      BindingTags = get_tags(Spec),
      sets:is_subset(MsgTags, BindingTags)
    end).

%% dummy methods, should probably validate n stuff
validate_binding(_X, _B) -> ok.
validate(_X) -> ok.
create(_Tx, _X) -> ok.
delete(_Tx, _X, _Bs) -> ok.
policy_changed(_X1, _X2) -> ok.
policy_changed(_X1, _X2, _X3) -> ok.
add_binding(_Tx, _X, _B) -> ok.
remove_bindings(_Tx, _X, _Bs) -> ok.
assert_args_equivalence(X, Args) ->
  rabbit_exchange:assert_args_equivalence(X, Args).