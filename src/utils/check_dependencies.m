function check_dependencies()
    %
    % Checks that that the right dependencies are installeda and
    % loads the spm defaults.
    %
    % USAGE::
    %
    %   check_dependencies()
    %
    %
    % (C) Copyright 2019 spm_2_bids developers

    fprintf('Checking dependencies\n');

    SPM_main = 'SPM12';
    SPM_sub = '7487';

    %% check spm version
    try
        [a, b] = spm('ver');
        fprintf(' Using %s %s\n', a, b);
        if any(~[strcmp(a, SPM_main) strcmp(b, SPM_sub)])
            str = sprintf('%s %s %s.\n%s', ...
                          'The current version SPM version is not', SPM_main, SPM_sub, ...
                          'In case of problems (e.g json file related) consider updating.');
            warning(str); %#ok<*SPWRN>
        end
    catch
        error('Failed to check the SPM version: Are you sure that SPM is in the matlab path?');
    end

    spm('defaults', 'fmri');

    fprintf(' We got all we need. Let''s get to work.\n');

end
