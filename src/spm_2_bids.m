function [new_filename, pth, json] = spm_2_bids(varargin)
    %
    % Provides a bids derivatives name for a file preprocessed with SPM
    %
    % USAGE::
    %
    %   [new_filename, pth, json] = spm_2_bids(file [, map][, verbose])
    %
    % :param file: SPM preprocessed filename (can be fullpath);
    %              for example ``wmsub-01_ses-01_T1w.nii``
    % :type file: string
    %
    % :param map: optional spm_2_bids map to overwrite the default
    %             map (see Mapping)
    % :param map: Mapping object
    %
    % :param verbose:
    % :param verbose: boolean
    %
    % :returns: - :new_filename: (string) BIDS compatible filename
    %               for example ``sub-01_ses-01_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii``;
    %           - :pth: (string) relative BIDS path
    %               for example ``sub-01/ses-01``
    %           - :json: (structure) JSON derivatives content
    %
    % The behaviour of which prefix gives which BIDS derivatives can be modified by
    % adapting the ``cfg``.
    %
    %

    % (C) Copyright 2021 spm_2_bids developers

    args = inputParser;

    addRequired(args, 'file', @ischar);
    addOptional(args, 'map', []);
    addOptional(args, 'verbose', true, @islogical);

    parse(args, varargin{:});

    file = args.Results.file;
    map = args.Results.map;
    verbose = args.Results.verbose;

    if isempty(map)
        map = Mapping();
        map = map.default();
    end

    mapping = map.mapping;
    cfg = map.cfg;

    % deal with suffixes modified by SPM
    % turns them into prefixes that can be handled by the default mapping
    use_suffix_as_label = false;
    [file, status(1)] = turn_spm_suffix_in_prefix(file, '_uw.mat', 'unwarpparam_');
    [file, status(2)] = turn_spm_suffix_in_prefix(file, '_seg8.mat', 'segparam_');
    if any(status)
        use_suffix_as_label = true;
    end

    bf = bids.File(file, 'use_schema', false);
    pth = bf.bids_path;
    new_filename = bf.filename;

    json = [];

    % TO DO allow renaming even if there is no prefix ?
    if isempty(bf.prefix)
        return
    end

    spec = [];

    % TODO see if some of the bids-query machinery cannot be kept for identifying
    % the right mapping

    % look for the right prefix in the mapping
    prefix_match = map.find_mapping('prefix', bf.prefix);

    % TODO implement methods in Mapping to filter by suffix / extension /
    % entities

    % if any suffix / extension mentioned in the mapping we check for that as well
    % if none is mentioned anywhere in the mapping then anything goes
    suffix_match = true(size(mapping));
    if ~all(cellfun('isempty', {mapping.suffix}'))
        suffix_match = any([strcmp({mapping.suffix}', bf.suffix), ...
                            strcmp({mapping.suffix}', '*')], 2);
    end
    ext_match = true(size(mapping));
    if ~all(cellfun('isempty', {mapping.ext}'))
        ext_match = any([strcmp({mapping.ext}', bf.extension), ...
                         strcmp({mapping.ext}', '*')], 2);
    end

    entitiy_match = get_entity_match(mapping, bf);

    this_mapping = [prefix_match, suffix_match, entitiy_match, ext_match];

    % We check whether all conditions are met
    % otherwise we only rely on the prefix
    if any(sum(this_mapping, 2) > 0) && any(prefix_match)

        MAX = size(this_mapping, 2);
        if any(sum(this_mapping, 2) == MAX)
            idx = sum(this_mapping, 2) == MAX;
        else
            idx = all([sum(this_mapping, 2) == 1, prefix_match], 2);
        end

        spec = mapping(idx).name_spec;
    end

    if isempty(spec) && verbose
        if isnan(str2double(bf.prefix(1))) && ...
            ~bids.internal.starts_with(bf.prefix, 'c4') && ... % ALI toolbox prefixes
             ~bids.internal.starts_with(bf.prefix, 'td_') % spmup toolbox truncated prefixes

            % TODO this warning should probably go in the find_mapping methods
            msg = sprintf('Unknown prefix: %s', bf.prefix);
            warning('spm_2_bids:unknownPrefix', msg); %#ok<SPWRN>

        end
        return
    end

    spec = add_fwhm_to_smooth_label(spec, cfg);

    spec = adapt_from_label_to_input(spec, bf);

    if use_suffix_as_label
        spec.entities.label = bf.suffix;
    end

    spec = use_config_spec(spec, cfg);

    bf = update_filename(bf, spec, cfg);

    % arg out
    pth = bf.bids_path;

    new_filename = bf.filename;

    %% metadata
    json = set_metadata(file, map, verbose, bf);

end

function entitiy_match = get_entity_match(mapping, bf)
    % we compare the entities-label pairs present in the file
    % to those required in the mapping (if any)
    % if no entity requirement anywhere in the mapping then anything goes
    entitiy_match = true(size(mapping));

    needs_entity_check = ~cellfun('isempty', {mapping.entities}');
    if any(needs_entity_check)

        entitiy_match = false(size(mapping));

        idx = find(needs_entity_check);
        for i = 1:numel(idx)
            status = check_field_content(bf.entities, mapping(idx(i)).entities);
            entitiy_match(idx(i)) = status;
        end
    end
end

function json = set_metadata(file, map, verbose, bf)

    json = bids.derivatives_json(bf.filename);

    if strcmp(bf.suffix, 'probseg')
        json.content.Manual = false;
    end

    content = json.content;

    content.RawSources = identify_rawsources(file, map, verbose);

    Sources = identify_sources(file, map, verbose);
    if ~isempty(Sources)
        content.Sources = Sources;
    elseif isfield(content, 'Sources')
        content = rmfield(content, 'Sources');
    end

    if isfield(bf.entities, 'space') && strcmp(bf.entities.space, 'space-MNI152NLin2009cAsym')
        content.SpatialReference  = struct('space-MNI152NLin2009cAsym', ...
                                           ['ICBM 152 Nonlinear Asymmetrical template version 2009c ', ...
                                            'http://nist.mni.mcgill.ca/?p=904']);
    end

    json.content = content;

end

function bf = update_filename(bf, spec, cfg)

    bf.prefix = '';
    if isfield(spec, 'suffix')
        bf.suffix = spec.suffix;
    end
    if isfield(spec, 'ext')
        bf.extension = spec.ext;
    end
    if isfield(spec, 'entities')
        entities = fieldnames(spec.entities);
        for i = 1:numel(entities)
            bf = bf.set_entity(entities{i}, spec.entities.(entities{i}));
        end
    end

    bf = reorder_entities(bf, cfg);
    bf = bf.update;

end

function bf = add_fwhm_to_smooth_label(bf, cfg)
    %
    % adds the FWHM to the description label for smoothing
    %

    if isfield(bf, 'entities') && ...
        isfield(bf.entities, 'desc') && ...
            strcmp(bf.entities.desc, 'smth') && ...
            ~isempty(cfg.fwhm)
        bf.entities.desc = sprintf('smth%i', cfg.fwhm);
    end

end

function spec = adapt_from_label_to_input(spec, bf)
    %
    % for deformation fields
    %

    if strcmp(bf.prefix, 'y_')
        spec.entities.from = bf.suffix;
        spec.entities = orderfields(spec.entities, {'from', 'to', 'mode'});
    elseif strcmp(bf.prefix, 'iy_')
        spec.entities.to = bf.suffix;
        spec.entities = orderfields(spec.entities, {'from', 'to', 'mode'});
    end

end

function spec = use_config_spec(spec, cfg)
    %
    % overwrite with user defined spec
    % and reorder entities
    %

    overwrite = true;

    if ~isempty(cfg.spec)

        spec = set_missing_fields(spec, cfg.spec, overwrite);

        present_entities = ismember(cfg.entity_order, fieldnames(spec.entities));
        entity_order = cfg.entity_order(present_entities);

        spec.entities = orderfields(spec.entities, entity_order);
    end

end

function bf = reorder_entities(bf, cfg)
    %
    % put entity from raw bids before those of derivatives
    % and make sure that derivatives entities are in the right order
    %
    %

    % TODO should be simplifiable with bids.File

    entities = fieldnames(bf.entities);

    is_raw_entity = ~ismember(entities, cfg.entity_order);

    raw_entities = entities(is_raw_entity);

    derivative_entities_present = ismember(cfg.entity_order, ...
                                           entities(~is_raw_entity));
    derivative_entities = cfg.entity_order(derivative_entities_present);

    bf = bf.reorder_entities(cat(1, raw_entities, derivative_entities));

end

function [filename, status] = turn_spm_suffix_in_prefix(filename, pattern, string)
    status = false;

    if strfind(filename, pattern) %#ok<*STRIFCND>
        filename = bids.internal.file_utils(filename, 'prefix', string);
        filename = strrep(filename, ...
                          pattern, ...
                          ['.' bids.internal.file_utils(filename, 'ext')]);
        status = true;
    end
end
