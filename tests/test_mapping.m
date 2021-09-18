% (C) Copyright 2021 spm_2_bids developers

function test_suite = test_mapping %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_constructor()

    map = Mapping();
    cfg = check_cfg();

    assertEqual(map.cfg, cfg);

end

function test_add_mapping()

    map = Mapping();
    map = map.add_mapping('prefix', 'm');

    assertEqual(map.mapping(end).prefix, {'m'});
    assertEqual(map.mapping(end).suffix, '');
    assertEqual(map.mapping(end).entities, '');
    assertEqual(map.mapping(end).ext, '');
    assertEqual(map.mapping(end).name_spec, '');

    map = Mapping();
    map = map.add_mapping('prefix', {'m', 'a'});

end

function test_find_mapping()

    map = Mapping();
    map = map.default();
    idx = map.find_mapping('prefix', 'rp_');

    assertEqual(find(idx), 12);

end

function test_flatten_mapping()

    map = Mapping();
    map = map.add_mapping('prefix', {'m', 'a'});
    map = map.flatten_mapping();

    assertEqual(map.mapping(1).prefix, 'm');
    assertEqual(map.mapping(2).prefix, 'a');

end

function test_default()

    map = Mapping();
    map = map.default();

    assertEqual(map.mapping(1).prefix, 'm');

end
