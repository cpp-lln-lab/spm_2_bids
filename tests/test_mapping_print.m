% (C) Copyright 2021 spm_2_bids developers

function test_suite = test_mapping_print %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_mapping_print_basic()

    map = Mapping();
    map = map.default();
    map.print_mapping();

    map.print_mapping(fullfile('mapping.md'));

end
