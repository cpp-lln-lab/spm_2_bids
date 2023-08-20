% (C) Copyright 2021 spm_2_bids developers

function test_suite = test_spm_2_bids_metadata %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_spm_2_bids_non_raw_suffix()

    file = fullfile('sub-01', 'func', 'wuasub-01_task-foo_mask.nii');

    [~, ~, json] = spm_2_bids(file, [], false);

    assertEqual(fieldnames(json), {'filename'; 'content'});
    assertEqual(json.content.RawSources{1}, fullfile('sub-01', 'func', ...
                                                     'sub-01_task-foo_mask.nii.gz'));

    too_long = fullfile('sub-01', 'func', ...
                        'sub-01_task-foo_space-individual_desc-realignUnwarp_mask.nii');
    assertEqual(json.content.Sources{end}, too_long);

    bids.util.jsonencode(json.filename, json.content);

end

function test_spm_2_bids_metadata_with_non_raw_entity()

    file = fullfile('sub-01', 'func', 'usub-01_task-foo_desc-stc_bold.nii');

    [~, ~, json] = spm_2_bids(file, [], false);

    assertEqual(fieldnames(json), {'filename'; 'content'});
    assertEqual(json.content.RawSources{1}, fullfile('sub-01', ...
                                                     'func', ...
                                                     'sub-01_task-foo_bold.nii.gz'));
    assertEqual(json.content.Sources{1}, ...
                fullfile('sub-01', 'func', 'sub-01_task-foo_desc-stc_bold.nii'));

    bids.util.jsonencode(json.filename, json.content);

end

function test_spm_2_bids_metadata_func()

    file = fullfile('sub-01', 'func', 'wuasub-01_task-foo_bold.nii');

    [~, ~, json] = spm_2_bids(file, [], false);

    assertEqual(fieldnames(json), {'filename'; 'content'});
    assertEqual(json.content.RawSources{1}, fullfile('sub-01', ...
                                                     'func', ...
                                                     'sub-01_task-foo_bold.nii.gz'));
    assertEqual(json.content.Sources{2}, ...
                fullfile('sub-01', ...
                         'func', ...
                         'sub-01_task-foo_space-individual_desc-realignUnwarp_bold.nii'));
    assertEqual(json.content.Sources{1}, 'TODO: add deformation field');

    bids.util.jsonencode(json.filename, json.content);

end

function test_spm_2_bids_metadata_surface()

    file = fullfile('sub-01', 'anat', 'wmsub-01_T1w.surf.gii');

    [~, ~, json] = spm_2_bids(file, [], false);

    assertEqual(fieldnames(json), {'filename'; 'content'});
    assertEqual(json.content.RawSources{1}, fullfile('sub-01', 'anat', 'sub-01_T1w.nii.gz'));
    assertEqual(json.content.Sources{end}, ...
                fullfile('sub-01', 'anat', 'sub-01_space-IXI549Space_desc-preproc_T1w.nii'));

    bids.util.jsonencode(json.filename, json.content);

end

function test_spm_2_bids_metadata_probseg()

    file = fullfile('sub-01', 'anat', 'c1sub-01_T1w.nii');

    [~, ~, json] = spm_2_bids(file, [], false);

    assertEqual(fieldnames(json), {'filename'; 'content'});
    assertEqual(json.content.RawSources{1}, fullfile('sub-01', 'anat', 'sub-01_T1w.nii.gz'));
    assertEqual(json.content.Manual, false);

    bids.util.jsonencode(json.filename, json.content);

end

function test_spm_2_bids_metadata_smoothed_data()

    file = fullfile('sub-01', 'func', 's6wusub-01_task-auditory_bold.nii');

    [~, ~, json] = spm_2_bids(file, [], false);

    assertEqual(fieldnames(json), {'filename'; 'content'});
    assertEqual(json.content.RawSources{1}, fullfile('sub-01', ...
                                                     'func', ...
                                                     'sub-01_task-auditory_bold.nii.gz'));
    assertEqual(json.content.Sources{end}, ...
                fullfile('sub-01', ...
                         'func', ...
                         'sub-01_task-auditory_space-IXI549Space_desc-preproc_bold.nii'));

    bids.util.jsonencode(json.filename, json.content);

end

function test_spm_2_bids_metadata_source_must_be_empty()

    file = fullfile('sub-01', 'anat', 'msub-01_T1w.nii');

    [~, ~, json] = spm_2_bids(file, [], false);

    assertEqual(fieldnames(json), {'filename'; 'content'});
    assertEqual(fieldnames(json.content), {'Description'; 'RawSources'; 'SpatialReference'});
    assertEqual(json.content.RawSources{1}, fullfile('sub-01', 'anat', 'sub-01_T1w.nii.gz'));

    bids.util.jsonencode(json.filename, json.content);

end
