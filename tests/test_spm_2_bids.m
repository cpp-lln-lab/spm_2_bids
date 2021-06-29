% (C) Copyright 2021 spm_2_bids developers

function test_suite = test_spm_2_bids %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_spm_2_bids_basic()

    input_dir = fullfile(fileparts(mfilename('fullpath')), ...
                         'data', 'MoAE', 'derivatives', 'cpp_spm-preproc');
    use_schema = false;
    tolerant = true;
    verbose = false;
    index_derivatives = false;
    BIDS = bids.layout(input_dir, use_schema, index_derivatives, tolerant, verbose);

    prefixes =  bids.query(BIDS, 'prefixes')';

end

function test_spm_2_bids_segmentation()

    anat_file = 'sub-01_T1w.nii';

    prefix_and_output = { ...
                         'c1',  'sub-01_space-individual_label-GM_probseg.nii'; ...
                         'c2',  'sub-01_space-individual_label-WM_probseg.nii'; ...
                         'c3',  'sub-01_space-individual_label-CSF_probseg.nii'; ...
                         'iy_', 'sub-01_from-IXI549Space_to-T1w_mode-image_xfm.nii'; ...
                         'y_',  'sub-01_from-T1w_to-IXI549Space_mode-image_xfm.nii'; ...
                         'm',   'sub-01_desc-biascor_T1w.nii'};

    for iTest = 1:size(prefix_and_output, 1)
        prefix = prefix_and_output{iTest, 1};
        filename = spm_2_bids([prefix anat_file]);

        expected = prefix_and_output{iTest, 2};
        assertEqual(filename, expected);
    end

end

function test_spm_2_bids_preproc_anat()

    test_cfg = set_test_cfg();
    if test_cfg.verbosity
        fprintf(1, '\n');
    end

    anat_file = 'sub-01_T1w.nii';

    prefix_and_output = { ...
                         {'wm', 'w'},  'sub-01_space-IXI549Space_desc-preproc_T1w.nii'; ...
                         'wc1',  'sub-01_space-IXI549Space_label-GM_probseg.nii'; ...
                         'wc2',  'sub-01_space-IXI549Space_label-WM_probseg.nii'; ...
                         'wc3',  'sub-01_space-IXI549Space_label-CSF_probseg.nii' ...
                        };

    for i = 1:size(prefix_and_output, 1)

        prefixes = get_prefixes(prefix_and_output, i);

        for j = 1:numel(prefixes)

            file = [prefixes{j} anat_file];

            if test_cfg.verbosity
                fprintf(1, '%s\n', file);
            end

            filename = spm_2_bids(file);

            expected = prefix_and_output{i, 2};
            assertEqual(filename, expected);

        end
    end

end

function test_spm_2_bids_preproc_func()

    test_cfg = set_test_cfg();
    if test_cfg.verbosity
        fprintf(1, '\n');
    end

    func_file = 'sub-01_task-auditory_bold.nii';

    prefix_and_output = { ...
                         'a', ...
                         'sub-01_task-auditory_space-individual_desc-stc_bold.nii'; ...
                         'u',  ...
                         'sub-01_task-auditory_space-individual_desc-realignUnwarp_bold.nii'; ...
                         {'mean', 'meanu'}, ...
                         'sub-01_task-auditory_space-individual_desc-mean_bold.nii'; ...
                         {'w', 'wua', 'wu', 'wr', 'wra'}, ...
                         'sub-01_task-auditory_space-IXI549Space_desc-preproc_bold.nii'; ...
                         {'wmeanu'}, ...
                         'sub-01_task-auditory_space-IXI549Space_desc-mean_bold.nii'; ...
                         {'sw', 'swua', 'swu', 'swr', 'swra'}, ...
                         'sub-01_task-auditory_space-IXI549Space_desc-smth_bold.nii'; ...
                         {'s', 'sua', 'su', 'sr', 'sra'}, ...
                         'sub-01_task-auditory_space-individual_desc-smth_bold.nii' ...
                        };

    for i = 1:size(prefix_and_output, 1)

        prefixes = get_prefixes(prefix_and_output, i);

        for j = 1:numel(prefixes)

            file = [prefixes{j} func_file];

            if test_cfg.verbosity
                fprintf(1, '%s\n', file);
            end

            filename = spm_2_bids(file);

            expected = prefix_and_output{i, 2};
            assertEqual(filename, expected);

        end
    end

end

% 's6wu'

% 'rc1wmeanu'
% 'rc2wmeanu'
% 'rc3wmeanu'

% 'rc1'
% 'rc2'
% 'rc3'

% 'rp_'

% 'ru'

function prefixes = get_prefixes(prefix_and_output, row)
    prefixes = prefix_and_output{row, 1};
    if ~iscell(prefixes)
        prefixes = {prefixes};
    end
end
