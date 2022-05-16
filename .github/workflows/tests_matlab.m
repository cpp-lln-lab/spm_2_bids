%
% (C) Copyright 2022 spm_2_bids developers

root_dir = getenv('GITHUB_WORKSPACE');

addpath(fullfile(root_dir, 'MOcov', 'MOcov'));

cd(fullfile(root_dir, 'MOxUnit', 'MOxUnit'));
run moxunit_set_path();

cd(root_dir);
init_spm_2_bids();

cd(root_dir);
run run_tests();
