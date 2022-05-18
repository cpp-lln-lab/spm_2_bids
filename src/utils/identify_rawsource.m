function rawsource = identify_rawsource(derivatives, verbose)
    %
    %
    %
    % USAGE::
    %
    %   rawsource = identify_rawsource(derivatives)
    %
    % :param file: SPM preprocessed filename (can be fullpath);
    %              for example ``wmsub-01_ses-01_T1w.nii``
    % :type file: string
    %
    % :returns: - :new_filename: (string) BIDS compatible filename
    %               for example ``sub-01_ses-01_space-IXI549Space_desc-preproc_T1w.nii``;
    %
    % (C) Copyright 2021 spm_2_bids developers

    rawsource = '';

    if nargin < 1 || isempty(derivatives)
        return
    end

    if nargin < 2
        verbose = true;
    end

    if endsWith(derivatives, '_seg8.mat')
        derivatives = strrep(derivatives, '_seg8.mat', '.nii');
    elseif endsWith(derivatives, '_uw.mat')
        derivatives = strrep(derivatives, '_uw.mat', '.nii');
    end

    bf = bids.File(derivatives, 'verbose', verbose);

    bf.prefix = '';

    rawsource = fullfile(bf.path, bf.bids_path, bf.filename);

end
