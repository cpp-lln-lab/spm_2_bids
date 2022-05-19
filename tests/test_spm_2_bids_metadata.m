% (C) Copyright 2021 spm_2_bids developers

function test_suite = test_spm_2_bids_metadata %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_spm_2_bids_metadata_anat()

    file = 'wmsub-01_T1w.nii';

    [~, ~, json] = spm_2_bids(file, [], false);

    assertEqual(fieldnames(json), {'filename'; 'content'});
    assertEqual(json.content.RawSources{1}, 'sub-01/sub-01_T1w.nii');
    assertEqual(json.content.Sources{1}, ...
                'sub-01/sub-01_space-individual_desc-biascor_T1w.nii');
    assertEqual(json.content.Sources{2}, ...
                'sub-01/sub-01_from-T1w_to-IXI549Space_mode-image_xfm.nii');

    bids.util.jsonencode(json.filename, json.content);

end

function test_spm_2_bids_metadata_func()

    file = 'wuasub-01_task-foo_bold.nii';

    [~, ~, json] = spm_2_bids(file, [], false);

    assertEqual(fieldnames(json), {'filename'; 'content'});
    assertEqual(json.content.RawSources{1}, 'sub-01/sub-01_task-foo_bold.nii');
    assertEqual(json.content.Sources{1}, ...
                'sub-01/sub-01_task-foo_space-individual_desc-realignUnwarp_bold.nii');
    assertEqual(json.content.Sources{2}, 'TODO: add deformation field');

    bids.util.jsonencode(json.filename, json.content);

end
