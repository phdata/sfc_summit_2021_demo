select
    filename,
    array_agg(view_name) as                             file_views,     -- simple aggregation to array (array of view_name's per file)
    object_agg(
        array_idx::string,
        view_name::variant
    ) as                                                index_to_view   -- simple aggregation to object (key=array_index, value=view_name)
from
    ui_views
group by
    filename;