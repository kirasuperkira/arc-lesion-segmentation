function [img, mask, info] = load_data(data_dir, subject_id)
    t2_pattern = sprintf('%s*T2w*.nii', subject_id);
    mask_pattern = sprintf('%s*lesion_mask*.nii', subject_id);

    t2_files = dir(fullfile(data_dir, t2_pattern));
    mask_files = dir(fullfile(data_dir, mask_pattern));

    if isempty(t2_files) || isempty(mask_files)
        error('Files not found for %s', subject_id);
    end

    t2_path = fullfile(data_dir, t2_files(1).name);
    mask_path = fullfile(data_dir, mask_files(1).name);

    try
        [img, t2_info] = read_nifti_octave(t2_path);
        [mask_raw, mask_info] = read_nifti_octave(mask_path);

        mask = logical(mask_raw > 0);

        info.subject = subject_id;
        info.t2_file = t2_files(1).name;
        info.mask_file = mask_files(1).name;
        info.img_size = size(img);

        disp(sprintf('Successfully loaded: %s (Size: %s)', subject_id, mat2str(size(img))));

    catch ME
        error('Read error: %s', ME.message);
    end
end
