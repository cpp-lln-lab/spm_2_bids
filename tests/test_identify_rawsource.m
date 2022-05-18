% (C) Copyright 2021 spm_2_bids developers

function test_suite = test_identify_rawsource %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_identify_rawsource_suffix()

    input_output = {'sub-01_T1w_seg8.mat', 'sub-01_T1w.nii'
                    'sub-01_task-foo_bold_uw.mat', 'sub-01_task-foo_bold.nii'};

    verbose = false;

    for i = 1:size(input_output, 1)

        rawsource = identify_rawsource(input_output{i, 1}, verbose);

        assertEqual(rawsource, ['sub-01/' input_output{i, 2}]);

    end

end

function test_identify_rawsource_anat()

    anat_file = 'sub-01_T1w.nii';

    prefixes = {'c1'
                'c2'
                'c3'
                'iy_'
                'y_'
                'm'
                'wm'
                'w'
                'wc1'
                'wc2'
                'wc3'
               };

    verbose = false;

    for i = 1:numel(prefixes)

        file = [prefixes{i} anat_file];

        rawsource = identify_rawsource(file, verbose);

        assertEqual(rawsource, 'sub-01/sub-01_T1w.nii');

    end

end

function test_identify_rawsource_func()

    func_file = 'sub-01_ses-02_task-foo_bold.nii';

    prefixes = {'a'
                'u'
                'rp_'
                'rp_a'
                'mean'
                'meanu'
                'meanua'
                'w'
                'wua'
                'wu'
                'wr'
                'wra'
                'wmeanu'
                'sw'
                'swua'
                'swu'
                'swr'
                'swra'
                's'
                'sua'
                'su'
                'sr'
                'sra'
               };

    verbose = false;

    for i = 1:numel(prefixes)

        file = [prefixes{i} func_file];

        rawsource = identify_rawsource(file, verbose);

        assertEqual(rawsource, 'sub-01/ses-02/sub-01_ses-02_task-foo_bold.nii');

    end

end
