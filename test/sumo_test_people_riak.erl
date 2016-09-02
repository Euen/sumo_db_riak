-module(sumo_test_people_riak).

-behavior(sumo_doc).

%% @todo remove this once mixer migrates specs better
-dialyzer([no_behaviours]).

-include_lib("mixer/include/mixer.hrl").
-mixin([{
  sumo_test_people, [
    sumo_wakeup/1,
    sumo_sleep/1,
    new/2,
    new/3,
    new/4,
    new/5,
    new/6,
    new/7,
    new/8,
    new/9,
    name/1,
    last_name/1,
    id/1,
    age/1,
    address/1,
    birthdate/1,
    created_at/1,
    height/1,
    description/1,
    profile_image/1,
    weird_field/1
  ]}
]).

-export([sumo_schema/0]).

%%%=============================================================================
%%% sumo_doc callbacks
%%%=============================================================================

-spec sumo_schema() -> sumo:schema().
sumo_schema() ->
  Fields = [
    sumo:new_field(id,            binary, [id]),
    sumo:new_field(name,          string, [not_null, unique]),
    sumo:new_field(last_name,     string, [not_null]),
    sumo:new_field(age,           integer),
    sumo:new_field(address,       string),
    sumo:new_field(birthdate,     date),
    sumo:new_field(created_at,    datetime),
    sumo:new_field(height,        float),
    sumo:new_field(description,   text),
    sumo:new_field(profile_image, binary),
    sumo:new_field(weird_field,   custom)
  ],
  sumo:new_schema(people, Fields).
