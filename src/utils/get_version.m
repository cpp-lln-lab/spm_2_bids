function version_number = get_version()
    %
    % Reads the version number of the pipeline from the txt file in the root of the
    % repository.
    %
    % USAGE::
    %
    %   version_number = get_version()
    %
    % :returns: :version_number: (string) Use semantic versioning format (like v0.1.0)
    %
    % (C) Copyright 2020 spm_2_bids developers

    try
        version_number = fileread(fullfile(fileparts(mfilename('fullpath')), ...
                                           '..', '..', 'version.txt'));
    catch
        version_number = 'v0.1.0';
    end
end
