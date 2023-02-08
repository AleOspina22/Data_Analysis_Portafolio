SELECT *
FROM NashvilleHousing.nashville_housing_full;

# Standardize SaleDate format

/*
SELECT  SaleDate, CAST(STR_TO_DATE(SaleDate, '%M %e,%Y') as DATE)
FROM    NashvilleHousing.nashville_housing_full;*/


ALTER TABLE NashvilleHousing.nashville_housing_full
CHANGE COLUMN  SaleDate DATE;

UPDATE NashvilleHousing.nashville_housing_full
SET SaleDat = CAST(STR_TO_DATE(SaleDate, '%M %e,%Y') as DATE);


# Populate Property address data (I want to check that every ParcelID have the same Adress and if a ParelID doen't have an Adress, I will put the Adress of another same ParcelID that have the information

SELECT  a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(b.PropertyAddress, a.PropertyAddress)
FROM    NashvilleHousing.nashville_housing_full AS a 
	JOIN NashvilleHousing.nashville_housing_full AS b
    ON a.ParcelID = b.ParcelID AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress = 'A';



UPDATE NashvilleHousing.nashville_housing_full AS a 
	JOIN NashvilleHousing.nashville_housing_full AS b
	ON a.ParcelID = b.ParcelID AND a.UniqueID != b.UniqueID
SET a.PropertyAddress = COALESCE(b.PropertyAddress, a.PropertyAddress)
WHERE a.PropertyAddress = 'A';



# Breaking out adress into individual columns the PropertyAddress (Address, City, State)

SELECT 
SUBSTRING(PropertyAddress, 1, locate(',', PropertyAddress) -1) AS Address, 
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, CHAR_LENGTH(PropertyAddress)) AS Address
FROM NashvilleHousing.nashville_housing_full;


ALTER TABLE NashvilleHousing.nashville_housing_full
ADD PropertySplitAddress varchar(255);

UPDATE NashvilleHousing.nashville_housing_full
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, locate(',', PropertyAddress) -1);

ALTER TABLE NashvilleHousing.nashville_housing_full
ADD PropertySplitCity varchar(255);

UPDATE NashvilleHousing.nashville_housing_full
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, CHAR_LENGTH(PropertyAddress));


SELECT *
FROM NashvilleHousing.nashville_housing_full;

# Breaking out adress into individual columns the OwnerAddress


SELECT 
SUBSTRING_INDEX(REPLACE(OwnerAddress, ',','.'), '.', 1),
SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',','.'), '.', 2), '.', -1),
SUBSTRING_INDEX(REPLACE(OwnerAddress, ',','.'), '.', -1)
FROM NashvilleHousing.nashville_housing_full;


ALTER TABLE NashvilleHousing.nashville_housing_full
ADD OwnerSplitAddress varchar(255);

UPDATE NashvilleHousing.nashville_housing_full
SET OwnerSplitAddress = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',','.'), '.', 1);


ALTER TABLE NashvilleHousing.nashville_housing_full
ADD OwnerSplitCity varchar(255);

UPDATE NashvilleHousing.nashville_housing_full
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',','.'), '.', 2), '.', -1);



ALTER TABLE NashvilleHousing.nashville_housing_full
ADD OwnerSplitState varchar(255);

UPDATE NashvilleHousing.nashville_housing_full
SET OwnerSplitState = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',','.'), '.', -1);



# Change the Y to Yes and N to No in the SoldAsVacant field

SELECT SoldAsVacant,
	CASE 
		WHEN SoldAsVacant ='Y' THEN 'YES'
		WHEN SoldAsVacant ='N' THEN 'NO'
		ELSE SoldAsVacant
	END
FROM NashvilleHousing.nashville_housing_full;

UPDATE NashvilleHousing.nashville_housing_full
SET SoldAsVacant = 	
	CASE 
		WHEN SoldAsVacant ='Y' THEN 'YES'
		WHEN SoldAsVacant ='N' THEN 'NO'
		ELSE SoldAsVacant
	END;
    
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing.nashville_housing_full
GROUP BY SoldAsVacant
ORDER BY 2;

# Removing duplicates 

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
    PARTITION BY 	ParcelID,
					PropertyAddress,
                    SalePrice,
                    LegalReference
                    ORDER BY
						UniqueID
						) row_numb
FROM NashvilleHousing.nashville_housing_full
-- ORDER BY ParcelID;
)
DELETE 
FROM RowNumCTE
WHERE row_numb > 1;
-- ORDER BY PropertyAddress;



# Delete unused columns

ALTER TABLE NashvilleHousing.nashville_housing_full
DROP COLUMN OwnerAddress,
DROP COLUMN  TaxDistrict,
DROP COLUMN  PropertyAddress;



SELECT *
FROM NashvilleHousing.nashville_housing_full
