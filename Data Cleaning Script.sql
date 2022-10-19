select *
from PortfolioProject..NashvilleHousing



-- Standardize date format
------------------------------------------------

select SaleDate, CONVERT(date, SaleDate)
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)

alter table PortfolioProject..NashvilleHousing
add SaleDateConverted date;

update PortfolioProject..NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)

select SaleDateConverted, CONVERT(date, SaleDate)
from PortfolioProject..NashvilleHousing


-- Populate Property Address data
------------------------------------------------

select * -- PropertyAddress
from PortfolioProject..NashvilleHousing
where PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-- Break out PropertyAddress into individual columns (address, city)
-------------------------------------------------------------------

select PropertyAddress
from PortfolioProject..NashvilleHousing


select PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing

-- Add two new columns for address and city
alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress nvarchar(255), PropertySplitCity nvarchar(255)

-- Update new columns
update PortfolioProject..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

-- Verify update
select PropertyAddress, PropertySplitAddress, PropertySplitCity
from PortfolioProject..NashvilleHousing


-- Break out OwnerAddress into individual columns (address, city, state)
-------------------------------------------------------------------

select OwnerAddress
from PortfolioProject..NashvilleHousing

select OwnerAddress, PARSENAME(replace(OwnerAddress, ',', '.'), 3) as Address, PARSENAME(replace(OwnerAddress, ',', '.'), 2) as City, PARSENAME(replace(OwnerAddress, ',', '.'), 1) as State
from PortfolioProject..NashvilleHousing

-- Add three new columns for address, city and state
alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(255), OwnerSplitCity nvarchar(255), OwnerSplitState nvarchar(255)

-- Update new columns
update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3),
	OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2),
	OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

-- Verify update
select OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from PortfolioProject..NashvilleHousing



-- Change Y/N to Yes/No in "SoldAsVacant" column

select  SoldAsVacant, count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant

select SoldAsVacant,
	case 
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end
from PortfolioProject..NashvilleHousing

--Update
update PortfolioProject..NashvilleHousing
set SoldAsVacant = case 
						when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
					end


-- Remove duplicates

with RowNumCTE as (
	select *,
		ROW_NUMBER() over (
			partition by ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						order by UniqueID) as row_num
	from PortfolioProject..NashvilleHousing
	--order by ParcelID
)
delete
from RowNumCTE
where row_num > 1

select *
from PortfolioProject..NashvilleHousing


-- Delete unused columns

alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject..NashvilleHousing
drop column SaleDate