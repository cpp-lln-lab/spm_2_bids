% (C) Copyright 2019 spm_2_bids developers

thisDir = fileparts(mfilename('fullpath'));

folderToCover = fullfile(thisDir, 'src');
addpath(genpath(folderToCover));

if isdir(fullfile(thisDir, 'lib', 'bids-matlab'))
    addpath(fullfile(thisDir, 'lib', 'bids-matlab'));
end
if isdir(fullfile(thisDir, 'lib', 'JSONio'))
    addpath(fullfile(thisDir, 'lib', 'JSONio'));
end

testFolder = fullfile(thisDir, 'tests');

addpath(fullfile(testFolder, 'utils'));

success = moxunit_runtests(testFolder, ...
                           '-verbose', '-recursive', '-with_coverage', '-randomize_order', ...
                           '-cover', folderToCover, ...
                           '-cover_xml_file', 'coverage.xml', ...
                           '-cover_html_dir', fullfile(pwd, 'coverage_html'));

exit(double(~success));
