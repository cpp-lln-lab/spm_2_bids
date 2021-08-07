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

    p = bids.internal.parse_filename(file);

    spec = [];
    for iMapping = 1:size(cfg.spm_2_bids.mapping, 1)
        if ismember(p.prefix, cfg.spm_2_bids.mapping{iMapping, 1})
            spec = cfg.spm_2_bids.mapping{iMapping, 2};
            break;
        end
    end

    if isempty(spec)
        warning('Unknown prefix: %s', p.prefix);
        [new_filename, pth] = spm_fileparts(file);
        json = [];
        return
    end

    spec = add_fwhm_to_smooth_label(spec, cfg);

    spec = adapt_from_label_to_input(spec, p);

    spec = use_config_spec(spec, p, cfg);

    overwrite = true;
    spec.prefix = '';
    spec.use_schema = false;
    p = set_missing_fields(p, spec, overwrite);

    [new_filename, pth, json] = bids.create_filename(p, file);

    % TODO update json content

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

function spec = use_config_spec(spec, p, cfg)
    %
    % overwrite with user defined spec
    % and reorder entities
    %

    overwrite = true;

    if ~isempty(cfg.spm_2_bids.spec) && ~any(strcmp(p.prefix, {'iy_', 'y_', 'rp_'}))

        spec = set_missing_fields(spec, cfg.spm_2_bids.spec, overwrite);

        present_entities = ismember(cfg.spm_2_bids.entity_order, fieldnames(spec.entities));
        entity_order = cfg.spm_2_bids.entity_order(present_entities);

        spec.entities = orderfields(spec.entities, entity_order);
    end

end
