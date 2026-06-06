function batch_evaluate(data_dir)
    
    pkg load image;
    pkg load datatypes;
    addpath('src');

    all_files = dir(fullfile(data_dir, '*T2w*.nii'));
    file_names = {all_files.name};
    
    subject_ids = {};
    for i = 1:length(file_names)
        parts = strsplit(file_names{i}, '_');
        subject_ids{end+1} = parts{1};
    end
    subject_ids = unique(subject_ids);
    
    fprintf('Найдено участников: %d\n', length(subject_ids));
    
    results_subjects = cell(length(subject_ids), 1);
    results_dice = zeros(length(subject_ids), 1);
    results_vol_gt = zeros(length(subject_ids), 1);
    results_vol_auto = zeros(length(subject_ids), 1);
    
    for i = 1:length(subject_ids)
        sub_id = subject_ids{i};
        
        try
            [img, gt_mask, ~] = load_data(data_dir, sub_id);
            auto_mask = segment_lesion(img);
            
            intersection = sum(auto_mask(:) & gt_mask(:));
            dice = 2 * intersection / (sum(auto_mask(:)) + sum(gt_mask(:)) + eps);
            
            results_subjects{i} = sub_id;
            results_dice(i) = dice;
            results_vol_gt(i) = sum(gt_mask(:));
            results_vol_auto(i) = sum(auto_mask(:));
            
            mask_path = fullfile('data/masks', [sub_id '_auto_mask.mat']);
            save(mask_path, 'auto_mask');
            
            overlap_per_slice = squeeze(sum(gt_mask & auto_mask, [1 2]));
            [~, best_slice_idx] = max(overlap_per_slice);
            if best_slice_idx == 0
                best_slice_idx = round(size(img, 3) / 2);
            end
            
            t2_slice = img(:, :, best_slice_idx);
            gt_slice = gt_mask(:, :, best_slice_idx);
            auto_slice = auto_mask(:, :, best_slice_idx);
            
            t2_norm = mat2gray(t2_slice);
            rgb_img = cat(3, t2_norm, t2_norm, t2_norm);
            
            rgb_img(:,:,1) = rgb_img(:,:,1) + 0.5 * double(gt_slice);
            rgb_img(:,:,2) = rgb_img(:,:,2) + 0.5 * double(auto_slice);
            rgb_img = min(rgb_img, 1);
            
            img_path = fullfile('results/visuals', [sub_id '_overlay.png']);
            imwrite(rgb_img, img_path);
            
            fprintf('   Dice: %.4f | GT: %d | Auto: %d\n', ...
                dice, sum(gt_mask(:)), sum(auto_mask(:)));
            
        catch ME
            results_subjects{i} = sub_id;
            results_dice(i) = NaN;
        end
    end
    
    fprintf('\nСводная таблица\n');
    fprintf('%-12s %-10s %-12s %-12s\n', 'Subject', 'Dice', 'Vol_GT', 'Vol_Auto');
    fprintf('%s\n', repmat('-', 1, 50));
    for i = 1:length(subject_ids)
        if ~isnan(results_dice(i))
            fprintf('%-12s %-10.4f %-12d %-12d\n', ...
                results_subjects{i}, results_dice(i), ...
                results_vol_gt(i), results_vol_auto(i));
        else
            fprintf('%-12s %-10s %-12s %-12s\n', ...
                results_subjects{i}, 'ERROR', '-', '-');
        end
    end
    
    csv_path = fullfile('results', 'batch_results.csv');
    fid = fopen(csv_path, 'w');
    fprintf(fid, 'Subject,Dice,Vol_GT,Vol_Auto\n');
    for i = 1:length(subject_ids)
        if ~isnan(results_dice(i))
            fprintf(fid, '%s,%.4f,%d,%d\n', ...
                results_subjects{i}, results_dice(i), ...
                results_vol_gt(i), results_vol_auto(i));
        end
    end
    fclose(fid);

    valid_dice = results_dice(~isnan(results_dice));
    if ~isempty(valid_dice)
        fprintf('Всего обработано: %d\n', length(valid_dice));
        fprintf('Средний Dice: %.4f ± %.4f\n', mean(valid_dice), std(valid_dice));
        fprintf('Медиана Dice: %.4f\n', median(valid_dice));
        fprintf('Min/Max: %.4f / %.4f\n', min(valid_dice), max(valid_dice));
        fprintf('Dice > 0.3: %d (%.1f%%)\n', ...
            sum(valid_dice > 0.3), 100*sum(valid_dice > 0.3)/length(valid_dice));
        fprintf('Dice > 0.5: %d (%.1f%%)\n', ...
            sum(valid_dice > 0.5), 100*sum(valid_dice > 0.5)/length(valid_dice));
        fprintf('Dice < 0.1: %d (%.1f%%)\n', ...
            sum(valid_dice < 0.1), 100*sum(valid_dice < 0.1)/length(valid_dice));
    end
end