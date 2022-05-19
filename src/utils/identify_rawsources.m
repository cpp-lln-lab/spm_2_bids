function rawsource = identify_rawsources(derivatives, verbose)
    %
    % find the most likely files in the raw dataset
    % that was used to create this derivatives
    %
    % USAGE::
    %
    %   rawsource = identify_rawsources(derivatives)
    %
    % :param file: SPM preprocessed filename (can be fullpath);
    %              for example ``wmsub-01_ses-01_T1w.nii``
    % :type file: string
    %
    %
    % (C) Copyright 2021 spm_2_bids developers

    % TODO mean may involve several files from the source (across runs
    % and sessions
    %     prefixes = {
    %                 'mean'
    %                 'meanu'
    %                 'meanua'
    %                 'wmeanu'
    %                };

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

    rawsource = fullfile(bf.bids_path, bf.filename);

end
