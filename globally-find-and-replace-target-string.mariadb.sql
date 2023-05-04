/*
 Never forget the stupid amount of time and pain that went into writing this:
 https://stackoverflow.com/questions/75818524/a-mariadb-stored-procedure-parameter-checking-for-a-table-is-being-interpreted-a/75819703

Also be careful replacing any strings containing single quotes, be sure to
 escape them to avoid unexpected mess.

In this script, the 'field format' is used to filter results, however you 
can modify to target any field.

Use `sql-field-list-generator.drupal.js` from this repo to generate the CALLs
 at the bottom of this script.


BACK UP YOUR DATABASE BEFORE RUNNING!

Paste the SQL script and the CALLs into a text file, and run on a db with:

`$ cat myfile.txt | drush sql-cli`

Then clear the cache with:

`$ drush cr`
*/

USE myDatabase;

DELIMITER $$

CREATE OR REPLACE PROCEDURE replaceLinks(
        tableName VARCHAR(255),
        fieldValue VARCHAR(255),
        fieldFormat VARCHAR(255),
        targetStr VARCHAR(255),
        replaceStr VARCHAR(255)
    ) 
    BEGIN
		DECLARE EXIT HANDLER FOR 1146 SELECT 1; -- Exit if the table (tableName) does not exist
		DECLARE EXIT HANDLER FOR 1054 SELECT 1; -- Exit if the column (fieldName) does not exist
   		EXECUTE IMMEDIATE CONCAT(
        	'UPDATE ',
	        tableName,
   		    ' SET ',
        	fieldValue,
        	' = REPLACE(',
        	fieldValue,
        	',\'',
        	targetStr,
        	'\', \'',
        	replaceStr,
        	'\') WHERE ',
        	fieldFormat,
        	' = \'html\''
    	);
    END
$$

DELIMITER ;

/* -- Example call
CALL replaceLinks(
        'tableName', 'fieldName', 'fieldFormat', 'target string', 'replacement string'
    );
*/