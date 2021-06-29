function [new_filename, pth, json] = spm_2_bids(file, cfg)
    %
    % (C) Copyright 2021 spm_2_bids developers

    if nargin < 2 || isempty(cfg)
        cfg = check_cfg();
    end

    p = bids.internal.parse_filename(file);

    spm_defaults = spm_get_defaults();
    prfx.stc = spm_defaults.slicetiming.prefix;
    prfx.realign = spm_defaults.realign.write.prefix;
    prfx.unwarp = spm_defaults.unwarp.write.prefix;
    prfx.coreg = spm_defaults.coreg.write.prefix;
    prfx.bias_cor = spm_defaults.deformations.modulate.prefix;
    prfx.norm = spm_defaults.normalise.write.prefix;
    prfx.smooth = spm_defaults.smooth.prefix;

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

        case {[prfx.norm prfx.unwarp prfx.stc], ...
              [prfx.norm prfx.unwarp], ...
              [prfx.norm prfx.realign], ...
              [prfx.norm prfx.realign prfx.stc]}
            spec = cfg.spm_2_bids.preproc_norm;

        case [prfx.norm 'mean' prfx.unwarp]
            spec = cfg.spm_2_bids.normalized_mean;

        case [prfx.norm 'c1']
            spec = cfg.spm_2_bids.segment.gm_norm;
        case [prfx.norm 'c2']
            spec = cfg.spm_2_bids.segment.wm_norm;
        case [prfx.norm 'c3']
            spec = cfg.spm_2_bids.segment.csf_norm;

        case {'w', 'wua', 'wu', 'wr', 'wra', 'wm'}
            spec = cfg.spm_2_bids.preproc_norm;

        case {'swu', 'swr', 'swua', 'swra'}

        case {'su' 'sr', 'sua' 'sra'}

    end

    spec.prefix = '';
    spec.use_schema = false;

    overwrite = true;
    p = set_missing_fields(p, spec, overwrite);
    [new_filename, pth, json] = bids.create_filename(p, file);

    % TODO update json content

end

% case 'rc1'
% case 'rc2'
% case 'rc3'
% case 'rc1wmeanu'
% case 'rc2wmeanu'
% case 'rc3wmeanu'
% case 'rp_'
% case 'ru'
