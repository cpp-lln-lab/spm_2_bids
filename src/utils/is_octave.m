function retval = is_octave()
    %
    % Returns true if the environment is Octave.
    %
    % USAGE::
    %
    %   retval = is_octave()
    %
    % :returns: :retval: (boolean)
    %
    % (C) Copyright 2021 spm_2_bids developers

    persistent cacheval   % speeds up repeated calls

    if isempty (cacheval)
        cacheval = (exist ('OCTAVE_VERSION', 'builtin') > 0);
    end

    retval = cacheval;
end
