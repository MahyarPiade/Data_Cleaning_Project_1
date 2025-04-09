select * 
from layoffs;


# Creating a copy of the raw data to work with:
create table layoffs_staging
like layoffs;

insert layoffs_staging
select * 
from layoffs;

select *
from layoffs_staging;

# Removing duplicates:


with duplicate_cte as
(
select *,
row_number() over(partition by company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;





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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


insert into layoffs_staging2
select *,
row_number() over(partition by company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

delete
from layoffs_staging2
where row_num > 1;



# Standardizing data:


-- removing extra spaces:

select  company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);


select distinct industry
from layoffs_staging2
order by 1;

-- unique the names that have similar content:
select *
from layoffs_staging2
where industry like "Crypto%";


update layoffs_staging2
set industry = "Crypto"
where industry like "Crypto%";

update layoffs_staging2
set country = trim(trailing "." from country)
where country like "United States%";

-- changing the format of the date:


select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;


update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table layoffs_staging2
modify column `date` date; 

select * 
from layoffs_staging2;



# Null values & Blank values:



update layoffs_staging2
set industry = null
where industry = "";

-- checking what to actually do:
select t1.industry, t2.industry
from layoffs_staging2 as t1
join layoffs_staging2 as t2
	on t1.company = t2.company
where (t1.industry is null or t1.industry = "")
and t2.industry is not null;

-- applying the changes:
update layoffs_staging2 as t1
join layoffs_staging2 as t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;


# Remove any unneccessry row or column:


delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

alter table layoffs_staging2
drop column row_num;


-- final product:
select * 
from layoffs_staging2;


