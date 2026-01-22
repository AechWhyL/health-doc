-- Fix Daily Health Measurement Foreign Key
-- 1. Drop the incorrect foreign key FIRST
ALTER TABLE `daily_health_measurement`
DROP FOREIGN KEY `fk_daily_health_measurement_elder`;

-- 2. Update data values: map elder_basic_info.id to users.id
UPDATE `daily_health_measurement` dhm
JOIN `elder_basic_info` ebi ON dhm.elder_id = ebi.id
SET
    dhm.elder_id = ebi.user_id
WHERE
    ebi.user_id IS NOT NULL;

-- 3. Modify the column to match users.id definition (int unsigned)
ALTER TABLE `daily_health_measurement`
MODIFY COLUMN `elder_id` INT UNSIGNED NOT NULL COMMENT '用户ID';

-- 4. Delete orphan records that do not link to a valid user (to ensure FK constraint succeeds)
DELETE FROM `daily_health_measurement`
WHERE
    `elder_id` NOT IN(
        SELECT `id`
        FROM `users`
    );

-- 5. Add the correct foreign key constraint
ALTER TABLE `daily_health_measurement`
ADD CONSTRAINT `fk_daily_health_measurement_user` FOREIGN KEY (`elder_id`) REFERENCES `users` (`id`);