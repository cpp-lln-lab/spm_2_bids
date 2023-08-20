function modality = guess_modality(bf)

    % (C) Copyright 2023 spm_2_bids developers
    switch bf.suffix
        case {'bold'}
            modality = 'func';
        case {'T1w'}
            modality = 'anat';
        case {'mask'}
            if ismember('task', fieldnames(bf.entities))
                modality = 'func';
            else
                modality = 'anat';
            end
    end
end
