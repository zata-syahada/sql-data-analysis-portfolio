####################### DATA CLEANING ##########################
## 1. remove dupli
## 2. standarize data 
## 3. null value or blank values
## 4. remove any kolom 
## BUAT TABEL KEDUA BUAT BISA DI EDIT EDIT TANPA MERUSAK RAW DATA 

create table layoff_staging
like layoffs;
select * from layoff_staging;
insert layoff_staging
select * 
from layoffs;

######################## MENGECEK DATA DUPLI PAKAI BANTUAN CTE ################
with cte_dupe as
(
select *,
row_number() over(
partition by company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoff_staging
)
select * 
from cte_dupe
where row_num > 1;

############################# CEK KEBENERAN DUPLIKAT, APAKAH MEMANG DUPLIKAT?#####################
select * from layoff_staging
where company = 'casper';

## HAPUS DATA DUPLI
## GABISA PAKAI CTE KARENA SIFATNYA SEMENTARA
## BUAT TABEL BARU 

CREATE TABLE `layoff_staging4` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` double DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoff_staging4;

insert into layoff_staging4
select *, row_number () over (partition by company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num			### MASUKIN WINDOWS
from layoff_staging;

################################################# CEK DATA DUPLI ####################################
select * from layoff_staging4
where row_num > 1;
################################################ HAPUS DATA DUPLIKAT####################################
delete
from layoff_staging4
where row_num > 1;

############################################## STANDARISASI DATA ##############################

#  1. trim company
select company, trim(company) from layoff_staging4;
update layoff_staging4
set company = trim(company);
select * from layoff_staging4;

# 2. industry apakah ada yang dupe
select  distinct industry from layoff_staging4
order by 1;

update 
layoff_staging4
set industry = 'Crypto'
where industry like 'Crypto%';

# 3. Location
select  distinct Location from layoff_staging3
order by 1;

#4. Country 
select  distinct country from layoff_staging4
where country like 'united state%';

### United states nya
select distinct country, trim(trailing '.' from country)
from layoff_staging4
where country like 'United stat%';

update layoff_staging4
set country = trim(trailing '.' from country)
where country like '%United states%'; 

SELECT country, trim(country)
from layoff_staging4;

update layoff_staging4
set country = trim(country);

## 4. date nya diubah format
select `date` from layoff_staging4;
select `date`, str_to_date(`date`, '%m/%d/%Y')
from layoff_staging4;
update layoff_staging4
set `date` = str_to_date(`date`, '%m/%d/%Y');

## 5. ubah format text jadi date
alter table layoff_staging4
modify column `date` DATE;

## 6. Bekerja dengan null dan blank 
select * from layoff_staging4;
### cek bagian industry apakah ada yang kosong?
select * from layoff_staging4
where (industry is null or industry = '');
#### Airbnb
select * from layoff_staging4
where company = 'airbnb';

update layoff_staging4
set industry = NULL
where industry = ''; 

select t1.industry, t2.industry from layoff_staging4 t1
join layoff_staging4 t2
	on t1.company = t2.company
where t1.industry is null 
and t2.industry is not null;

update layoff_staging4 t1
join layoff_staging4 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null;

### total layoff dan persentase null kosong 2 2 nya baru bisa kita hapus karena gaada artinya waktu mau EDA
select * from layoff_staging4
where total_laid_off is NULL
and percentage_laid_off is NULL;

delete
from layoff_staging4
where total_laid_off is NULL
and percentage_laid_off is NULL;

## 7. Hapus kolom yang ga kepake yaitu kolom row_num
select * from layoff_staging4;
alter table layoff_staging4
drop column row_num;

## SELESAI


