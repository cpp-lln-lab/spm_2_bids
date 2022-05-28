function init_spm_2_bids(add_dev)
    %
    % 1 - Check if version requirements
    % are satisfied and the packages are
    % are installed/loaded:
    %   Octave > 4
    %       - image
    %       - optim
    %       - struct
    %       - statistics
    %
    %   MATLAB >= R2015b
    %
    % 2 - Add project to the O/M path
    %
    % (C) Copyright 2021 spm_2_bids developers

    if nargin < 1
        add_dev = false;
    end

    OCTAVE_VER = '4.0.3';
    MATLAB_VER = '8.6.0';

    INSTALL_LIST = {};

    if is_octave

        more off;

        % Exit if min version is not satisfied
        if ~compare_versions(OCTAVE_VERSION, OCTAVE_VER, '>=')
            error('Minimum required Octave version: %s', OCTAVE_VER);
        end

        for ii = 1:length(INSTALL_LIST)

            package_name = INSTALL_LIST{ii};

            try
                % Try loading Octave packages
                disp(['loading ' package_name]);
                pkg('load', package_name);

            catch

                try_install_from_forge(package_name);

            end
        end

    else

        if verLessThan('matlab', MATLAB_VER)
            error('Sorry, minimum required version is R2017b. :(');
        end

    end

    add_dependencies(add_dev);

    pth = fileparts(mfilename('fullpath'));
    addpath(genpath(fullfile(pth, 'src')));

    disp('Correct matlab/octave verions and added to the path!');

end

function retval = is_octave

    % speeds up repeated calls
    persistent cacheval

    if isempty (cacheval)
        cacheval = (exist ('OCTAVE_VERSION', 'builtin') > 0);
    end

    retval = cacheval;

end

function try_install_from_forge(package_name)

    errorcount = 1;
    while errorcount % Attempt twice in case installation fails
        try
            pkg('install', '-forge', package_name);
            pkg('load', package_name);
            errorcount = 0;
        catch err
            errorcount = errorcount + 1;
            if errorcount > 2
                error(err.message);
            end
        end
    end

end

function add_dependencies(add_dev)

    if add_dev
        pth = fileparts(mfilename('fullpath'));
        addpath(fullfile(pth, 'lib', 'bids-matlab'));
        addpath(fullfile(pth, 'lib', 'JSONio'));
    end

end
