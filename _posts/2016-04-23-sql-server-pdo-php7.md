---
title: SQL Server PDO PHP7
date: 2016-04-23
author: Beej
tags:
  - Database
  - PHP
---
  1. [get the DLL][1] - grab latest x64.zip
  2. add to your php.ini extension list: 
        [ExtensionList]
        extension=php_pdo_sqlsrv_7_nts.dll
        

  3. here's sample call code: 
        <?php
        
        try {
             $conn = new PDO( "sqlsrv:Server= ip_address; Database = mydb ", $user, $pwd);
             $conn->setAttribute( PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION );
        }
        catch(Exception $e){
             die(var_dump($e));
        }
        
        $stmt = $conn->query($qry);
        $result = $stmt->fetchAll();
        $row = $result[0];
        $colval = $row["fieldname"];
        ?>

 [1]: https://github.com/Azure/msphpsql/releases