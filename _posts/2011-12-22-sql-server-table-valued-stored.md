---
title: 'SQL Server Table-Valued Stored Procedure Parameters <=> ADO.Net'
author: Beej
type: post
date: 2011-12-22T22:32:00+00:00
year: "2011"
month: "2011/12"
url: /2011/12/sql-server-table-valued-stored.html
blogger_bid:
  - 7726907200224433699
blogger_blog:
  - www.beejblog.com
blogger_id:
  - 1287557296909973670
blogger_author:
  - g108669953529091704409
blogger_permalink:
  - /2011/12/sql-server-table-valued-stored.html
dsq_thread_id:
  - 5821406805
categories:
tags:
  - DotNetFramework
  - Database

---
## Nutshell

1. Declare a User Defined Type (UDT)
1. Declare a stored proc parm of that UDT
1. Fill an ADO.Net DataTable with the same columns as the UDT
1. Assign the DataTable to a Parameter of an ADO.Net SqlCommand corresponding to the sproc

## Notes

* The Table-Valued Stored Procedure Parameters feature was first included in SQL Server 2008
* [Full working project source available here](https://code.google.com/p/yasbe/source/browse/trunk/#trunk)

## Code Examples

1. [File_UDT.sql](https://code.google.com/p/yasbe/source/browse/trunk/DB/DBobj/File_UDT.sql)

    ```sql
    CREATE TYPE File_UDT AS TABLE
    (
      FullPath varchar(900) PRIMARY KEY,
      ModifiedDate datetime,
      [Size] bigint
    )
    GO

    GRANT EXECUTE ON TYPE::dbo.File_UDT TO PUBLIC
    GO
    ```

    &nbsp;

1. [Files_UploadCompare.sql](https://code.google.com/p/yasbe/source/browse/trunk/DB/DBobj/Files_UploadCompare.sql)

    ```sql
    CREATE PROCEDURE dbo.Files_UploadCompare
    @BackupProfileID INT,
    @NextDiscNumber INT = NULL OUT,
    @AllFiles File_UDT READONLY -- <= *****
    AS BEGIN

    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    -- new approach, simply return all files which don't match something already in the database
    -- then we don't have to worry about partial results left in the tables ...
    -- we just upload the current batch of files when we're with each burn and then start fresh with the next batch selection from there
    -- there will be no records in FileArchive unless they've been put there specifically as marking a "finalized" MediaSubset

    SELECT *,
      CONVERT(BIT, 0) AS Selected,
      CONVERT(BIT, 0) AS SkipError
    FROM @AllFiles a
    WHERE NOT EXISTS(
      SELECT 1
      FROM FileArchive fa
      JOIN [File] f ON fa.FileID = f.FileID
      WHERE f.FullPath = a.FullPath AND fa.ModifiedDate = a.ModifiedDate AND fa.Size = a.Size
    )

    DECLARE @IncrementalID int
    SELECT @IncrementalID = MAX(IncrementalID) FROM Incremental WHERE BackupProfileID = BackupProfileID

    SELECT @NextDiscNumber = isnull(COUNT(1),0)+1 FROM MediaSubset WHERE IncrementalID = @IncrementalID

    END
    ```

    &nbsp;

1. [FileSystemNode.cs](https://code.google.com/p/yasbe/source/browse/trunk/App/FileSystemNode.cs)

    ```csharp
    static private void ScanFolder(FolderNode folder, DataTable IncludedFiles)
    {
      DirectoryInfo dir = new DirectoryInfo(folder.FullPath);
      FileInfo[] files = dir.GetFiles("*.*", folder.IsSubSelected ? SearchOption.TopDirectoryOnly : SearchOption.AllDirectories);
      foreach (FileInfo file in files)
      {
        DataRow r = IncludedFiles.NewRow();
        r["FullPath"] = file.FullName;
        r["ModifiedDate"] = file.LastWriteTimeUtc;
        r["Size"] = file.Length; //megabytes
        IncludedFiles.Rows.Add(r);
      }
    }
    ```

    &nbsp;

1. [MainWindow.xaml.cs](https://code.google.com/p/yasbe/source/browse/trunk/App/MainWindow.xaml.cs)

    ```csharp
    using (Proc Files_UploadCompare = new Proc("Files_UploadCompare"))
    {
      Files_UploadCompare["@BackupProfileID"] = (int)cbxBackupProfiles.SelectedValue;
      Files_UploadCompare["@AllFiles"] = IncludedFilesTable; // <= ******
      WorkingFilesTable = Files_UploadCompare.ExecuteDataTable();
      lblCurrentDisc.Content = Files_UploadCompare["@NextDiscNumber"].ToString();
    }
    ```

## Tips

* If the login that [SqlCommandBuilder.DeriveParameters](https://msdn.microsoft.com/en-us/library/system.data.sqlclient.sqlcommandbuilder.deriveparameters.aspx#3) is run under does not have permission to access the UDT, no error will be thrown &#8211; the method will return successfully, but the SqlCommand.Parameters collection will not contain the UDT parameter.!!!
* Granting permissions on a type ([from here](https://www.sqlteam.com/article/sql-server-2008-table-valued-parameters)): GRANT EXECUTE ON TYPE::dbo.MyType TO public;

## Links

* [MSDN page on Table-Valued Parameters](https://msdn.microsoft.com/en-us/library/bb510489.aspx)
