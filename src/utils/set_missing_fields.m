function structure = set_missing_fields(structure, fields_to_set, overwrite)
    %
    % Recursively loop through the fields of a target ``structure`` and sets the values
    % as defined in the structure ``fields_to_set`` if they don't exist.
    %
    % Content of the target structure can be overwritten by setting the
    % ``overwrite```to ``true``.
    %
    % USAGE::
    %
    %   structure = set_missing_fields(structure, fields_to_set, overwrite = false)
    %
    % :param structure:
    % :type structure:
    % :param fields_to_set:
    % :type fields_to_set: string
    % :param overwrite:
    % :type overwrite: boolean
    %
    % :returns: - :structure: (structure)
    %
    %

    % (C) Copyright 2021 spm_2_bids developers

    if isempty(fields_to_set)
        return
    end

    if nargin < 3 || isempty(overwrite)
        overwrite = false;
    end

    names = fieldnames(fields_to_set);

    for j = 1:numel(structure)

        for i = 1:numel(names)

            this_field = fields_to_set.(names{i});

            if isfield(structure(j), names{i}) && isstruct(structure(j).(names{i}))

                structure(j).(names{i}) = ...
                  set_missing_fields(structure(j).(names{i}), ...
                                     fields_to_set.(names{i}), ...
                                     overwrite);

            else

                if ~overwrite
                    structure = overwrite_field( ...
                                                structure, ...
                                                names{i}, ...
                                                this_field);
                else
                    structure.(names{i}) = this_field;

                end

            end

        end

    end

end

function structure = overwrite_field(structure, field_name, value)
    if ~isfield(structure, field_name)
        for i = 1:numel(structure)
            structure(i).(field_name) = value;
        end
    end
end
