put file://&{project_dir}json/views*.json @%raw_device_data/json
    overwrite = true;

copy into raw_device_data (raw, filename, file_row)
    from (
        select
            $1, metadata$filename, metadata$file_row_number
        from
            @%raw_device_data/json
    )
    file_format = (type = 'JSON');