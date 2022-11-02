function [status, bf] = update_prefix(bf, map)
    % (C) Copyright 2021 spm_2_bids developers
    status = 2;

    if length(bf.prefix) < 2
        % TODO: files that have been realigned but not resliced have no
        % "prefix" so we may miss some transformation
        status = 0;
        return
    end

    % remove the prefix of the last step
    if startsWith(bf.prefix, map.smooth)

        % in case the prefix includes a number to denotate the FXHM used
        % for smoothing
        starts_with_fwhm = regexp(bf.prefix, '^s[0-9]*', 'match');
        if ~isempty(starts_with_fwhm)
            bf = shorten_prefix(bf, length(starts_with_fwhm{1}));
        else
            bf = shorten_prefix(bf, 1);
        end

    elseif startsWith(bf.prefix, map.unwarp)
        bf = shorten_prefix(bf, 1);

    elseif startsWith(bf.prefix, map.norm)
        bf = shorten_prefix(bf, 1);

    elseif startsWith(bf.prefix, ['rp_' map.stc])
        bf = shorten_prefix(bf, 3);

    elseif startsWith(bf.prefix, 'mean')
        % TODO mean may involve several files from the source (across runs
        % and sessions
        %     prefixes = {
        %                 'mean'
        %                 'meanu'
        %                 'meanua'
        %                };
        status = 1;
        return

    elseif ismember(bf.prefix(1:2), {'c1', 'c2', 'c3', 'c4', 'c5'})
        % bias corrected image
        status = 1;
        return

    else
        % no idea
        status = 1;
        return

    end

end

function bf = shorten_prefix(bf, len)
    bf.prefix = bf.prefix((len + 1):end);
end
