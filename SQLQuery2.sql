-- NASHVILLE HOUSING DATA CLEANING

select*
from SQLPortefolio..NashvilleHousing

-- 1/ STANDARDIZE DATE FORMAT
--update NashvilleHousing
--set SaleDate = convert(date, SaleDate)

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

select SaleDateConverted, convert(date, SaleDate)
from SQLPortefolio..NashvilleHousing

-- 2/ POPULATE PROPERTY ADRESSE DATA
select *
from SQLPortefolio..NashvilleHousing
--where PropertyAddress is NULL 
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from SQLPortefolio..NashvilleHousing a
join SQLPortefolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from SQLPortefolio..NashvilleHousing a
join SQLPortefolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- 3/ BREAKING OUT ADRESSE INTO INDIVIDUAL COLUMN (ADRESSE, CITY, STATE)
select PropertyAddress
from SQLPortefolio..NashvilleHousing 

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) as Adress,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, len(PropertyAddress)) as City
from SQLPortefolio..NashvilleHousing

alter table NashvilleHousing
add Property_Adress nvarchar(255);
update NashvilleHousing
set Property_Adress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1)

alter table NashvilleHousing
add Property_City nvarchar(255);
update NashvilleHousing
set Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, len(PropertyAddress))

-- OWNER ADRESS PARSING	(ALTERNATIVE WAY TO PARSE)
select*
from SQLPortefolio..NashvilleHousing

alter table NashvilleHousing
add Owner_Adress nvarchar(255);
update NashvilleHousing
set Owner_Adress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add Owner_City nvarchar(255);
update NashvilleHousing
set Owner_City = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add Owner_State nvarchar(255);
update NashvilleHousing
set Owner_State = parsename(replace(OwnerAddress, ',', '.'), 1)

-- 4/ CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD
select distinct(SoldAsVacant), count(SoldAsVacant)
from SQLPortefolio..NashvilleHousing
group by SoldAsVacant

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from SQLPortefolio..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

-- 5/ REMOVE DUPLICATES

with RowNumCTE as
(
select*,
	ROW_NUMBER() over(
	partition by ParcelID,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID
				 ) row_num
from SQLPortefolio..NashvilleHousing
)
--select*
--from RowNumCTE
--where row_num > 1
delete
from RowNumCTE
where row_num > 1

-- 6/ DELETE UNUSED COLUMNS

alter table SQLPortefolio..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table SQLPortefolio..NashvilleHousing
drop column SaleDate

select*
from SQLPortefolio..NashvilleHousing
