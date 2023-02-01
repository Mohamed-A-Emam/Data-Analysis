
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








-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO
