function sources = identify_sources(derivatives)
    %
    % finds the most likely files in the detrivatives that was used to create
    % this file
    %
    % USAGE::
    %
    %   sources = identify_sources(derivatives, verbose)
    %
    % :param file: SPM preprocessed filename (can be fullpath);
    %              for example ``wmsub-01_ses-01_T1w.nii``
    % :type file: string
    %
    %
    % (C) Copyright 2021 spm_2_bids developers

    % "r" could mean realigned or resliced...
    %     'sr'
    %     'sra'
    %     'wr'
    %     'wra'

    % TODO mean may involve several files from the source (across runs
    % and sessions
    %     prefixes = {
    %                 'mean'
    %                 'meanu'
    %                 'meanua'
    %                 'wmeanu'
    %                };

    sources = '';

    prefix_based = true;

    if nargin < 1 || isempty(derivatives)
        return
    end

    if endsWith(derivatives, '_seg8.mat')

        prefix_based = false;

        derivatives = strrep(derivatives, '_seg8.mat', '.nii');

    elseif endsWith(derivatives, '_uw.mat')

        prefix_based = false;

        derivatives = strrep(derivatives, '_uw.mat', '.nii');

    end

    bf = bids.File(derivatives);

    if prefix_based
        if numel(bf.prefix) < 2

            % needs at least 2 characters for this file to have some provenance in the
            % derivatives

            % TODO: files that have been realigned but not resliced have no
            % "prefix" so we may miss some transformation

            return

        else
            % remove the prefix of the last step

            if startsWith(bf.prefix, 's') || startsWith(bf.prefix, 'w')
                bf.prefix = bf.prefix(2:end);

            elseif startsWith(bf.prefix, 'rp_a')
                bf.prefix = bf.prefix(4:end);

            else
                % no idea
                return

            end

        end
    end

    % call spm_2_bids what is the filename from the previous step
    [new_filename] = spm_2_bids(bf.filename);

    sources = fullfile(bf.bids_path, new_filename);

end
