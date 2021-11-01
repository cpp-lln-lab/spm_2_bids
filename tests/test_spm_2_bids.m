% (C) Copyright 2021 spm_2_bids developers

function test_suite = test_spm_2_bids %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_spm_2_bids_order_entities()

    file = 'wmsub-01_desc-skullstripped_T1w.nii';
    new_filename = spm_2_bids(file);
    assertEqual(new_filename, 'sub-01_space-IXI549Space_desc-preproc_T1w.nii');

end

function test_spm_2_bids_suffix()

    input_output = {
                    'sub-01_T1w_seg8.mat', ...
                    'sub-01_label-T1w_segparam.mat'
                    'sub-01_task-auditory_bold_uw.mat', ...
                    'sub-01_task-auditory_label-bold_unwarpparam.mat'};

    for i = 1:numel(size(input_output, 1))

        print_here('%s\n', input_output{i, 1});

        filename = spm_2_bids(input_output{i, 1});

        expected = input_output{i, 2};
        assertEqual(filename, expected);

    end

end

function test_spm_2_bids_new_mapping()

    map = Mapping();
    map = map.default();

    name_spec = map.cfg.preproc_norm;
    name_spec.entities.res = 'onemm';
    map = map.add_mapping('prefix', 'wm', ...
                          'suffix',  'T1w', ...
                          'ext', '.nii', ...
                          'entities', struct('desc', 'skullstripped'), ...
                          'name_spec', name_spec);

    name_spec = struct('suffix', 'T1w', ...
                       'ext', '.gii', ...
                       'entities', struct('desc', 'pialsurf'));
    map = map.add_mapping('prefix', 'c1', ...
                          'suffix',  'T1w', ...
                          'ext', '.surf.gii', ...
                          'entities', '*', ... % allows any entity, if empty only prefix is used
                          'name_spec', name_spec);

    map = map.flatten_mapping();

    input_output = {'c1sub-01_T1w.surf.gii', ... % new mapping for surface data
                    'sub-01_desc-pialsurf_T1w.gii'; ...
                    'wmsub-01_desc-skullstripped_T1w.nii', ... % new mapping for skulltripped data
                    'sub-01_space-IXI549Space_res-onemm_desc-preproc_T1w.nii'
                    'wmsub-01_desc-skullstripped_T2w.nii', ... % wrong suffix: use only prefix
                    'sub-01_space-IXI549Space_desc-preproc_T2w.nii'; ...
                    'wmsub-01_desc-preproc_T1w.nii', ... % wrong entity: use only prefix
                    'sub-01_space-IXI549Space_desc-preproc_T1w.nii'};
    for i = 1:size(input_output, 1)

        print_here('%s\n', input_output{i, 1});

        filename = spm_2_bids(input_output{i, 1}, map);

        expected = input_output{i, 2};
        assertEqual(filename, expected);

    end

end

function test_spm_2_bids_no_prefix()

    file = 'sub-01_ses-02_T1w.nii';
    new_filename = spm_2_bids(file);
    assertEqual(new_filename, file);

end

function test_spm_2_bids_unknown_prefix()

    file = 'wtfsub-01_ses-02_T1w.nii';
    assertWarning( ...
                  @()spm_2_bids(file), ...
                  'spm_2_bids:unknownPrefix');

end

function test_spm_2_bids_json()

    file = 'c1sub-01_ses-02_T1w.nii';
    [new_filename, pth, json] = spm_2_bids(file);

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

    map = Mapping();
    map = map.default();
    map.cfg.fwhm = 6;

    func_file = 'sub-01_task-auditory_bold.nii';

    prefix_and_output = {'su', 'sub-01_task-auditory_space-individual_desc-smth6_bold.nii'; ...
                         'swua', 'sub-01_task-auditory_space-IXI549Space_desc-smth6_bold.nii' ...
                        };

    for i = 1:size(prefix_and_output, 1)

        prefixes = get_prefixes(prefix_and_output, i);

        for j = 1:numel(prefixes)

            file = [prefixes{j} func_file];

            print_here('%s\n', file);

            filename = spm_2_bids(file, map);

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
                         'm',   'sub-01_space-individual_desc-biascor_T1w.nii'; ...
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
