function sources = add_deformation_field(bf, sources, map, verbose)
    % (C) Copyright 2021 spm_2_bids developers
    if ~startsWith(bf.prefix, map.norm)
        return
    end

    % for anatomical data we assume that
    % the deformation field comes from the anatomical file itself
    if (~isempty(bf.modality) && ismember(bf.modality, {'anat'})) || ...
        (~isempty(bf.suffix) && ~isempty(map.cfg.schema.find_suffix_group('anat', bf.suffix)))

        bf.prefix = 'y_';
        bf = bf.update;
        new_filename = spm_2_bids(bf.filename, map, verbose);
        deformation_field = fullfile(bf.bids_path, new_filename);

        % otherwise we can't guess it just from the file name
    else
        deformation_field = 'TODO: add deformation field';

    end

    sources{end + 1, 1} = deformation_field;

end
