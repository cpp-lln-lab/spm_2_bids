function prefix_list = get_spm_prefix_list()
    %
    % load SPM default prefix values
    %
    %
    % (C) Copyright 2021 spm_2_bids developers

    spm_defaults = spm_get_defaults();
    prefix_list.stc = spm_defaults.slicetiming.prefix;
    prefix_list.realign = spm_defaults.realign.write.prefix;
    prefix_list.unwarp = spm_defaults.unwarp.write.prefix;
    prefix_list.coreg = spm_defaults.coreg.write.prefix;
    prefix_list.bias_cor = spm_defaults.deformations.modulate.prefix;
    prefix_list.norm = spm_defaults.normalise.write.prefix;
    prefix_list.smooth = spm_defaults.smooth.prefix;

end
