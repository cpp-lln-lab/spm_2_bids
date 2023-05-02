% (C) Copyright 2019 spm_2_bids developers

thisDir = fullfile(fileparts(mfilename('fullpath')));

if isdir(fullfile(thisDir, 'lib', 'bids-matlab'))
    addpath(fullfile(thisDir, 'lib', 'bids-matlab'));
end
if isdir(fullfile(thisDir, 'lib', 'JSONio'))
    addpath(fullfile(thisDir, 'lib', 'JSONio'));
end

folderToCover = fullfile(thisDir, 'src');
testFolder = fullfile(thisDir, 'tests');

addpath(fullfile(testFolder, 'utils'));

if ispc
    success = moxunit_runtests(test_folder, '-verbose');

else
    success = moxunit_runtests(test_folder, ...
                               '-verbose', '-recursive', '-with_coverage', ...
                               '-cover', folder_to_cover, ...
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
