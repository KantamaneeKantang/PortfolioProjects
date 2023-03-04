/*
Cleaning Data in SQL Queries
*/

Select *
From PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------

-- Starndard Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate) /*see again what it's work (Last step) */
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)  /* no change (try) */


ALTER TABLE NashvilleHousing  /* so add new column */
Add SaleDateConverted Date;

Update NashvilleHousing  /* update data date in the new column*/
SET SaleDateConverted = CONVERT(Date, SaleDate)


-----------------------------------------------------------------------------------
-- Populate Property Address data
----- 1. see null data 2. see ParcelID that have same property address 3. use the address that matched

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) /*To find null fist and check again after update ISNULL*/
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-----------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address                         /* SELECT SUBSTRING('SQL Tutorial', 1, 100) AS ExtractString; / The -1 is specified before comma*/
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address    /* staeting from 'after , + 1' until equal number of string (LEN()) */

From PortfolioProject.dbo.NashvilleHousing



--- So let's create to a new column of PropertyAddress

ALTER TABLE NashvilleHousing  /* so add new column */
Add PropertySplitAddress Nvarchar(225);

Update NashvilleHousing  /* update data date in the new column*/
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


--- So let's create to a new column of PropertyCity

ALTER TABLE NashvilleHousing  /* so add new column */
Add PropertyCity Nvarchar(225);

Update NashvilleHousing  /* update data date in the new column*/
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


--- Let's see whether it is updated

Select *
From PortfolioProject.dbo.NashvilleHousing






------Looking at Owneraddress (using PARSNAME that easier that substring)

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)   /*PARSENAME('object_name', object_piece) use for staring backwards  and Only use with . so chage , into . and 1 2 3 specify order of delimiter*/
, PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
From PortfolioProject.dbo.NashvilleHousing




--- So let's create to a new column of OwnerAdress



ALTER TABLE NashvilleHousing  
Add OwnerSplitAddress Nvarchar(225);

Update NashvilleHousing  
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3) 


--- So let's create to a new column of city

ALTER TABLE NashvilleHousing  
Add OwnerSplitCity Nvarchar(225);

Update NashvilleHousing  
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)

--- So let's create to a new column of state

ALTER TABLE NashvilleHousing  
Add OwnerSplitState Nvarchar(225);

Update NashvilleHousing  
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)



---see what's updated

Select *
From PortfolioProject.dbo.NashvilleHousing





--------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2





Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



--------------------------------------------------------------------------------------------------------

--Remove Duplicates


--identify those duplicates


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


From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)

--Select *                  /* See the duplicates*/
--From RowNumCTE
--Where row_num > 1
--Order by PropertyAddress

--DELETE                    /* Delete the duplicates*/
--From RowNumCTE
--Where row_num > 1
--Order by PropertyAddress

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress





Select *
From PortfolioProject.dbo.NashvilleHousing







-------------------------------------------------------------------------------------------------

--Delete Unused Columns


Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
