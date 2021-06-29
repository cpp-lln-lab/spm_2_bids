function versionNumber = get_version()
    %
    % Reads the version number of the pipeline from the txt file in the root of the
    % repository.
    %
    % USAGE::
    %
    %   versionNumber = get_version()
    %
    % :returns: :versionNumber: (string) Use semantic versioning format (like v0.1.0)
    %
    % (C) Copyright 2020 spm_2_bids developers

    try
        versionNumber = fileread(fullfile(fileparts(mfilename('fullpath')), ...
                                          '..', '..', 'version.txt'));
    catch
        versionNumber = 'v0.1.0';
    end
end
