% (C) Copyright 2019 spm_2_bids developers

thisDir = fullfile(fileparts(mfilename('fullpath')));

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

if ispc
    success = moxunit_runtests(testFolder, '-verbose', '-recursive');

else
    success = moxunit_runtests(testFolder, ...
                               '-verbose', '-recursive', '-with_coverage', ...
                               '-cover', folderToCover, ...
                               '-cover_xml_file', 'coverage.xml', ...
                               '-cover_html_dir', fullfile(pwd, 'coverage_html'));
end

fileID = fopen('test_report.log', 'w');
if success
    fprintf(fileID, '0');
else
    fprintf(fileID, '1');
end
fclose(fileID);
