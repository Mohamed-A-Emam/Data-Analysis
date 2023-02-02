
-- Standardize Date Format

select * from [Housing Project2]
order by ParcelID

alter table [Housing Project2]
add DateSold Date

update [Housing Project2]
set DateSold = convert(Date, SaleDate)

alter table [Housing Project2]
drop column [SaleDate]
		  ,[LegalReference]
		  ,[Acreage]
		  ,[TaxDistrict]
		  ,[LandValue]
		  ,[BuildingValue]
		  ,[TotalValue]


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select * from [Housing Project2]
where PropertyAddress is null
order by ParcelID

update a
set a.PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from [Housing Project2] a
join [Housing Project2] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Using Substring to Break out the Property Address into Individual Columns (Address, City)

select * from [Housing Project2]
order by ParcelID

alter table [Housing Project2]
add [Address] nvarchar(255)

update [Housing Project2]
set [Address] = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

alter table [Housing Project2]
add [City] nvarchar(255)

update [Housing Project2]
set [City] = substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(propertyaddress))


--------------------------------------------------------------------------------------------------------------------------

-- Using Parsename to Break out the Owner Address into Individual Columns (Address, City, State)

alter table [Housing Project2]
add [OwnersAddress] nvarchar(255)
update [Housing Project2]
set [OwnersAddress] = parsename(replace(OwnerAddress,',','.'), 3)

alter table [Housing Project2]
add [OwnersCity] nvarchar(255)
update [Housing Project2]
set [OwnersCity] = parsename(replace(OwnerAddress,',','.'), 2)

alter table [Housing Project2]
add [OwnersState] nvarchar(255)
update [Housing Project2]
set [OwnersState] = parsename(replace(OwnerAddress,',','.'), 1)

alter table [Housing Project2]
drop column [OwnerAddress]



--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

update [Housing Project2]
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						end

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


with RowNumCTE as(
select * , ROW_NUMBER() over (partition by parcelid, ownername, propertyaddress, saleprice, datesold order by uniqueid) row_num
from [Housing Project2]
)
delete from RowNumCTE
where row_num > 1
-- order by ParcelID
