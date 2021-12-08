/*
Housing Data Cleaning (as of 07/12/21)
*/

Select *
From PortfolioProjectSQL..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;
Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select saleDateConverted
From PortfolioProjectSQL..NashvilleHousing


 --------------------------------------------------------------------------------------------------------------------------

Select *
From PortfolioProjectSQL..NashvilleHousing
Where PropertyAddress is null
order by ParcelID

-- Populate Property Address data if it's null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)  -- populate PropertyAddress nulls
From PortfolioProjectSQL..NashvilleHousing a
JOIN PortfolioProjectSQL..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Check if it worked
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProjectSQL..NashvilleHousing a
JOIN PortfolioProjectSQL..NashvilleHousing b
	on a.ParcelID = b.ParcelID  -- same id
	AND a.[UniqueID ] <> b.[UniqueID ] -- not a same row
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- PropertyAddress

Select PropertyAddress
From PortfolioProjectSQL..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);
Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From PortfolioProjectSQL..NashvilleHousing

-- OwnerAddress (Another way, using PARSENAME)

Select OwnerAddress
From PortfolioProjectSQL..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From PortfolioProjectSQL..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjectSQL..NashvilleHousing
Group by SoldAsVacant
order by 2

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates 
-- (We ignore UniqueID column), this is purely for demonstrative purposes!

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProjectSQL..NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE PortfolioProjectSQL..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


Select *
From PortfolioProjectSQL..NashvilleHousing