with
    proc_details_tabular as (                                       -- ProcedureDetails 'views' from ui_views
        select
            filename,
            array_idx,
            to_timestamp(view_obj:EndTime::string, 'YYYY-MON-DD HH24:MI:SS') as proc_end,
            to_timestamp(view_obj:StartTime::string, 'YYYY-MON-DD HH24:MI:SS') as proc_start
        from
            ui_views
        where
            view_name = 'ProcedureDetails'
    ),
    views_with_proc_idx as (                                        -- ui_views joined with ProcedureDetails using time ranges
        select
            ui_views.filename,
            ui_views.view_name,
            proc_details_tabular.array_idx as proc_idx
        from
            ui_views
            join proc_details_tabular on (ui_views.filename = proc_details_tabular.filename
                                            and exit_view > proc_start
                                            and exit_view <= proc_end)
        where
            view_name != 'ProcedureDetails'
    )
select
    proc_details_tabular.filename,
    proc_idx,
    proc_start,
    proc_end,
    array_agg(view_name)
from
    proc_details_tabular
    join views_with_proc_idx on (proc_details_tabular.filename = views_with_proc_idx.filename
                                    and proc_details_tabular.array_idx = views_with_proc_idx.proc_idx)
group by
    proc_details_tabular.filename,
    proc_idx,
    proc_start,
    proc_end;