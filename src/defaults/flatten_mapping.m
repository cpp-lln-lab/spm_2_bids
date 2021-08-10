function mapping = flatten_mapping(mapping)
    %
    % ensures that there is only one prefix, suffix, entity for each mapping
    %
    % (C) Copyright 2021 spm_2_bids developers

    % TODO add a check to make sure each prefix is only present once

    tmp = struct([]);

    for i = 1:size(mapping, 1)

        if ~iscell(mapping(i).prefix)
            mapping(i).prefix = {mapping(i).prefix};
        end

        for j = 1:numel(mapping(i).prefix)
            tmp(end + 1, 1).prefix = mapping(i).prefix{j};
            tmp(end).suffix = mapping(i).suffix;
            tmp(end).entities = mapping(i).entities;
            tmp(end).name_spec = mapping(i).name_spec;
        end

    end

    mapping =  tmp;

end
