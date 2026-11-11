---
title: Linq Enumerable to another Collection
date: 2016-10-27
author: Beej
tags:
  - Json
  - Linq
---
given devices is an IEnumberable<>

    var nvc = devices.Aggregate(new NameValueCollection(), (seed, current) => { seed.Add("device", current.Id.ToString()); return seed; });
    

Json Array of objects to Dictionary, keyed (indexed) on chosen property

    using Json.Net; //Newtonsoft
    using Json.Net.Linq;
    
    public class Device {
      public int Id {get; set;}
      public string Name {get; set;}
      public string Property {get; set;}
    }
    
    var json = @"[{id: 1, name: ""name1"", prop: ""prop1""}, {id: 2, name: ""name2"", prop: ""prop""}]";
    
    var devicesDictionary = JArray.Parse(json).ToDictionary( i=>i["id"].Value<int>(), i=>i.ToObject<Device>() );