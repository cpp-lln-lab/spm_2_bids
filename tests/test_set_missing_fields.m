% (C) Copyright 2020 spm_2_bids developers

function test_suite = test_set_missing_fields %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_set_missing_fields_write()

    %% set up
    structure = struct();

    fields_to_set.field = 1;

    structure = set_missing_fields(structure, fields_to_set);

    %% data to test against
    expected_structure.field = 1;

    %% test
    assertEqual(expected_structure, structure);

end

function test_set_missing_fields_no_overwrite()

    % set up
    structure.field.subfield_1 = 3;

    fields_to_set.field.subfield_1 = 1;
    fields_to_set.field.subfield_2 = 1;

    structure = set_missing_fields(structure, fields_to_set);

    % data to test against
    expected_structure.field.subfield_1 = 3;
    expected_structure.field.subfield_2 = 1;

    % test
    assert(isequal(expected_structure, structure));

end

function test_set_missing_fields_overwrite()

    overwrite = true();

    % set up
    structure.field.subfield_1 = 3;

    fields_to_set.field.subfield_1 = 1;
    fields_to_set.field.subfield_2 = 1;

    structure = set_missing_fields(structure, fields_to_set, overwrite);

    % data to test against
    expected_structure.field.subfield_1 = 1;
    expected_structure.field.subfield_2 = 1;

    % test
    assert(isequal(expected_structure, structure));

end

function test_set_missing_fields_cmplx_struct()

    % set up
    structure = struct();

    fields_to_set.field.subfield_1 = 1;
    fields_to_set.field.subfield_2(1).name = 'a';
    fields_to_set.field.subfield_2(1).value = 1;
    fields_to_set.field.subfield_2(2).name = 'b';
    fields_to_set.field.subfield_2(2).value = 2;

    structure = set_missing_fields(structure, fields_to_set);

    % data to test against
    expected_structure.field.subfield_1 = 1;
    expected_structure.field.subfield_2(1).name = 'a';
    expected_structure.field.subfield_2(1).value = 1;
    expected_structure.field.subfield_2(2).name = 'b';
    expected_structure.field.subfield_2(2).value = 2;

    % test
    assert(isequal(expected_structure, structure));

end
