function sources = identify_sources(varargin)
    %
    % finds the most likely files in the detrivatives that was used to create
    % this file
    %
    % USAGE::
    %
    %   sources = identify_sources(derivatives, map, verbose)
    %
    % :param derivatives: derivatives file whose source to identify
    % :type derivatives: string
    %
    % :param map: a mapping object. See ``Mapping`` class and or function ``default_mapping``
    % :type map: object
    %
    % :param verbose: Defaults to ``true``
    % :type verbose: boolean
    %

    % (C) Copyright 2021 spm_2_bids developers

    % "r" could mean realigned or resliced...
    %     'sr'
    %     'sra'
    %     'wr'
    %     'wra'
    % those will throw warnings

    % TODO adapt in case prefixes have been changed from SPM defaults

    % TODO
    % functional to anatomical coregistration
    % anatomical to functional coregistration

    default_map = Mapping();
    default_map = default_map.default();

    sources = {};

    prefix_based = true;

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

    % deal with SPM's funky suffixes
    if endsWith(derivatives, '_seg8.mat')

        prefix_based = false;

        derivatives = strrep(derivatives, '_seg8.mat', '.nii');

    elseif bids.internal.ends_with(derivatives, '_uw.mat')

        prefix_based = false;

        derivatives = strrep(derivatives, '_uw.mat', '.nii');

    end

    bf = bids.File(derivatives, 'verbose', verbose, 'use_schema', false);

    % unknown suffix
    if ~ismember(bf.suffix, fieldnames(map.cfg.schema.content.objects.suffixes))
        sources{1, 1} = 'TODO';
        return
    end

    % deal with surface data
    if strcmp(bf.extension, '.surf.gii')
        bf.extension = '.nii';
        prefix_based = false;
    end

    % unless this file already contains a derivative entity
    % it needs at least 2 characters for this file
    % to have some provenance in the derivatives
    if length(bf.prefix) == 1 && any(ismember(fieldnames(bf.entities), map.cfg.entity_order))
        bf.prefix = '';
        sources{1, 1} = fullfile(bf.bids_path, bf.filename);
        return
    end

    sources = add_deformation_field(bf, sources, map, verbose);

    % anything prefix based
    if prefix_based

        [status, bf] = update_prefix(bf, map);

        if status == 0
            return

        elseif status == 1
            sources = 'TODO';
            return

        end

    end

    % call spm_2_bids what is the filename from the previous step
    new_filename = spm_2_bids(bf.filename, map, verbose);

    sources{end + 1, 1} = fullfile(bf.bids_path, new_filename);

end
