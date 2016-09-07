-module(sumo_test_purchase_order).

-behaviour(sumo_doc).

-type address() :: #{
  line1    => binary(),
  line2    => binary(),
  city     => binary(),
  state    => binary(),
  zip_code => binary(),
  country  => binary()
}.

-type item() :: #{
  part_num      => binary(),
  product_name  => binary(),
  quantity      => pos_integer(),
  unit_price    => pos_integer(),
  price         => pos_integer()
}.
-type items() :: [item()].

-type purchase_order() :: #{
  id          => binary(),
  created_at  => calendar:datetime(),
  order_num   => binary(),
  po_date     => calendar:datetime(),
  ship_to     => address(),
  bill_to     => address(),
  items       => items(),
  currency    => binary(),
  total       => pos_integer()
}.

-export_type([purchase_order/0, address/0, item/0, items/0]).

%% API
-export([
  new/8,
  id/1, id/2,
  items/1, items/2,
  currency/1, currency/2,
  order_num/1, order_num/2,
  new_address/6, new_item/5
]).

%% sumo_doc callbacks
-export([sumo_schema/0, sumo_wakeup/1, sumo_sleep/1]).

%%%=============================================================================
%%% sumo_doc callbacks
%%%=============================================================================

-spec sumo_schema() -> sumo:schema().
sumo_schema() ->
  sumo:new_schema(purchase, [
    sumo:new_field(id,         string,   [id, not_null]),
    sumo:new_field(created_at, datetime, [not_null]),
    sumo:new_field(order_num,  string,   [not_null]),
    sumo:new_field(po_date,    datetime, [not_null]),
    sumo:new_field(ship_to,    custom,   [{type, object}]),
    sumo:new_field(bill_to,    custom,   [{type, object}]),
    sumo:new_field(items,      custom,   [{type, object}]),
    sumo:new_field(currency,   string,   [not_null]),
    sumo:new_field(total,      integer,  [not_null])
  ]).

-spec sumo_sleep(purchase_order()) -> sumo:model().
sumo_sleep(PO) ->
  I = items(PO),
  Items = maps:from_list(lists:zip(lists:seq(1, length(I)), I)),
  items(PO, Items).

-spec sumo_wakeup(sumo:model()) -> purchase_order().
sumo_wakeup(Doc) ->
  Items = wakeup_items(maps:get(items, Doc, #{})),
  Total = to_int(maps:get(total, Doc)),
  #{
    id          => maps:get(id, Doc),
    created_at  => maps:get(created_at, Doc),
    order_num   => maps:get(order_num, Doc),
    po_date     => maps:get(po_date, Doc),
    ship_to     => maps:get(ship_to, Doc),
    bill_to     => maps:get(bill_to, Doc),
    items       => Items,
    currency    => maps:get(currency, Doc),
    total       => Total
  }.

%%%=============================================================================
%%% API
%%%=============================================================================

-spec new(
  binary(),
  binary(),
  calendar:datetime(),
  address(),
  address(),
  items(),
  binary(),
  pos_integer()
) -> purchase_order().
new(Id, OrderNum, Date, ShipTo, BillTo, Items, Currency, Total) ->
  #{
    id          => Id,
    created_at  => calendar:universal_time(),
    order_num   => OrderNum,
    po_date     => Date,
    ship_to     => ShipTo,
    bill_to     => BillTo,
    items       => Items,
    currency    => Currency,
    total       => Total
  }.

-spec id(purchase_order()) -> binary().
id(#{id := Val}) ->
  Val.

-spec id(purchase_order(), binary()) -> purchase_order().
id(PO, Val) ->
  maps:put(id, Val, PO).

-spec order_num(purchase_order()) -> binary().
order_num(#{order_num := Val}) ->
  Val.

-spec order_num(purchase_order(), binary()) -> purchase_order().
order_num(PO, Val) ->
  maps:put(order_num, Val, PO).

-spec items(purchase_order()) -> items().
items(#{items := Val}) ->
  Val.

-spec items(purchase_order(), item()) -> purchase_order().
items(PO, Val) ->
  maps:put(items, Val, PO).

-spec currency(purchase_order()) -> binary().
currency(#{currency := Val}) ->
  Val.

-spec currency(purchase_order(), binary()) -> purchase_order().
currency(PO, Val) ->
  maps:put(currency, Val, PO).

-spec new_address(
  binary(),
  binary(),
  binary(),
  binary(),
  binary(),
  binary()
) -> address().
new_address(Line1, Line2, City, State, ZipCode, Country) ->
  #{
    line1    => Line1,
    line2    => Line2,
    city     => City,
    state    => State,
    zip_code => ZipCode,
    country  => Country
  }.

-spec new_item(
  binary(),
  binary(),
  pos_integer(),
  pos_integer(),
  pos_integer()
) -> item().
new_item(PartNum, Name, Quantity, UnitPrice, Price) ->
  #{
    part_num      => PartNum,
    product_name  => Name,
    quantity      => Quantity,
    unit_price    => UnitPrice,
    price         => Price
  }.

%%%=============================================================================
%%% Internal functions
%%%=============================================================================

%% @private
to_int(Data) when is_binary(Data) ->
  binary_to_integer(Data);
to_int(Data) when is_list(Data) ->
  list_to_integer(Data);
to_int(Data) ->
  Data.

%% @private
wakeup_item(Item) ->
  #{
    part_num      => maps:get(part_num, Item),
    product_name  => maps:get(product_name, Item),
    quantity      => to_int(maps:get(quantity, Item)),
    unit_price    => to_int(maps:get(unit_price, Item)),
    price         => to_int(maps:get(price, Item))
  }.

%% @private
wakeup_items(Items) ->
  [wakeup_item(V) || V <- maps:values(Items)].
