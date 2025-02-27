-- DB Migration for expanding server name field to support changes commited 2/27/2025

ALTER TABLE `servers` MODIFY COLUMN `name` VARCHAR(160);