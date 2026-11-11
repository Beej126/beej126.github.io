---
title: Fix Orphaned SQL Server Database Users
date: 2011-02-23
author: Beej
tags:
  - Database
---
<a href="https://vyaskn.tripod.com/troubleshooting_orphan_users.htm" target="_blank">Good reference</a>

Quick examples:

<pre class="prettyprint lang-sql">sp_change_users_login 'report' -- this shows the list of orphaned users in the current database
sp_change_users_login 'update_one', 'iTRAAC_User', 'iTRAAC_User' -- this is how you remap one
</pre>