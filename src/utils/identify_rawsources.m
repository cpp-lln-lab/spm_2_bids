function rawsource = identify_rawsources(derivatives, map, verbose)
    %
    % find the most likely files in the raw dataset
    % that was used to create this derivatives
    %
    % Assumption: the raw file was zipped
    %
    % USAGE::
    %
    %   rawsource = identify_rawsources(derivatives)
    %
    % :param derivatives: derivatives file whose source to identify
    % :type derivatives: string
    %
    % :param verbose: Defaults to ``true``
    % :type verbose: boolean
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

    if bids.internal.ends_with(derivatives, '_seg8.mat')
        derivatives = strrep(derivatives, '_seg8.mat', '.nii');
    elseif bids.internal.ends_with(derivatives, '_uw.mat')
        derivatives = strrep(derivatives, '_uw.mat', '.nii');
    end

    % - only deal with files with official BIDS suffixes
    % - remove prefix
    % - remove eventual derivatives entities
    % - change surface extension to a volume one
    % - use only .nii.gz
    bf = bids.File(derivatives, 'verbose', verbose, 'use_schema', false);

    if isempty(bf.modality)
        bf.modality = guess_modality(bf);
    end

    if ~ismember(bf.suffix, fieldnames(map.cfg.schema.content.objects.suffixes))
        rawsource{1} = 'TODO';
        return
    end

    bf.prefix = '';

    entities = fieldnames(bf.entities);
    idx = find(ismember(entities, map.cfg.entity_order));
    for i = 1:numel(idx)
        bf.entities.(entities{idx(i)}) = '';
    end

    if strcmp(bf.extension, '.surf.gii')
        bf.extension = '.nii';
    end

    if strcmp(bf.extension, '.nii')
        bf.extension = '.nii.gz';
    end

    rawsource{1} = fullfile(bf.bids_path, bf.filename);

end
