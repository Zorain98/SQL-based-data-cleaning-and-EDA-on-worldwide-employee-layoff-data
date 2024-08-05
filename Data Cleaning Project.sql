SELECT * FROM layoffs;

-- Step 1. Remove Duplicates --
-- Step 2. Standardize the Data --
-- Step 3. Deal with Null/Blank Values --
-- Step 4. Remove unnecessary columns --

CREATE TABLE layoffs_staging LIKE layoffs;
SELECT * FROM layoffs_staging;
INSERT INTO layoffs_staging SELECT * FROM layoffs;

-- STEP 1 --

-- Adding Row numbers to the data --
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
							`date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- 1's are unique values and 2's upto so on are duplicates --
SELECT * FROM layoffs_staging2
WHERE row_num > 1; 

-- Deleting the duplicates --
DELETE FROM layoffs_staging2
WHERE row_num = 2 ;

SELECT * FROM layoffs_staging2;

-- STEP 2 --

-- Removing the empty spaces before names --
 SELECT company, TRIM(company) FROM layoffs_staging2; 
 UPDATE layoffs_staging2
 SET company = TRIM(company);
 
 SELECT DISTINCT industry FROM layoffs_staging2 ORDER BY 1;     -- to check same name of industry in different ways --
 SELECT * FROM layoffs_staging2 WHERE industry LIKE 'Crypto%';  -- displaying rows where industry is related to crypto --
 UPDATE layoffs_staging2 SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';
 
 SELECT DISTINCT location FROM layoffs_staging2 ORDER BY 1;     -- No issue here --
 
 SELECT DISTINCT country FROM layoffs_staging2 ORDER BY 1;      -- We have found problem in United States --
 UPDATE layoffs_staging2 SET country = 'United States' WHERE country LIKE 'United States%';
 
 SELECT `date` FROM layoffs_staging2;                   -- Date is in text format --
 UPDATE layoffs_staging2 SET `date` = str_to_date(`date`, '%m/%d/%Y');   -- Changed text format date into DATE format --
 ALTER TABLE layoffs_staging2 MODIFY COLUMN `date` DATE;
 
 
 -- STEP 3 --
 
 -- Filling Null Values --
SELECT * FROM layoffs_staging2 WHERE industry IS NULL OR industry = '';     -- Checking is the column has Null/Blank values or not --
UPDATE layoffs_staging2 SET industry = NULL WHERE industry = '';
SELECT * FROM layoffs_staging2 AS t1 JOIN layoffs_staging2 AS t2 ON t1.company = t2.company WHERE t1.industry IS NULL OR t2.industry IS NULL;
UPDATE layoffs_staging2 t1 JOIN layoffs_staging2 t2
	ON t1.company = t2.company SET t1.industry = t2.industry WHERE t1.industry IS NULL AND t2.industry IS NOT NULL; 
    


-- STEP 4 --

-- Removing useless columns and rows --
SELECT * FROM layoffs_staging2;
SELECT * FROM layoffs_staging2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL; 
DELETE FROM layoffs_staging2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL; 
ALTER TABLE layoffs_staging2 DROP COLUMN row_num;


