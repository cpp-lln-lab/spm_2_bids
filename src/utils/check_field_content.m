function status = check_field_content(struct_one, struct_two)
    %

    % (C) Copyright 2021 spm_2_bids developers

    status = true;

    if isempty(struct_two)
        return
    end

    if strcmp(struct_two, '*')
        return
    end

    shared_fields = intersect(fieldnames(struct_one), fieldnames(struct_two));

    if isempty(shared_fields)
        status = false;
        return
    end

    for i = 1:numel(shared_fields)
        if ~strcmp(struct_one.(shared_fields{i}), struct_two.(shared_fields{i}))
            status = false;
            return
        end
    end
end
