-module(find_SUITE).

%% CT
-export([
  all/0,
  init_per_suite/1,
  end_per_suite/1
]).

%% Test Cases
-include_lib("mixer/include/mixer.hrl").
-mixin([
  {sumo_find_test_helper, [
    find_by_sort/1,
    find_all_sort/1
  ]}
]).

-define(EXCLUDED_FUNS, [
  all,
  module_info,
  init_per_suite,
  end_per_suite
]).

-type config() :: [{atom(), term()}].

%%%=============================================================================
%%% Common Test
%%%=============================================================================

-spec all() -> [atom()].
all() ->
  Exports = ?MODULE:module_info(exports),
  [F || {F, _} <- Exports, not lists:member(F, ?EXCLUDED_FUNS)].

-spec init_per_suite(config()) -> config().
init_per_suite(Config) ->
  {ok, _} = application:ensure_all_started(sumo_db_riak),
  Name = people,
  sumo_find_test_helper:init_store(Name),
  timer:sleep(5000),
  [{name, Name}, {people_with_like, true}, {sort, [first_name]} | Config].

-spec end_per_suite(config()) -> config().
end_per_suite(Config) ->
  ok = sumo_db_riak:stop(),
  Config.
