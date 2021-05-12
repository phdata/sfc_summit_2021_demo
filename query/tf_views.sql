select
    filename,
    array_element.index as                  array_idx,      -- 2) use flattened lateral data to get array index
    array_element.value as                  view_wrapper,   -- 3) use flattened lateral data to get variant value (an object) at array index
    object_keys(view_wrapper) as            view_keys,      -- 4) get all keys for the object (should be a single key)
    view_keys[0]::string as                 view_name,      -- 5) disvoer the name of the first (and only) key for the object.
    get(view_wrapper, view_name) as         view_obj,       -- 6) use the object and the discovered key to get the actual object with keys/values
    view_obj:EnterView::string as           enter_view,     -- 7) parse out common values (EnterView and ExitView)
    view_obj:ExitView::string as            exit_view
from
    raw_device_data,
    lateral flatten(input => raw:Views) array_element;      -- 1) explode all 'Views' arrays