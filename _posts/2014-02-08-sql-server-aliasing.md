---
title: SQL Server Aliasing
date: 2014-02-08
author: Beej
tags:
  - Database
thumbnail-img: /images/uploads/2014/02/SQL-Server-Configuration-Manager.png
---
<div class="separator" style="clear: both; text-align: center;">
  <a href="{{ site.baseurl }}/images/uploads/2014/02/SQL-Server-Configuration-Manager.png" imageanchor="1" style="clear: right; float: right; margin-bottom: 1em; margin-left: 1em;"><img border="0" src="{{ site.baseurl }}/images/uploads/2014/02/SQL-Server-Configuration-Manager.png" height="557" width="640" /></a>
</div>

  * Done via "SQL Server Configuration Manager" > "SQL Native Client vXY.Z Configuration" > Aliases
  * tip: SSMS.exe is a 32bit app (because Visual Studio, upon which it is based, still has a <a href="https://blogs.msdn.com/b/ricom/archive/2009/06/10/visual-studio-why-is-there-no-64-bit-version.aspx" target="_blank">well established justification for 32bit</a>) and therefore it depends on the (32bit) Client Configuration node above to find your server alias
  * For mainstream sql server network client API based connections there is no need to put this alias anywhere else (i.e. not in DNS/hosts file nor AD computers)
  * tip: in AD trusted login context, it seems mandatory to use the name of the actual SQL Server host machine vs just the corresponding ip address; otherwise i would always get bonked with "Login failed. The login is from an untrusted domain and cannot be used with Windows authentication."