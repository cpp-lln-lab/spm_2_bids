function [new_filename, pth, json] = spm_2_bids(file, cfg)
    %
    % Provides a bids derivatives name for a file preprocessed with SPM
    %
    % USAGE::
    %
    %   [new_filename, pth, json] = spm_2_bids(file)
    %   [new_filename, pth, json] = spm_2_bids(file, cfg)
    %
    % :param file: SPM preprocessed filename (can be fullpath);
    %              for example ``wmsub-01_ses-01_T1w.nii``
    % :type file: string
    % :param cfg: optional spm_2_bids configuration to overwrite the default
    %   conffiguration (see check_cfg)
    % :param cfg: structure
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
        cfg = struct();
    end
    cfg = check_cfg(cfg);

    mapping = cfg.spm_2_bids.mapping;

    pth = spm_fileparts(file);
    new_filename = spm_file(file, 'filename');
    json = [];

    p = bids.internal.parse_filename(file);

    if isempty(p.prefix)
        return
    end

    spec = [];

    % look for the right prefix in the mapping
    prefix_match = strcmp({mapping.prefix}', p.prefix);

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
        msg = sprintf('Unknown prefix: %s', p.prefix);
        warning('spm_2_bids:unknownPrefix', msg); %#ok<SPWRN>
        return
    end

    spec = add_fwhm_to_smooth_label(spec, cfg);

    spec = adapt_from_label_to_input(spec, p);

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

    if isfield(spec.entities, 'desc') && ...
            strcmp(spec.entities.desc, 'smth') && ...
            ~isempty(cfg.spm_2_bids.fwhm)
        spec.entities.desc = sprintf('smth%i', cfg.spm_2_bids.fwhm);
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

    if ~isempty(cfg.spm_2_bids.spec)

        spec = set_missing_fields(spec, cfg.spm_2_bids.spec, overwrite);

        present_entities = ismember(cfg.spm_2_bids.entity_order, fieldnames(spec.entities));
        entity_order = cfg.spm_2_bids.entity_order(present_entities);

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

    is_raw_entity = ~ismember(entities, cfg.spm_2_bids.entity_order);

    raw_entities = entities(is_raw_entity);

    derivative_entities_present = ismember(cfg.spm_2_bids.entity_order, ...
                                           entities(~is_raw_entity));
    derivative_entities = cfg.spm_2_bids.entity_order(derivative_entities_present);

    p.entity_order = cat(1, raw_entities, derivative_entities);

end
