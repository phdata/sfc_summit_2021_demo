select
    view_field.seq as                       prepare_view_key,       -- 3) a key to the Prepare View this field is from
    iff(
        is_object(view_field.value),
        'attempt',
        view_field.value::string
    ) as                                    prepare_action,         -- 4) action name, hardcoded to 'attempt' when field value is an object
    to_timestamp(
        view_field.key,
        'YYYY-MON-DD HH24:MI:SS'
    ) as                                    prepare_action_time,    -- 5) action timestamp, parsed from field key
    view_field.value:attempt::number as     attempt_num,            -- 6) action details, parsed from field value when it is an object, null if not an object.
    view_field.value:error::number as       error,                  --    same ^^
    view_field.value:xDim::number as        x,                      --    same   ^^
    view_field.value:yDim::number as        y,                      --    same     ^^
    view_field.value:zDim::number as        z                       --    same       ^^
from
    ui_views,
    lateral flatten(input => view_obj) view_field                   -- 1) explode all 'View' objects (from ui_views), creating a row for each field of the views
where
    view_name = 'Prepare'                                           -- 2) filter all rows to fields from Prepare views with keys that parse to a timestamp of the given format
    and try_to_timestamp(
        view_field.key, 
        'YYYY-MON-DD HH24:MI:SS'
    ) is not null;