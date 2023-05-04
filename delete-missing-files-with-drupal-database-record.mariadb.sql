USE myDatabase;

DELIMITER $$

-- /******************************/
-- Delete records of files that don't exist on the server from a Drupal database.
-- /******************************/


-- This script inspects the `uri` column, which contains the `public://` path to Drupal files. 
-- Links like '/sites/default/files/some.pdf' won't work.
-- Note it also checks the `file_usage` table to ensure the file is not in use before deleting the record.
-- If it finds any record, it will skip it. Files like these should be replaced in Drupal:
--  Media > myBrokenMedia > fileField > replaceFile (overwrite existing file=true).

-- ONLY TESTED ON DRUPAL 9.5.7 on MariaDB 10.4

-- USAGE: 

-- BACK UP YOUR DATABASE BEFORE RUNNING!

-- 1. Add a CALL statement per file at the bottom of this script
-- (You can use https://github.com/T-Fletcher/url-tester to find missing files quickly)
-- 2. Save this file with the CALL statements to a text file, e.g. `myfile.txt`
-- 2. Run the script on the database with `cat myfile.txt | drush sql-cli`
-- 3. Clear the Drupal cache with `drush cr`

CREATE OR REPLACE PROCEDURE deleteFileRecord(
        uri VARCHAR(255)
    ) 
    BEGIN
		DECLARE EXIT HANDLER FOR 1054 SELECT 1; -- Exit if the column (uri) does not exist
   		EXECUTE IMMEDIATE CONCAT(
			'DELETE FROM file_managed WHERE uri = \'',
			uri,
			'\' AND fid NOT IN (SELECT fid FROM file_usage);' -- Only remove the file if no usage is recorded
   		);
    END
$$

DELIMITER ;

-- Example call:
-- CALL deleteFileRecord('public://some-missing-file.pdf');

