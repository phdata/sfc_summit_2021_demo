with
    proc_details_tabular as (                                       -- ProcedureDetails 'views' from ui_views
        select
            filename,                                               -- filename and array_idx make up a unique key for each ProcedureDetails which represents a Procedure
            array_idx,
            to_timestamp(view_obj:EndTime::string, 'YYYY-MON-DD HH24:MI:SS') as proc_end,
            to_timestamp(view_obj:StartTime::string, 'YYYY-MON-DD HH24:MI:SS') as proc_start
        from
            ui_views
        where
            view_name = 'ProcedureDetails'
    ),
    views_with_proc_idx as (                                        -- ui_views joined with ProcedureDetails by time ranges
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
    proc_details_tabular.filename,                                  -- proecdure details: key (filename, array_idx), start time, end time, ui views
    proc_idx,
    proc_start,
    proc_end,
    array_agg(view_name) as views                                   -- array_agg view names to create variant array of all UI views in a given Procedure
from
    proc_details_tabular
    join views_with_proc_idx on (proc_details_tabular.filename = views_with_proc_idx.filename
                                    and proc_details_tabular.array_idx = views_with_proc_idx.proc_idx)
group by
    proc_details_tabular.filename,                                  -- group by Procedure key (filename, array_idx) to have a row for each Procedure
    proc_idx,
    proc_start,
    proc_end;