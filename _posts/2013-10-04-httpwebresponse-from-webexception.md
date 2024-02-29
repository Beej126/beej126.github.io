---
title: HttpWebResponse from WebException
author: Beej
type: post
date: 2013-10-05T02:02:00+00:00
year: "2013"
month: "2013/10"
url: /2013/10/httpwebresponse-from-webexception.html
blogger_bid:
  - 7726907200224433699
blogger_blog:
  - www.beejblog.com
blogger_id:
  - 8485635023782115481
blogger_author:
  - g108669953529091704409
blogger_permalink:
  - /2013/10/httpwebresponse-from-webexception.html
dsq_thread_id:
  - 5530450352
categories:
tags:
  - DotNetFramework

---
```js
using (var response = (HttpWebResponse)((Func)(() =>
{
  try { return(request.GetResponse());}
  catch (WebException ex) { return(ex.Response); }
}))()) //<-- too funny
using (var responseStream = response.GetResponseStream())
// ReSharper disable once AssignNullToNotNullAttribute
using (var readStream = new StreamReader(responseStream, Encoding.UTF8))
{
  return String.Format("{0} {1}. {2}", (int)response.StatusCode, response.StatusCode, readStream.ReadToEnd());
}
```