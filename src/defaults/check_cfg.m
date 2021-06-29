function cfg = check_cfg(cfg)
    %
    % Check the option inputs and add any missing field with some defaults
    %
    %
    % USAGE::
    %
    % cfg = check_cfg(cfg)
    %
    % :param cfg: structure or json filename containing the spm_2_bids.anat.
    % :type cfg: structure
    %
    % :returns:
    %
    % - :cfg: the option structure with missing values filled in by the defaults.
    %
    % REQUIRED FIELDS:
    %
    % (C) Copyright 2021 spm_2_bids developers

    if nargin < 1
        cfg = struct();
    end

    fields_to_set = set_default_cfg();

    cfg = set_missing_fields(cfg, fields_to_set);

    cfg = set_missing_fields(cfg, fields_to_set);

    check_fields(cfg);

    cfg = orderfields(cfg);

end

function fields_to_set = set_default_cfg()

    SPM_SPACE = 'IXI549Space';

    segment.normalized = struct('entities', struct('space', 'IXI549Space'));

    % Segmentation output
    segment.bias_corrected = struct('entities', struct('desc', 'biascor'));

    segment_gen = @(x) struct('entities', struct('space', 'individual', ...
                                                 'label', x), ...
                              'suffix', 'probseg');
    segment.gm = segment_gen('GM');
    segment.wm = segment_gen('WM');
    segment.csf = segment_gen('CSF');
    segment.bone = segment_gen('B');
    segment.soft = segment_gen('ST');
    segment.air = segment_gen('air');

    norm_segment_gen = @(x) struct('entities', struct('space', SPM_SPACE, ...
                                                      'label', x), ...
                                   'suffix', 'probseg');
    segment.gm_norm = norm_segment_gen('GM');
    segment.wm_norm = norm_segment_gen('WM');
    segment.csf_norm = norm_segment_gen('CSF');
    segment.bone_norm = norm_segment_gen('B');
    segment.soft_norm = norm_segment_gen('ST');
    segment.air_norm = norm_segment_gen('air');

    % TODO update to to adapt to input image suffix
    segment.deformation_field.to_mni = struct('entities', struct( ...
                                                                 'from', 'T1w', ...
                                                                 'to', SPM_SPACE, ...
                                                                 'mode', 'image'), ...
                                              'suffix', 'xfm');

    segment.deformation_field.from_mni = struct('entities', ...
                                                struct('from', SPM_SPACE, ...
                                                       'to', 'T1w', ...
                                                       'mode', 'image'), ...
                                                'suffix', 'xfm');

    fields_to_set.spm_2_bids.segment = segment;

    % Preprocessed data
    fields_to_set.spm_2_bids.stc = struct('entities', struct('space', 'individual', ...
                                                             'desc', 'stc'));
    fields_to_set.spm_2_bids.realign_unwarp = struct('entities', struct('space', 'individual', ...
                                                                        'desc', 'realignUnwarp'));
    fields_to_set.spm_2_bids.mean = struct('entities', struct('space', 'individual', ...
                                                              'desc', 'mean'));
    fields_to_set.spm_2_bids.normalized_mean = fields_to_set.spm_2_bids.mean;
    fields_to_set.spm_2_bids.normalized_mean.entities.space = SPM_SPACE;

    fields_to_set.spm_2_bids.preproc = struct('entities', struct('space', 'individual', ...
                                                                 'desc', 'preproc'));

    fields_to_set.spm_2_bids.preproc_norm = fields_to_set.spm_2_bids.preproc;
    fields_to_set.spm_2_bids.preproc_norm.entities.space = SPM_SPACE;

    fields_to_set.spm_2_bids.smooth.entities.space = struct('entities', struct('space', 'individual', ...
                                                                               'desc', 'smth'));

end

function check_fields(cfg)
end
