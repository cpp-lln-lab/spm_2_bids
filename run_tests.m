% (C) Copyright 2019 spm_2_bids developers

thisDir = fullfile(fileparts(mfilename('fullpath')));

if isdir(fullfile(thisDir, 'lib', 'bids-matlab'))
    addpath(fullfile(thisDir, 'lib', 'bids-matlab'));
    addpath(fullfile(thisDir, 'lib', 'JSONio'));
end

folderToCover = fullfile(thisDir, 'src');
testFolder = fullfile(thisDir, 'tests');

success = moxunit_runtests(testFolder, ...
                           '-verbose', '-recursive', '-with_coverage', ...
                           '-cover', folderToCover, ...
                           '-cover_xml_file', 'coverage.xml', ...
                           '-cover_html_dir', fullfile(pwd, 'coverage_html'));

if success
    system('echo 0 > test_report.log');
else
    system('echo 1 > test_report.log');
end
