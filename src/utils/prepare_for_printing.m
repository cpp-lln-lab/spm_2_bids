function bf = prepare_for_printing(spec)
    %
    % (C) Copyright 2022 spm_2_bids developers

    if isfield(spec, 'entities')
        if strcmp(spec.entities, '*')
            spec.entities = struct('add', 'joker');
        elseif strcmp(spec.entities, '')
            spec.entities = struct();
        end
    end
    bf = bids.File(spec, 'tolerant', true);

    if isfield(spec, 'suffix') && isempty(spec.suffix) || ...
        ~isfield(spec, 'suffix')
        spec.suffix = '*';
    end

    if isfield(spec, 'ext') && ~isempty(spec.ext)
        spec.extension = '.*';
    end
    if ~isfield(spec, 'extension') || isempty(spec.extension)
        spec.ext = '.*';
    end

end
