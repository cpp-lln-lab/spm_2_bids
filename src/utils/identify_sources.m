function sources = identify_sources(varargin)
    %
    % finds the most likely files in the detrivatives that was used to create
    % this file
    %
    % USAGE::
    %
    %   sources = identify_sources(derivatives, map, verbose)
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
    % those will throw warnings

    % TODO
    % functional to anatomical coregistration
    % anatomical to functional coregistration

    default_map = Mapping();
    default_map = default_map.default();

    sources = '';

    prefix_based = true;

    deformation_field_needed = false;

    args = inputParser;

    addOptional(args, 'derivatives', pwd, @ischar);
    addOptional(args, 'map', default_map);
    addOptional(args, 'verbose', true, @islogical);

    parse(args, varargin{:});

    derivatives = args.Results.derivatives;
    map = args.Results.map;
    verbose = args.Results.verbose;

    if isempty(derivatives)
        return
    end

    if bids.internal.ends_with(derivatives, '_seg8.mat')

        prefix_based = false;

        derivatives = strrep(derivatives, '_seg8.mat', '.nii');

    elseif bids.internal.ends_with(derivatives, '_uw.mat')

        prefix_based = false;

        derivatives = strrep(derivatives, '_uw.mat', '.nii');

    end

    bf = bids.File(derivatives, 'verbose', verbose, 'use_schema', false);

    if prefix_based

        if numel(bf.prefix) < 2

            % needs at least 2 characters for this file to have some provenance in the
            % derivatives

            % TODO: files that have been realigned but not resliced have no
            % "prefix" so we may miss some transformation

            return

        else
            % remove the prefix of the last step

            if bids.internal.starts_with(bf.prefix, 's') && ...
                ~bids.internal.starts_with(bf.prefix, 'std_') && ...
                 ~bids.internal.starts_with(bf.prefix, 'segparam_')

                % in case we have "s6" for the fwhm
                if isnan(str2double(bf.prefix(2)))
                    bf.prefix = bf.prefix(2:end);
                else
                    bf.prefix = bf.prefix(3:end);
                end

            elseif bids.internal.starts_with(bf.prefix, 'u') && ...
                   ~bids.internal.starts_with(bf.prefix, 'unwarpparam_')

                bf.prefix = bf.prefix(2:end);

                deformation_field_needed = true;

            elseif bids.internal.starts_with(bf.prefix, 'w')

                bf.prefix = bf.prefix(2:end);
                deformation_field_needed = true;

            elseif bids.internal.starts_with(bf.prefix, 'rp_a')

                bf.prefix = bf.prefix(4:end);

            elseif bids.internal.starts_with(bf.prefix, 'mean')
                % TODO mean may involve several files from the source (across runs
                % and sessions
                %     prefixes = {
                %                 'mean'
                %                 'meanu'
                %                 'meanua'
                %                };
                return

            else
                % no idea
                return

            end

        end
    end

    % call spm_2_bids what is the filename from the previous step
    new_filename = spm_2_bids(bf.filename, map, verbose);

    sources{1, 1} = fullfile(bf.bids_path, new_filename);

    sources = add_deformation_field(sources, bf, map, verbose, deformation_field_needed);

end

