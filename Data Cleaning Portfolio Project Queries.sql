/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
-- Removing leading and trailing quotes from column

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 2, LEN(PropertyAddress)-2)
FROM PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET PropertyAddress = SUBSTRING(PropertyAddress, 2, LEN(PropertyAddress)-2)
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1) AS Address,
SUBSTRING (PropertyAddress,  CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress,  CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress))


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

SELECT SUBSTRING(OwnerAddress, 2, LEN(OwnerAddress)-2)
FROM PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET OwnerAddress = SUBSTRING(OwnerAddress, 2, LEN(OwnerAddress)-2)
FROM PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME (Replace(OwnerAddress,',','.'), 3),
PARSENAME (Replace(OwnerAddress,',','.'), 2),
PARSENAME (Replace(OwnerAddress,',','.'), 1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME (Replace(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME (Replace(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME (Replace(OwnerAddress,',','.'), 1)


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Change 0 and 1 to Yes and No in "Sold as Vacant" field

SELECT 
    CONVERT(VARCHAR(30), SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SoldAsVacant_varchar Nvarchar(255);

UPDATE NashvilleHousing
SET SoldAsVacant_varchar = CONVERT(VARCHAR(30), SoldAsVacant)

SELECT DISTINCT(SoldAsVacant_varchar), COUNT(SoldAsVacant_varchar)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant_varchar
ORDER BY 2

SELECT SoldAsVacant_varchar,
CASE
	WHEN SoldAsVacant_varchar = 1 THEN 'Yes'
	WHEN SoldAsVacant_varchar = 0 THEN 'No'
	ELSE SoldAsVacant_varchar
	END
FROM PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant_varchar = CASE When SoldAsVacant_varchar = '1' THEN 'Yes'
	   When SoldAsVacant_varchar = '0' THEN 'No'
	   ELSE SoldAsVacant_varchar
	   END

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
	ORDER BY UniqueID) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)

DELETE
FROM RowNumCTE 
WHERE row_num > 1
--ORDER BY PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SoldAsVacant
