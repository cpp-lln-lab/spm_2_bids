% (C) Copyright 2022 spm_2_bids developers

function test_suite = test_identify_sources %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_identify_sources_func()

    func_file = 'sub-01_task-auditory_bold.nii';

    prefix_output = {
                     'ua', 'sub-01_task-auditory_space-individual_desc-stc_bold.nii'
                     'rp_a', 'sub-01_task-auditory_space-individual_desc-stc_bold.nii'
                     'wua', 'sub-01_task-auditory_space-individual_desc-realignUnwarp_bold.nii'
                     'wu', 'sub-01_task-auditory_space-individual_desc-realignUnwarp_bold.nii'
                     'sw', 'sub-01_task-auditory_space-IXI549Space_desc-preproc_bold.nii'
                     'swua', 'sub-01_task-auditory_space-IXI549Space_desc-preproc_bold.nii'
                     'swu', 'sub-01_task-auditory_space-IXI549Space_desc-preproc_bold.nii'
                     'swr', 'sub-01_task-auditory_space-IXI549Space_desc-preproc_bold.nii'
                     'swra', 'sub-01_task-auditory_space-IXI549Space_desc-preproc_bold.nii'
                     'sua', 'sub-01_task-auditory_space-individual_desc-realignUnwarp_bold.nii'
                     'su', 'sub-01_task-auditory_space-individual_desc-realignUnwarp_bold.nii'
                    };

    map = default_mapping();

    for i  = 1:size(prefix_output, 1)

        sources = identify_sources([prefix_output{i, 1} func_file], map, false);

        assertEqual(sources{1}, fullfile('sub-01', prefix_output{i, 2}));

    end

end

function test_identify_sources_mean()

    func_file = 'sub-01_task-auditory_bold.nii';

    prefix_output = {
                     'wmeanua', 'sub-01_task-auditory_space-individual_desc-mean_bold.nii'
                     'wmeanu',  'sub-01_task-auditory_space-individual_desc-mean_bold.nii'
                     'wmeanau', 'sub-01_task-auditory_space-individual_desc-mean_bold.nii'
                    };

    map = default_mapping();

    for i  = 1:size(prefix_output, 1)

        sources = identify_sources([prefix_output{i, 1} func_file], map, false);

        assertEqual(sources{1}, fullfile('sub-01', prefix_output{i, 2}));

    end

end

function test_identify_sources_anat()

    anat_file = 'sub-01_T1w.nii';

    prefix_output = {'wm',  'sub-01/sub-01_space-individual_desc-biascor_T1w.nii'
                     'wc1', 'sub-01/sub-01_space-individual_label-GM_probseg.nii'
                     'wc2', 'sub-01/sub-01_space-individual_label-WM_probseg.nii'
                     'wc3', 'sub-01/sub-01_space-individual_label-CSF_probseg.nii'
                    };

    map = default_mapping();

    for i  = 1:size(prefix_output, 1)

        sources = identify_sources([prefix_output{i, 1} anat_file], map, false);

        assertEqual(sources{1}, prefix_output{i, 2});

    end

end

function test_identify_sources_suffix()

    input_output = {'msub-01_T1w_seg8.mat', ...
                    'sub-01_space-individual_desc-biascor_T1w.nii'
                    'asub-01_task-foo_bold_uw.mat', ...
                    'sub-01_task-foo_space-individual_desc-stc_bold.nii'};

    map = default_mapping();

    for i = 1:size(input_output, 1)

        sources = identify_sources(input_output{i, 1}, map, false);

        assertEqual(sources{1}, ['sub-01/' input_output{i, 2}]);

    end

end
