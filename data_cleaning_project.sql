-- Data Cleaning 
-- Remove Duplicates

RENAME TABLE csvjson TO layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * 
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

WITH duplicate_CTE AS 
(
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_CTE
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging
WHERE company = 'Casper';

WITH duplicate_CTE AS 
(
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
) 
DELETE
FROM duplicate_CTE
WHERE row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging2;

-- Standardize the Data

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT * 
FROM layoffs_staging2
WHERE industry LIKE '%crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT * 
FROM layoffs_staging2
WHERE COUNTRY LIKE '%United States%';

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

SELECT 
    STR_TO_DATE(
        CASE 
            WHEN DATE = 'none' THEN NULL 
            ELSE DATE
        END, 
       '%m/%d/%Y' -- Change this format to match your date format
    ) AS converted_date
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = NULL 
WHERE `date` = 'none';

SELECT `date`, 
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2 MODIFY COLUMN `date` VARCHAR(10);

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` IS NOT NULL AND `date` != '' AND `date` != 'none' AND `date` <> 'NULL';

UPDATE layoffs_staging2
SET `date` = '1970-01-01'
WHERE `date` IS NULL;

SELECT `date`
FROM layoffs_staging2
LIMIT 10;

UPDATE layoffs_staging2
SET `date` = NULL
WHERE `date` = '1970-01-01';

SELECT * 
FROM layoffs_staging2;

-- Nulls/Blank/None

SELECT *
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET total_laid_off = NULL
WHERE total_laid_off = 'None';

UPDATE layoffs_staging2
SET percentage_laid_off = NULL
WHERE percentage_laid_off = 'None';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = 'None';

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2 
	ON t1.company = t2.comPany
	AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 
	ON t1.company = t2.comPany
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL; 

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%'; 

SELECT *
FROM layoffs_staging2;

-- Removing Rows / Columns

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;