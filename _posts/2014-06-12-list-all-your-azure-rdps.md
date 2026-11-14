---
title: List all your Azure RDP's
date: 2014-06-12
author: Beej
tags:
  - Azure
  - PowerShell
  - SysAdmin
---

```powershell
Get-AzureVM | #this first one gets the entire list of VMs in subscription
    Get-AzureVM | # this one gets the detailed object for each specific VM
    %{
        $port = ($_ | Get-AzureEndpoint | ? {$_.name -like "Remote*"})[0].Port;
        $null = $_.DNSName -match 'https://(.*?)/'
        write-host "$($_.Name) - $($matches[1]):$($port)"
    }
```