SELECT * FROM layoffs_staging2;

-- How many minimum & maximum no. of employees were laid off in a single day? --
SELECT MIN(total_laid_off), MAX(total_laid_off) FROM layoffs_staging2;

-- Top 5 Companies who laid off all their employees --
SELECT company, country, total_laid_off FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Top 3 Companies with highest raised funding who laid off all of their employees in a single day --
SELECT company, country, funds_raised_millions FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Top 5 Companies with highest no. of employees laid off in 3 years --
SELECT company, SUM(total_laid_off) AS total FROM layoffs_staging2
GROUP BY company
ORDER BY total DESC;

-- Which industry suffered most layoffs in 3 years --
SELECT industry, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;


-- Top 3 Countries with most no. of layoffs in 3 years --
SELECT country, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;


-- Which year has highest no. of layoffs --
SELECT YEAR(`date`), SUM(total_laid_off) FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Which company stage suffered most no. of layoffs worldwide --
SELECT stage, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Top 3 months having most no. of layoffs in 3 years --
SELECT substring(`date`,1,7) AS `Month`, SUM(total_laid_off) FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY substring(`date`,1,7)
ORDER BY 2 DESC;

-- In which year Google, Amazon, Meta & Microsoft laid off their highest no. of employees --
WITH company_year_layoffs AS
( 
SELECT company, year(`date`), SUM(total_laid_off) FROM layoffs_staging2
GROUP BY company, year(`date`)
ORDER BY SUM(total_laid_off) DESC
)
SELECT * FROM company_year_layoffs;


-- Top 3 companies with most layoffs in 2020, 2021, 2022 and 2023 --
WITH company_year_layoffs AS
( 
SELECT company, year(`date`) AS `year`, SUM(total_laid_off) AS total_layoff FROM layoffs_staging2
GROUP BY company, year(`date`)
ORDER BY SUM(total_laid_off) DESC
), company_layoffs_per_year AS
( 
SELECT *, DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_layoff DESC) AS `rank` FROM company_year_layoffs
WHERE `year` IS NOT NULL
)
SELECT * FROM company_layoffs_per_year
WHERE `rank` <= 3;







