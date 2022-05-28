% (C) Copyright 2022 spm_2_bids developers

function test_suite = test_identify_rawsources %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_identify_rawsources_skip_unknown_suffix()

    input_output = {'wsub-01_label-brain_mask.nii', ''};

    verbose = false;

    map = default_mapping();

    for i = 1:size(input_output, 1)

        rawsource = identify_rawsources(input_output{i, 1}, map, verbose);

        assertEqual(rawsource, {'TODO'});

    end

end

function test_identify_rawsources_surface()

    input_output = {'c1sub-01_T1w.surf.gii', 'sub-01_T1w.nii.gz'};

    verbose = false;

    map = default_mapping();

    for i = 1:size(input_output, 1)

        rawsource = identify_rawsources(input_output{i, 1}, map, verbose);

        assertEqual(rawsource, {['sub-01/' input_output{i, 2}]});

    end

end

function test_identify_rawsources_when_der_entities()

    input_output = {'sub-01_desc-skullstripped_T1w.nii', 'sub-01_T1w.nii.gz'};

    verbose = false;

    map = default_mapping();

    for i = 1:size(input_output, 1)

        rawsource = identify_rawsources(input_output{i, 1}, map, verbose);

        assertEqual(rawsource, {['sub-01/' input_output{i, 2}]});

    end

end

function test_identify_rawsources_suffix()

    input_output = {'sub-01_T1w_seg8.mat', 'sub-01_T1w.nii.gz'
                    'sub-01_task-foo_bold_uw.mat', 'sub-01_task-foo_bold.nii.gz'};

    verbose = false;

    map = default_mapping();

    for i = 1:size(input_output, 1)

        rawsource = identify_rawsources(input_output{i, 1},  map, verbose);

        assertEqual(rawsource, {['sub-01/' input_output{i, 2}]});

    end

end

function test_identify_rawsources_anat()

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

    map = default_mapping();

    for i = 1:numel(prefixes)

        file = [prefixes{i} anat_file];

        rawsource = identify_rawsources(fullfile(pwd, 'sub-01', file), map,  verbose);

        assertEqual(rawsource, {'sub-01/sub-01_T1w.nii.gz'});

    end

end

function test_identify_rawsources_func()

    func_file = 'sub-01_ses-02_task-foo_bold.nii';

    prefixes = {'a'
                'u'
                'rp_'
                'rp_a'
                'w'
                'wua'
                'wu'
                'wr'
                'wra'
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

    map = default_mapping();

    for i = 1:numel(prefixes)

        file = [prefixes{i} func_file];

        rawsource = identify_rawsources(file, map, verbose);

        assertEqual(rawsource, {'sub-01/ses-02/sub-01_ses-02_task-foo_bold.nii.gz'});

    end

end
