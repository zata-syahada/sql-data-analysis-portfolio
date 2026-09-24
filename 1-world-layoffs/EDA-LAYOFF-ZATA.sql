SELECT * FROM world_layoffs.layoff_staging4;


####################################### Company yang paling banyak PHK ################################
select company, sum(total_laid_off)
from layoff_staging4
group by company
order by sum(total_laid_off) desc;

####################################### INdustry yang paling banyak PHK ################################
select industry, sum(total_laid_off)
from layoff_staging4
group by industry
order by sum(total_laid_off) desc;

###################################### Tahun paling banyak kena phk ###################################
select year(`date`), sum(total_laid_off)
from layoff_staging4
group by year(`date`)
order by sum(total_laid_off) desc;

###################################### Rerata karyawan yang di phk setiap tahun ###########################################
select year(`date`) as years, FLoor(avg(total_laid_off)) as average_laid_off
from layoff_staging4
where year(`date`) is not null
group by year(`date`)
order by average_laid_off desc
;

###################################### Negara mana yang paling banyak phk karyawan? ###################################
select country, sum(total_laid_off)
from layoff_staging4
group by country
order by sum(total_laid_off) desc;


###################################### Peringkat company yang phk karyawan terbanyak setiap tahunnya ################################
select company, year(`date`), sum(total_laid_off)
from layoff_staging4
group by company, year(`date`)
order by 3 desc;

with company_rank (company, `year`, Total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoff_staging4
group by company, year(`date`)
)
select *, dense_rank () over (partition by `year` order by total_laid_off desc)
from company_rank
where `year` is not null;

with company_rank (company, `year`, Total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoff_staging4
group by company, year(`date`)
)
select *, 
dense_rank () over (partition by `year` order by total_laid_off desc) as ranking
from company_rank
where `year` is not null
order by ranking asc;

with company_rank (company, `year`, Total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoff_staging4
group by company, year(`date`)
), comp_rank as 
(
select *, 
dense_rank () over (partition by `year` order by total_laid_off desc) as ranking
from company_rank
where `year` is not null
)
select * from comp_rank
where ranking <= 5;
;

################################### cek perusahaan dengan fund raised terbesar ##################################
with company_rank (company, `year`, funds_raised_millions) as
(
select company, year(`date`), sum(funds_raised_millions)
from layoff_staging4
group by company, year(`date`)
), comp_rank as 
(
select *, 
dense_rank () over (partition by `year` order by funds_raised_millions desc) as ranking
from company_rank
where `year` is not null
)
select * from comp_rank
where ranking <= 5;
;

################################# cari hubungan total karyawan phk dengan pendanaannya###########################
####### buat storre procedure untuk si ranking total karyawan kena phk

with company_rank (company, years, Total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoff_staging4
group by company, year(`date`)
), comp_rank as 
(
select *, 
dense_rank () over (partition by years order by total_laid_off desc) as ranking
from company_rank
where years is not null
), fund_rank (company, years, funds_raised_millions) as
(
select company, year(`date`), sum(funds_raised_millions)
from layoff_staging4
group by company, year(`date`)
), fund_ranking as 
(
select *, 
dense_rank () over (partition by years order by funds_raised_millions desc) as ranking
from fund_rank
where years is not null
)
select t1.company, t1.years, t1.total_laid_off, t2.company, t2.funds_raised_millions from comp_rank t1
join fund_ranking t2
	on t1.years = t2.years
    and t1.company = t2.company
where t1.years is not null and t2.years is not null  # and t1.company = 'NAME COMPANY'
order by t1.years DESC
;



