function auto_mask = segment_lesion(img)
    brain_mask = img > 0;
    brain_pixels = img(brain_mask);
    threshold = prctile(brain_pixels, 95);
    auto_mask = img > threshold;
    auto_mask = bwconncomp_filter(auto_mask, 100);
    auto_mask = imfill(auto_mask, 'holes');
    disp(sprintf('Lesion voxels found: %d', sum(auto_mask(:))));
end

function filtered_mask = bwconncomp_filter(mask, min_size)
    [L, num] = bwlabeln(mask);
    filtered_mask = false(size(mask));

    for i = 1:num
        component = (L == i);
        if sum(component(:)) >= min_size
            filtered_mask = filtered_mask | component;
        end
    end
end
