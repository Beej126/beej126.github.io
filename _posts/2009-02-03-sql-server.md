---
title: SQL Server "CHECKSUM()"
date: 2009-02-03
author: Beej
tags:
  - Database
---
Absolutely crazy I hadn't run across this little gem yet... could've used that bugger to get out of a couple jams.&#160; e.g. eliminating heavily duplicated xml blobs that represent incoming supply chain events/transactions.&#160; The BOL has a couple examples to get your juices flowing.&#160; e.g. Run it on a column list, CHECKSUM(*), to compare rows.&#160; There's also BINARY\_CHECKSUM(), HashBytes() and CHECKSUM\_AGG() for different slices.