function simple_stats(csv_path)
    fid = fopen(csv_path, 'r');
    fgetl(fid);
    dice_vals = [];
    vol_gt = [];
    
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line)
            parts = strsplit(line, ',');
            if length(parts) >= 4
                dice_vals(end+1) = str2double(parts{2});
                vol_gt(end+1) = str2double(parts{3});
            end
        end
    end
    fclose(fid);
    
    fprintf('Summary statistics (N=%d)\n', length(dice_vals));
    fprintf('Mean Dice: %.4f ± %.4f\n', mean(dice_vals), std(dice_vals));
    fprintf('Median Dice: %.4f\n', median(dice_vals));
    fprintf('Min/Max Dice: %.4f / %.4f\n', min(dice_vals), max(dice_vals));
    fprintf('Dice > 0.3: %d (%.1f%%)\n', ...
        sum(dice_vals > 0.3), 100*sum(dice_vals > 0.3)/length(dice_vals));
    fprintf('Dice > 0.5: %d (%.1f%%)\n', ...
        sum(dice_vals > 0.5), 100*sum(dice_vals > 0.5)/length(dice_vals));
    fprintf('Dice < 0.1: %d (%.1f%%)\n', ...
        sum(dice_vals < 0.1), 100*sum(dice_vals < 0.1)/length(dice_vals));

    figure('Position', [100, 100, 800, 400], 'Color', 'w');
    [n, bins] = hist(dice_vals, 20);
    bar(bins, n, 'FaceColor', [0.2, 0.6, 0.8]);
    xlabel('Dice Score');
    ylabel('Number of participants');
    title(sprintf('Dice Score distribution (N=%d, Mean=%.3f)', length(dice_vals), mean(dice_vals)));
    xlim([0, 1]);
    grid on;
    saveas(gcf, 'results/dice_distribution.png');
    fprintf('\nChart saved: results/dice_distribution.png\n');
end
