function [new_filename, pth, json] = spm_2_bids(file, map)
    %
    % Provides a bids derivatives name for a file preprocessed with SPM
    %
    % USAGE::
    %
    %   [new_filename, pth, json] = spm_2_bids(file)
    %   [new_filename, pth, json] = spm_2_bids(file, map)
    %
    % :param file: SPM preprocessed filename (can be fullpath);
    %              for example ``wmsub-01_ses-01_T1w.nii``
    % :type file: string
    % :param map: optional spm_2_bids map to overwrite the default 
    %             map (see Mapping)
    % :param map: Mapping object
    %
    % :returns: - :new_filename: (string) BIDS compatible filename
    %               for example ``sub-01_ses-01_space-IXI549Space_desc-preproc_T1w.nii``;
    %           - :pth: (string) relative BIDS path
    %               for example ``sub-01/ses-01``
    %           - :json: (structure) JSON derivatives content
    %
    % The behaviour of which prefix gives which BIDS derivatives can be modified by
    % adapting the ``cfg``.
    %
    %
    % (C) Copyright 2021 spm_2_bids developers

    if nargin < 2
        map = Mapping();
        map = map.default();
    end

    mapping = map.mapping;
    cfg = map.cfg;
    
    use_suffix_as_label = false;
    
    % deal with suffixes modified by SPM
    % turns them into prefixes that can be handled by the default mapping
    if strfind(file, '_uw.mat') %#ok<*STRIFCND>
        file = spm_file(file, 'prefix', 'unwarpparam_');
        file = strrep(file, '_uw.mat', '.mat');
        use_suffix_as_label = true;
    end
    if strfind(file, '_seg8.mat') %#ok<*STRIFCND>
        file = spm_file(file, 'prefix', 'segparam_');
        file = strrep(file, '_seg8.mat', '.mat');
        use_suffix_as_label = true;
    end

    pth = spm_fileparts(file);
    new_filename = spm_file(file, 'filename');
    json = [];

    p = bids.internal.parse_filename(file);

    % TO DO allow renaming even if there is no prefix ?
    if isempty(p.prefix)
        return
    end

    spec = [];

    % TODO se if some of the bids-query machinery cannot be kept for identifying
    % the right mapping
    
    % look for the right prefix in the mapping
    prefix_match = map.find_mapping('prefix', p.prefix);

    % TODO implement methods in Mapping to filter by suffix / extention /
    % entities
    
    % if any suffix / extention mentioned in the mapping we check for that as well
    % if none is mentioned anywhere in the mapping then anything goes
    suffix_match = true(size(mapping));
    if ~all(cellfun('isempty', {mapping.suffix}'))
        suffix_match = any([strcmp({mapping.suffix}', p.suffix), ...
                            strcmp({mapping.suffix}', '*')], 2);
    end
    ext_match = true(size(mapping));
    if ~all(cellfun('isempty', {mapping.ext}'))
        ext_match = any([strcmp({mapping.ext}', p.ext), ...
                         strcmp({mapping.ext}', '*')], 2);
    end

    % we compare the entities-label pairs present in the file
    % to those required in the mapping (if any)
    % if no entity requirement anywhere in the mapping then anything goes
    entitiy_match = true(size(mapping));

    needs_entity_check = ~cellfun('isempty', {mapping.entities}');
    if any(needs_entity_check)

        entitiy_match = false(size(mapping));

        idx = find(needs_entity_check);
        for i = 1:numel(idx)
            status = check_field_content(p.entities, mapping(idx(i)).entities);
            entitiy_match(idx(i)) = status;
        end
    end

    this_mapping = [prefix_match, suffix_match, entitiy_match, ext_match];

    % We check whether all conditons are met
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

    if isempty(spec)
        %TODO this warning should probably go in the find_mapping methods
        msg = sprintf('Unknown prefix: %s', p.prefix);
        warning('spm_2_bids:unknownPrefix', msg); %#ok<SPWRN>
        return
    end

    spec = add_fwhm_to_smooth_label(spec, cfg);

    spec = adapt_from_label_to_input(spec, p);
    
    if use_suffix_as_label
        spec.entities.label = p.suffix;
    end

    spec = use_config_spec(spec, cfg);

    overwrite = true;
    spec.prefix = '';
    spec.use_schema = false;
    p = set_missing_fields(p, spec, overwrite);

    p = reorder_entities(p, cfg);

    [new_filename, pth, json] = bids.create_filename(p, file);

    % TODO update json content
    p = bids.internal.parse_filename(file);
    json.content.RawSources{1} = strrep(p.filename, p.prefix, '');

end

function spec = add_fwhm_to_smooth_label(spec, cfg)
    %
    % adds the FWHM to the description label for smoothing
    %

    if isfield(spec, 'entities') && ...
        isfield(spec.entities, 'desc') && ...
            strcmp(spec.entities.desc, 'smth') && ...
            ~isempty(cfg.fwhm)
        spec.entities.desc = sprintf('smth%i', cfg.fwhm);
    end

end

function spec = adapt_from_label_to_input(spec, p)
    %
    % for deformation fields
    %

    if strcmp(p.prefix, 'y_')
        spec.entities.from = p.suffix;
        spec.entities = orderfields(spec.entities, {'from', 'to', 'mode'});
    elseif strcmp(p.prefix, 'iy_')
        spec.entities.to = p.suffix;
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

function p = reorder_entities(p, cfg)
    %
    % put entity from raw bids before those of derivatives
    % and make sure that derivatives entities are in the right order
    %
    %

    entities = fieldnames(p.entities);

    is_raw_entity = ~ismember(entities, cfg.entity_order);

    raw_entities = entities(is_raw_entity);

    derivative_entities_present = ismember(cfg.entity_order, ...
                                           entities(~is_raw_entity));
    derivative_entities = cfg.entity_order(derivative_entities_present);

    p.entity_order = cat(1, raw_entities, derivative_entities);

end
