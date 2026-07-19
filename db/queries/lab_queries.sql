SELECT subject_code, dice_score, processed_at
FROM participants
WHERE dice_score > 0.3
ORDER BY dice_score DESC;

SELECT subject_code, dice_score
FROM participants
WHERE dice_score BETWEEN 0.2 AND 0.5
ORDER BY dice_score;

SELECT
    p.subject_code,
    p.dice_score,
    r.algorithm_version,
    r.status,
    r.finished_at
FROM participants p
JOIN processing_runs r ON r.id = p.run_id
ORDER BY p.subject_code;

SELECT
    r.algorithm_version,
    COUNT(p.id)                 AS participants_count,
    ROUND(AVG(p.dice_score), 4) AS avg_dice,
    MIN(p.dice_score)           AS min_dice,
    MAX(p.dice_score)           AS max_dice
FROM participants p
JOIN processing_runs r ON r.id = p.run_id
GROUP BY r.algorithm_version
ORDER BY avg_dice DESC;

SELECT
    r.algorithm_version,
    ROUND(AVG(p.dice_score), 4) AS avg_dice
FROM participants p
JOIN processing_runs r ON r.id = p.run_id
GROUP BY r.algorithm_version
HAVING AVG(p.dice_score) < 0.25;

SELECT
    subject_code,
    lesion_volume_gt,
    lesion_volume_auto,
    ROUND(
        100.0 * (lesion_volume_auto - lesion_volume_gt) / NULLIF(lesion_volume_gt, 0),
        1
    ) AS overestimation_pct
FROM participants
WHERE lesion_volume_gt > 0
ORDER BY overestimation_pct DESC
LIMIT 10;