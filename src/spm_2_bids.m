function [new_filename, pth, json] = spm_2_bids(file, cfg)
    %
    % (C) Copyright 2021 spm_2_bids developers

    if nargin < 2
        cfg = struct();
    end
    cfg = check_cfg(cfg);

    p = bids.internal.parse_filename(file);

    prfx = get_spm_prefix_list();

    fprintf('%s', p.prefix);

    switch p.prefix

        case prfx.bias_cor
            spec = cfg.spm_2_bids.segment.bias_corrected;
        case 'c1'
            spec = cfg.spm_2_bids.segment.gm;
        case 'c2'
            spec = cfg.spm_2_bids.segment.wm;
        case 'c3'
            spec = cfg.spm_2_bids.segment.csf;
        case 'iy_'
            spec = cfg.spm_2_bids.segment.deformation_field.from_mni;
        case 'y_'
            spec = cfg.spm_2_bids.segment.deformation_field.to_mni;

        case prfx.stc
            spec = cfg.spm_2_bids.stc;

        case prfx.unwarp
            spec = cfg.spm_2_bids.realign_unwarp;

        case {'mean', ...
              ['mean' prfx.unwarp]}
            spec = cfg.spm_2_bids.mean;

        case { prfx.norm, ...
              [prfx.norm, prfx.bias_cor], ...
              [prfx.norm, prfx.unwarp,  prfx.stc], ...
              [prfx.norm, prfx.realign, prfx.stc], ...
              [prfx.norm, prfx.unwarp], ...
              [prfx.norm, prfx.realign]
             }
            spec = cfg.spm_2_bids.preproc_norm;

        case [prfx.norm, 'mean', prfx.unwarp]
            spec = cfg.spm_2_bids.normalized_mean;

        case [prfx.norm, 'c1']
            spec = cfg.spm_2_bids.segment.gm_norm;
        case [prfx.norm, 'c2']
            spec = cfg.spm_2_bids.segment.wm_norm;
        case [prfx.norm, 'c3']
            spec = cfg.spm_2_bids.segment.csf_norm;

        case {[prfx.smooth, prfx.norm], ...
              [prfx.smooth, prfx.norm, prfx.unwarp,  prfx.stc], ...
              [prfx.smooth, prfx.norm, prfx.realign, prfx.stc], ...
              [prfx.smooth, prfx.norm, prfx.unwarp], ...
              [prfx.smooth, prfx.norm, prfx.realign] ...
             }
            spec = cfg.spm_2_bids.smooth_norm;

        case { prfx.smooth, ...
              [prfx.smooth, prfx.unwarp,  prfx.stc], ...
              [prfx.smooth, prfx.realign, prfx.stc], ...
              [prfx.smooth, prfx.unwarp], ...
              [prfx.smooth, prfx.realign] ...
             }
            spec = cfg.spm_2_bids.smooth;

        otherwise
            warning('Unknown prefix: %s', p.prefix);
            [new_filename, pth] = spm_fileparts(file);
            json = [];
            return

    end

    if isfield(spec.entities, 'desc') && ...
            strcmp(spec.entities.desc, 'smth') && ...
            ~isempty(cfg.spm_2_bids.fwhm)
        spec.entities.desc = sprintf('smth%i', cfg.spm_2_bids.fwhm);
    end

    spec.prefix = '';
    spec.use_schema = false;

    overwrite = true;
    p = set_missing_fields(p, spec, overwrite);
    [new_filename, pth, json] = bids.create_filename(p, file);

    % TODO update json content

end

function prefix_list = get_spm_prefix_list()

    spm_defaults = spm_get_defaults();
    prefix_list.stc = spm_defaults.slicetiming.prefix;
    prefix_list.realign = spm_defaults.realign.write.prefix;
    prefix_list.unwarp = spm_defaults.unwarp.write.prefix;
    prefix_list.coreg = spm_defaults.coreg.write.prefix;
    prefix_list.bias_cor = spm_defaults.deformations.modulate.prefix;
    prefix_list.norm = spm_defaults.normalise.write.prefix;
    prefix_list.smooth = spm_defaults.smooth.prefix;

end

% case 'rc1'
% case 'rc2'
% case 'rc3'
% case 'rc1wmeanu'
% case 'rc2wmeanu'
% case 'rc3wmeanu'
% case 'rp_'
% case 'ru'
