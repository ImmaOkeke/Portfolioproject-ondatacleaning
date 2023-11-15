select *
from dbo.NashvilleHousing

---Standardize sale date format
select SaleDateConverted, CONVERT(date, SaleDate)
from dbo.NashvilleHousing

Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert(Date, SaleDate)

---Populate property address data
select *
from dbo.NashvilleHousing
Where PropertyAddress is null
Order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b. [UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b. [UniqueID ]

---Breaking out address into individual columns (address, City, state)

Select PropertyAddress
from dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From dbo.NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
from dbo.NashvilleHousing

Select OwnerAddress
from dbo.NashvilleHousing

Select
Parsename(Replace(OwnerAddress, ',', '.') ,3),
Parsename(Replace(OwnerAddress, ',', '.') ,2),
Parsename(Replace(OwnerAddress, ',', '.') ,1)
from dbo.NashvilleHousing


Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.') ,3)

Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.') ,2)

Alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.') ,1)


---Changing Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case 
when SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End
From dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case 
when SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End

----Remove duplicates

With RowNumCTE As(
Select *,
Row_Number() Over(
Partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order by
			 UniqueID) row_num

FRom dbo.NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
Where row_num > 1
order by PropertyAddress
		

---delete unused columns

Select *
From dbo.NashvilleHousing


Alter table dbo.NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate