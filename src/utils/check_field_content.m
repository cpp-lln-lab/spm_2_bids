function status = check_field_content(struct_1, struct_2)
    %
    % (C) Copyright 2021 spm_2_bids developers

    status = true;

    if isempty(struct_2)
        return
    end

    if strcmp(struct_2, '*')
        return
    end

    shared_fields = intersect(fieldnames(struct_1), fieldnames(struct_2));

    if isempty(shared_fields)
        status = false;
        return
    end

    for i = 1:numel(shared_fields)
        if ~strcmp(struct_1.(shared_fields{i}), struct_2.(shared_fields{i}))
            status = false;
            return
        end
    end
end
