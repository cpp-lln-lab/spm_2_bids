function cfg = check_cfg(cfg)
    %
    % Check the option inputs and add any missing field with some defaults
    %
    %
    % USAGE::
    %
    %   cfg = check_cfg(cfg)
    %
    % :param cfg: structure or json filename containing the spm_2_bids.anat.
    % :type cfg: structure
    %
    % :returns:
    %
    % - :cfg: the option structure with missing values filled in by the defaults.
    %
    % ``cfg`` fields:
    %
    % - ``all_entity_order``: order of all the official bids entities
    % - ``entity_order``: order of the entities in bids derivatives
    % - ``fwhm``: value to append to smoothing desctiption label
    % - ``spec``: specfication details to over ride some of the defaults
    %
    % BIDS derivatives defining fields:
    %
    % Each of those fields contain a structure that lists the BIDS suffix
    % and entities-label pairs for each type of preprocessed image.
    %
    % - ``segment``
    % - ``stc``
    % - ``realign_unwarp``
    % - ``real_param``
    % - ``mean``
    % - ``normalized_mean``
    % - ``preproc``
    % - ``preproc_norm``
    % - ``smooth``
    % - ``smooth_norm``
    %
    % For example:
    %
    % .. code-block:: matlab
    %
    %   % for grey matter segmentation output
    %   cfg.segment.gm = struct('entities', struct('space', 'individual', ...
    %                                              'label', x), ...
    %                           'suffix', 'probseg')
    %
    %
    %

    % (C) Copyright 2021 spm_2_bids developers

    if nargin < 1
        cfg = struct();
    end

    fields_to_set = set_default_cfg();

    cfg = set_missing_fields(cfg, fields_to_set);

    cfg = orderfields(cfg);

end

function fields_to_set = set_default_cfg()

    SPM_SPACE = 'IXI549Space';

    % TODO DARTEL uses
    % MNI152NLin2009[a-c][Sym|Asym]
    %
    % See section: standard-template-identifiers of
    % https://bids-specification.readthedocs.io/en/latest/99-appendices/08-coordinate-systems.html

    fields_to_set.space = SPM_SPACE;

    % just to keep track of all the BIDS entities in the cfg
    bidsFile = bids.File('sub-01_T1.nii', 'use_schema', false);
    bidsFile = bidsFile.reorder_entities;
    fields_to_set.schema = bids.Schema;
    fields_to_set.all_entity_order = bidsFile.entity_order;

    fields_to_set.entity_order = {'hemi'; ...
                                  'space'; ...
                                  'atlas'; ...
                                  'res'; ...
                                  'den'; ...
                                  'label'; ...
                                  'from'; ...
                                  'to'; ...
                                  'mode'; ...
                                  'desc'};

    fields_to_set.fwhm = [];

    fields_to_set.spec = struct([]);

    % function to generate structures
    desc_gen = @(x) struct('entities', struct('space', 'individual', ...
                                              'desc', x));
    segment_gen = @(x) struct('entities', struct('space', 'individual', ...
                                                 'label', x), ...
                              'suffix', 'probseg');
    norm_segment_gen = @(x) struct('entities', struct('space', SPM_SPACE, ...
                                                      'label', x), ...
                                   'suffix', 'probseg');

    % Segmentation output
    segment.bias_corrected = desc_gen('biascor');

    segment.gm = segment_gen('GM');
    segment.wm = segment_gen('WM');
    segment.csf = segment_gen('CSF');
    segment.bone = segment_gen('B');
    segment.soft = segment_gen('ST');
    segment.air = segment_gen('air');

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

    segment.param = struct('label', 'TBD', 'suffix', 'segparam');

    fields_to_set.segment = segment;

    % Preprocessed data
    fields_to_set.stc = desc_gen('stc');

    fields_to_set.realign_unwarp = desc_gen('realignUnwarp');
    fields_to_set.realign_unwarp_param = struct('label', 'TBD', 'suffix', 'unwarpparam');
    fields_to_set.real_param = struct('suffix', 'motion', ...
                                      'ext', '.tsv');

    fields_to_set.mean = desc_gen('mean');
    % remove the run entity
    fields_to_set.mean.entities.run = '';

    fields_to_set.normalized_mean = fields_to_set.mean;
    fields_to_set.normalized_mean.entities.space = SPM_SPACE;

    fields_to_set.preproc = desc_gen('preproc');
    fields_to_set.preproc_norm = fields_to_set.preproc;
    fields_to_set.preproc_norm.entities.space = SPM_SPACE;

    % Smooth
    fields_to_set.smooth = desc_gen('smth');
    fields_to_set.smooth_norm = fields_to_set.smooth;
    fields_to_set.smooth_norm.entities.space = SPM_SPACE;

end
