% (C) Copyright 2021 spm_2_bids developers

function test_suite = test_spm_2_bids %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_spm_2_bids_cfg()

    % define the renaming specification to use for this file
    cfg.spm_2_bids.spec.entities.res = 'T1w';
    cfg.spm_2_bids.spec.entities.desc = 'something';
    cfg.spm_2_bids.spec.entities.space = '';

    print_here('\n', '');

    prefix_input_output = {'wu', ...
                           'sub-01_task-aud_bold.nii', ...
                           'sub-01_task-aud_res-T1w_desc-something_bold.nii' ...
                          };

    prefix = prefix_input_output{1, 1};
    file = [prefix prefix_input_output{1, 2}];

    print_here('%s\n', file);

    filename = spm_2_bids(file, cfg);

    expected = prefix_input_output{1, 3};
    assertEqual(filename, expected);


end

function test_spm_2_bids_defor_field()

    print_here('\n', '');

    prefix_input_output = {'y_', ...
                           'sub-01_T1w.nii', ...
                           'sub-01_from-T1w_to-IXI549Space_mode-image_xfm.nii'; ...
                           'y_', ...
                           'sub-01_T2w.nii', ...
                           'sub-01_from-T2w_to-IXI549Space_mode-image_xfm.nii'; ...
                           'iy_', ...
                           'sub-01_T1w.nii', ...
                           'sub-01_from-IXI549Space_to-T1w_mode-image_xfm.nii'; ...
                           'iy_', ...
                           'sub-01_T2w.nii', ...
                           'sub-01_from-IXI549Space_to-T2w_mode-image_xfm.nii' ...
                          };

    for i = 1:size(prefix_input_output, 1)

        prefixes = get_prefixes(prefix_input_output, i);

        for j = 1:numel(prefixes)

            file = [prefixes{j} prefix_input_output{i, 2}];

            print_here('%s\n', file);

            filename = spm_2_bids(file);

            expected = prefix_input_output{i, 3};
            assertEqual(filename, expected);

        end
    end

end

function test_spm_2_bids_smooth_fwhm()

    print_here('\n', '');

    cfg.spm_2_bids.fwhm = 6;

    func_file = 'sub-01_task-auditory_bold.nii';

    prefix_and_output = {'su', 'sub-01_task-auditory_space-individual_desc-smth6_bold.nii'};

    for i = 1:size(prefix_and_output, 1)

        prefixes = get_prefixes(prefix_and_output, i);

        for j = 1:numel(prefixes)

            file = [prefixes{j} func_file];

            print_here('%s\n', file);

            filename = spm_2_bids(file, cfg);

            expected = prefix_and_output{i, 2};
            assertEqual(filename, expected);

        end
    end

end

function test_spm_2_bids_anat()

    print_here('\n', '');

    anat_file = 'sub-01_T1w.nii';

    prefix_and_output = { ...
                         'c1',  'sub-01_space-individual_label-GM_probseg.nii'; ...
                         'c2',  'sub-01_space-individual_label-WM_probseg.nii'; ...
                         'c3',  'sub-01_space-individual_label-CSF_probseg.nii'; ...
                         'iy_', 'sub-01_from-IXI549Space_to-T1w_mode-image_xfm.nii'; ...
                         'y_',  'sub-01_from-T1w_to-IXI549Space_mode-image_xfm.nii'; ...
                         'm',   'sub-01_desc-biascor_T1w.nii'; ...
                         {'wm', 'w'},  'sub-01_space-IXI549Space_desc-preproc_T1w.nii'; ...
                         'wc1',  'sub-01_space-IXI549Space_label-GM_probseg.nii'; ...
                         'wc2',  'sub-01_space-IXI549Space_label-WM_probseg.nii'; ...
                         'wc3',  'sub-01_space-IXI549Space_label-CSF_probseg.nii' ...
                        };

    for i = 1:size(prefix_and_output, 1)

        prefixes = get_prefixes(prefix_and_output, i);

        for j = 1:numel(prefixes)

            file = [prefixes{j} anat_file];

            print_here('%s\n', file);

            filename = spm_2_bids(file);

            expected = prefix_and_output{i, 2};
            assertEqual(filename, expected);

        end
    end

end

function test_spm_2_bids_func()

    print_here('\n', '');

    func_file = 'sub-01_task-auditory_bold.nii';

    prefix_and_output = { ...
                         {'a'}, ...
                         'sub-01_task-auditory_space-individual_desc-stc_bold.nii'; ...
                         {'u'},  ...
                         'sub-01_task-auditory_space-individual_desc-realignUnwarp_bold.nii'; ...
                         {'rp_', 'rp_a'}, ...
                         'sub-01_task-auditory_desc-confounds_regressors.tsv'; ...
                         {'mean', 'meanu', 'meanua'}, ...
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

            print_here('%s\n', file);

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

% 'ru'

function prefixes = get_prefixes(prefix_and_output, row)
    prefixes = prefix_and_output{row, 1};
    if ~iscell(prefixes)
        prefixes = {prefixes};
    end
end

function print_here(string, file)
    test_cfg = get_test_cfg();
    if test_cfg.verbosity
        fprintf(1, string, file);
    end
end
