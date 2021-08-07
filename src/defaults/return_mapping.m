function mapping = return_mapping(cfg)
    %
    % Maps a certain SPM prefix or sets of SPM prefixes to bids derivatives name spec
    %
    % (C) Copyright 2021 spm_2_bids developers

    % TODO
    % case 'rc1'
    % case 'rc2'
    % case 'rc3'
    % case 'rc1wmeanu'
    % case 'rc2wmeanu'
    % case 'rc3wmeanu'
    % case 'ru'

    prfx = get_spm_prefix_list();

    mapping(1).prefix = { prfx.bias_cor };
    mapping(1).name_spec = cfg.spm_2_bids.segment.bias_corrected;

    mapping(end + 1).prefix = { 'c1' };
    mapping(end).name_spec = cfg.spm_2_bids.segment.gm;

    mapping(end + 1).prefix = { 'c2' };
    mapping(end).name_spec = cfg.spm_2_bids.segment.wm;

    mapping(end + 1).prefix = { 'c3' };
    mapping(end).name_spec = cfg.spm_2_bids.segment.csf;

    mapping(end + 1).prefix = { 'iy_' };
    mapping(end).name_spec = cfg.spm_2_bids.segment.deformation_field.from_mni;

    mapping(end + 1).prefix = { 'y_' };
    mapping(end).name_spec = cfg.spm_2_bids.segment.deformation_field.to_mni;

    mapping(end + 1).prefix = { prfx.stc };
    mapping(end).name_spec = cfg.spm_2_bids.stc;

    mapping(end + 1).prefix = { prfx.unwarp };
    mapping(end).name_spec = cfg.spm_2_bids.realign_unwarp;

    mapping(end + 1).prefix = { 'rp_', ['rp_' prfx.stc] };
    mapping(end).name_spec = cfg.spm_2_bids.real_param;

    mapping(end + 1).prefix = { 'mean', ...
                               ['mean' prfx.unwarp], ...
                               ['mean' prfx.unwarp, prfx.stc] };
    mapping(end).name_spec = cfg.spm_2_bids.mean;

    mapping(end + 1).prefix = { prfx.norm, ...
                               [prfx.norm, prfx.bias_cor], ...
                               [prfx.norm, prfx.unwarp,  prfx.stc], ...
                               [prfx.norm, prfx.realign, prfx.stc], ...
                               [prfx.norm, prfx.unwarp], ...
                               [prfx.norm, prfx.realign] };
    mapping(end).name_spec = cfg.spm_2_bids.preproc_norm;

    mapping(end + 1).prefix = { [prfx.norm, 'mean', prfx.unwarp] };
    mapping(end).name_spec = cfg.spm_2_bids.normalized_mean;

    mapping(end + 1).prefix = { [prfx.norm, 'c1'] };
    mapping(end).name_spec = cfg.spm_2_bids.segment.gm_norm;

    mapping(end + 1).prefix = { [prfx.norm, 'c2'] };
    mapping(end).name_spec = cfg.spm_2_bids.segment.wm_norm;

    mapping(end + 1).prefix = { [prfx.norm, 'c3'] };
    mapping(end).name_spec = cfg.spm_2_bids.segment.csf_norm;

    mapping(end + 1).prefix = {[prfx.smooth, prfx.norm], ...
                               [prfx.smooth, prfx.norm, prfx.unwarp,  prfx.stc], ...
                               [prfx.smooth, prfx.norm, prfx.realign, prfx.stc], ...
                               [prfx.smooth, prfx.norm, prfx.unwarp], ...
                               [prfx.smooth, prfx.norm, prfx.realign] };
    mapping(end).name_spec = cfg.spm_2_bids.smooth_norm;

    mapping(end + 1).prefix = { prfx.smooth, ...
                               [prfx.smooth, prfx.unwarp,  prfx.stc], ...
                               [prfx.smooth, prfx.realign, prfx.stc], ...
                               [prfx.smooth, prfx.unwarp], ...
                               [prfx.smooth, prfx.realign]};
    mapping(end).name_spec = cfg.spm_2_bids.smooth;

end

function prefix_list = get_spm_prefix_list()
    %
    % load SPM default prefix values
    %

    spm_defaults = spm_get_defaults();
    prefix_list.stc = spm_defaults.slicetiming.prefix;
    prefix_list.realign = spm_defaults.realign.write.prefix;
    prefix_list.unwarp = spm_defaults.unwarp.write.prefix;
    prefix_list.coreg = spm_defaults.coreg.write.prefix;
    prefix_list.bias_cor = spm_defaults.deformations.modulate.prefix;
    prefix_list.norm = spm_defaults.normalise.write.prefix;
    prefix_list.smooth = spm_defaults.smooth.prefix;

end
