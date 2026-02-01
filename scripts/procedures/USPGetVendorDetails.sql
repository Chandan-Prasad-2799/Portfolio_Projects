CREATE OR ALTER PROCEDURE dbo.USPGetVendorDetails
(
    @VendorID INT = NULL,
    @PageNo INT = 1,
    @PageSize INT = 10
)
AS
/********************************************************************************
Created By: Chandan Prasad
Created On: 31/01/2026
Purpose: To Get Vendor Details with Pagination
History:
-------
Date         Author            Description
----------   --------------    -----------------------------------------------
31/01/2026   Chandan Prasad    Initial Creation 
*******************************************************************************/
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartRow INT = (@PageNo - 1) * @PageSize + 1,
            @EndRow INT = @PageNo * @PageSize;

    ;WITH EntityCTE AS
    (
        SELECT 
            E.VendorID,
            E.VendorCode,
            E.VendorName,
            E.VendorDisplayname,
            ROW_NUMBER() OVER (ORDER BY E.VendorID DESC) AS RowNum
        FROM 
            dbo.VendorMaster E
        WHERE
            (@VendorID IS NULL OR E.VendorID = @VendorID)
    )
    SELECT 
        VendorID,
        VendorCode,
        VendorName,
        VendorDisplayname,
        RowNum
    FROM EntityCTE
    WHERE RowNum BETWEEN @StartRow AND @EndRow
    ORDER BY VendorID

    IF @VendorID IS NOT NULL
    BEGIN
        SELECT E.VendorID, VendorName, VendorDisplayname, VendorCode, BankCharges, Description
            , VendorWebsite, Street, Street1, Street2, Street3, City, POBox, Zip,
            State, Country, OtherIdentifier, VendorTaxID, TaxType, TaxPercentage, VendorLocalCcy, BankDebitDetails,
            ContactPersonName, ContactPersonNumber,EmailID1, EmailID2,
            BankName, BankAccNo, TransferType, BankCountry, ACHNo, WireDetails, BankEmailID
        FROM dbo.VendorMaster E
        WHERE E.VendorID = @VendorID

        SELECT FM.FundID, FM.FundCode, FM.FundName, VFM.FeeTypes
        FROM dbo.VendorFundMapping VFM
            INNER JOIN dbo.FundMaster FM ON VFM.FundID = FM.FundID
        WHERE VFM.VendorID = @VendorID

    END
END