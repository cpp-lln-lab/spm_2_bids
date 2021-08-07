function mapping = return_mapping(cfg)
    %
    % Maps a certain SPM prefix or sets of SPM prefixes to bids derivatives name spec

    % TODO
    % case 'rc1'
    % case 'rc2'
    % case 'rc3'
    % case 'rc1wmeanu'
    % case 'rc2wmeanu'
    % case 'rc3wmeanu'
    % case 'ru'

    prfx = get_spm_prefix_list();

    mapping = { ...
               { prfx.bias_cor },                                  cfg.spm_2_bids.segment.bias_corrected
               { 'c1' },                                           cfg.spm_2_bids.segment.gm
               { 'c2' },                                           cfg.spm_2_bids.segment.wm
               { 'c3' },                                           cfg.spm_2_bids.segment.csf
               { 'iy_' },                                          cfg.spm_2_bids.segment.deformation_field.from_mni
               { 'y_' },                                           cfg.spm_2_bids.segment.deformation_field.to_mni
               { prfx.stc },                                       cfg.spm_2_bids.stc
               { prfx.unwarp },                                    cfg.spm_2_bids.realign_unwarp
               { 'rp_', ['rp_' prfx.stc] },                        cfg.spm_2_bids.real_param
               { 'mean', ...
                ['mean' prfx.unwarp], ...
                ['mean' prfx.unwarp, prfx.stc] },                  cfg.spm_2_bids.mean
               { prfx.norm, ...
                [prfx.norm, prfx.bias_cor], ...
                [prfx.norm, prfx.unwarp,  prfx.stc], ...
                [prfx.norm, prfx.realign, prfx.stc], ...
                [prfx.norm, prfx.unwarp], ...
                [prfx.norm, prfx.realign] },                       cfg.spm_2_bids.preproc_norm
               { [prfx.norm, 'mean', prfx.unwarp] },               cfg.spm_2_bids.normalized_mean
               { [prfx.norm, 'c1'] },                              cfg.spm_2_bids.segment.gm_norm
               { [prfx.norm, 'c2'] },                              cfg.spm_2_bids.segment.wm_norm
               { [prfx.norm, 'c3'] },                              cfg.spm_2_bids.segment.csf_norm
               { [prfx.smooth, prfx.norm], ...
                [prfx.smooth, prfx.norm, prfx.unwarp,  prfx.stc], ...
                [prfx.smooth, prfx.norm, prfx.realign, prfx.stc], ...
                [prfx.smooth, prfx.norm, prfx.unwarp], ...
                [prfx.smooth, prfx.norm, prfx.realign] },          cfg.spm_2_bids.smooth_norm
               { prfx.smooth, ...
                [prfx.smooth, prfx.unwarp,  prfx.stc], ...
                [prfx.smooth, prfx.realign, prfx.stc], ...
                [prfx.smooth, prfx.unwarp], ...
                [prfx.smooth, prfx.realign] },                     cfg.spm_2_bids.smooth
              };

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
