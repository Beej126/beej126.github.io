---
title: "gBox Resurrected"
date: 2019-07-24T14:19:42-08:00
type: post
author: Beej
year: "2019"
month: "2019/07"
url: /2019/07/2019-07-24-gBox-Resurrected.html
tags:
  - Hardware
thumbnail-img: https://user-images.githubusercontent.com/6301228/62012493-e71af080-b13b-11e9-9957-6ef88e03d005.jpg
---

<img style="height: 300px; float:right; margin: 0.6em" src="https://user-images.githubusercontent.com/6301228/62012493-e71af080-b13b-11e9-9957-6ef88e03d005.jpg" />

## Geek Crush Origin Story
Back around 2002 (yes '02 not '20), I still remember sitting in the company lunch room where I worked on the south side of Chicago, casually browsing the back ads section of an [InfoWorld](https://en.wikipedia.org/wiki/InfoWorld) when I saw this barebones kit they were calling the "gBox". 
<img style="height: 300px; float:right; margin: 0.6em" src="https://user-images.githubusercontent.com/6301228/64924190-a5e7aa00-d796-11e9-880c-c9f2498ba540.png" />
I was instantly drawn to the acrylic wrapped aluminum look... an admitedly crude reference to the Power Mac G4 Cube which had [gloriously fizzled just a year prior](https://www.wired.com/story/20-years-ago-steve-jobs-built-the-coolest-computer-ever-it-bombed/) - that S.Job's article is a great example of "[Strong Opinions Loosely Held](https://tim.blog/2018/01/01/the-tim-ferriss-show-transcripts-marc-andreessen/#:~:text=strong%20opinions%20loosely%20held)".

## Old School Refs
"Wayback Machine" links to reviews and marketing from that era... this box was a mild fan favorite for its day
- [AMSElectronics.com CF-S868 Product Page](https://web.archive.org/web/20061029171006/http://www.amselectronics.com/Products/PC_Servers/CF-S868.html)
- [ChyangFun.com CF-S868 Product Page](https://web.archive.org/web/20020903192257/http://www.chyangfun.com/Product/S868.htm)
- [PugetSystems.com review with photos](https://www.pugetsystems.com/labs/articles/AMS-gBox-P4-DDR-Review-9/)
- [DansData.com Review with photos](http://www.dansdata.com/minipc.htm)
- [LittleWhiteDog.com Review full teardown](https://web.archive.org/web/20030207121431/http://www.littlewhitedog.com/reviews_hardware_00040.asp)
- [Falcon Northwest original "Fragbox"](https://web.archive.org/web/20031206091154/http://www.falcon-nw.com/fragbox.asp) - Falcon switched to a SilverStone case for several years after the original Chyang; and pretty sure they're using something else these days.  It's notable even in 2019 they continue to find reason to sell something WITH A HANDLE.

## New Parts
- Mobo: [ASRock z390 Phantom Gaming-ITX/ac](https://www.asrock.com/MB/Intel/Z390%20Phantom%20Gaming-ITXac/index.asp) ([full manual](https://download.asrock.com/Manual/Z390%20Phantom%20Gaming-ITXac.pdf), [quick install guide](https://download.asrock.com/Manual/QIG/Z390%20Phantom%20Gaming-ITXac_multiQIG.pdf))
  - I don't know if i'll ever really need Thunderbolt-3 for anything but it feels good to have it as an option for an external hard drive enclosure.
- CPU: [Intel Core i9-9900K](https://www.intel.com/content/www/us/en/products/processors/core/i9-processors/i9-9900k.html)
  - This is 9th gen Intel "Coffee Lake", 8 core with integrated HD 630 graphics.
  - I'm stoked we can finally run two full 4k digital video ports (DP & HDMI) in the ITX footprint without a video card. This fits the compact developer workstation profile I'm looking for in this rig... big screens and fast compiles, no games here, all business =)
  - A short discrete graphics card might just barely fit if I really need to go there some day but those thermals would definitely require revisiting my simplistic ventilation.
- Cooler: [Corsair Hydro Series H80i v2](https://www.corsair.com/us/en/Categories/Products/Liquid-Cooling/Single-Radiator-Liquid-Coolers/Hydro-Series%E2%84%A2-H80i-v2-High-Performance-Liquid-CPU-Cooler/p/CW-9060024-WW)
  - admittedly this little 1U 120mm radiator would be easily overwhelmed by the 9900K doing any aggressive overclocking... at least the radiator is double thick and the fans are configured in optimal push+pull... i love how well this bugger brings the biggest cooling stack possible for the space available ([best photo](https://user-images.githubusercontent.com/6301228/61926906-78fde000-af27-11e9-9a90-f62c0eca7a34.png)).
- RAM: [Corsair Dominator Platinum 32GB (2x16GB) DDR4 3200MHz C16](https://www.corsair.com/us/en/Categories/Products/Memory/DOMINATOR%C2%AE-PLATINUM-32GB-%282-x-16GB%29-DDR4-DRAM-3200MHz-C16-Memory-Kit/p/CMD32GX4M2C3200C16)
- SSD: 
  1. [Samsung 970 PRO 512GB - NVMe PCIe M.2](https://www.samsung.com/us/computing/memory-storage/solid-state-drives/ssd-970-pro-nvme-m2-512gb-mz-v7p512bw/) - These PCIe drives crank 3500 MB/s reads! and 5yr warranty.
  2. [Samsung 980 PRO 1TB](https://www.samsung.com/us/computing/memory-storage/solid-state-drives/980-pro-pcie-4-0-nvme-ssd-1tb-mz-v8p1t0b-am/) - by Christmas 2021 feeling the squeeze of local dev databases and docker containers, added a 1TB Sammy 980 to this mobo's secondary M.2 slot... I grew up on C64/Amiga and still marvel at all the cheap & easy expansion possibilities we have now. Local Oracle absolutely flies on 7,000 MB/s reads. Thanks Santa!
- PSU: [Corsair SF600 Platinum](https://www.corsair.com/us/en/Categories/Products/Power-Supply-Units/Power-Supply-Units-Advanced/SF-Series/p/CP-9020182-NA)
  - Lots to say about this below.

<style>
div.gallery + p img {
  height: 300px;
}
</style>

<div class="gallery"></div>
![](https://www.asrock.com/mb/photo/Z390%20Phantom%20Gaming-ITXac(L4).png)
![](https://user-images.githubusercontent.com/6301228/64915747-4d2af980-d723-11e9-831d-cf6d8af2625b.png)
![](https://www.corsair.com/medias/sys_master/images/images/h8d/h78/9110765076510/-CW-9060024-WW-Gallery-H80i-01.png)
![](https://www.corsair.com/medias/sys_master/images/images/hfd/h03/9110470361118/-CMD32GX4M2C3200C16-Gallery-DOM-DDR4-PLAT-002.png)
![](https://image-us.samsung.com/SamsungUS/home/computing/memory-and-storage/solid-state-drives/pdp/mz-v7p512bw/gallery-updates-10-02-18/002_gallery_MZ-V7P512BW_10-02-18.jpg)
![](https://www.corsair.com/medias/sys_master/images/images/h07/h21/9112508497950/-CP-9020182-NA-Gallery-SF600-09.png)

## Highlights

- **<span style="float: left; font-size: 3em; margin: 0.3em 5px 0 0px; color: red">H</span>andle** - The "LAN box" handle on this case remains pretty hard to find in the endless stream of cases we see year after year.  There's always plenty of Small Form Factor (SFF) cases to choose from but somehow handles have never caught on mainstream.  It's so satisfying to grab that sucker and chuck it somewhere.  Allegedly it jumped in my backpack and went to work one day ;)

- [<img style="float: right; height: 300px; margin: 0.6em;" src="https://upload.wikimedia.org/wikipedia/commons/f/fd/ATX_ITX_AT_Motherboard_Compatible_Dimensions.svg" />](https://en.wikipedia.org/wiki/ATX) The original layout of this kit was based on a short lived standard called "[FlexATX](https://en.wikipedia.org/wiki/FlexATX)". Note on the adjascent wikipedia diagram in the light orange outline how it was a little bit longer and wider than the ubiquitous mini-ITX format. This resulted in a little work to add new mount posts on the floor of the case to align with the ITX hole standard.

   - The extra Flex depth wound up being a real blessing - providing just enough headroom for the giant cooling radiator and fans to squeeze in behind the front face. Then the ITX mobo eats up all the remaining floor space (see photos). The fans are in push + pull configuration to get as much cooling as possible. But it's true, the i9-9900k CPU can still easily overwhelm this small of a cooler with overclocking.
   - I also like how a case like this keeps the motherboard in what I feel is the more natural horizontal position, where weights like the CPU cooler  are pressing down into the socket versus endlessly torquing sideways throughout the lifespan.
<div><br/></div>

- I/O plate - The original "bare bones" kit this case came with had a noble design of marrying the mobo's I/O ports to customized punchouts in the case's rear aluminum face... but now we want a modern ITX I/O plate there, which meant carving out that whole area with the dremel to be an open "mouth".

- <img style="float: right; height: 300px; margin: 0.6em;" src="https://user-images.githubusercontent.com/6301228/64915665-1227c680-d721-11e9-9e59-30fa51b537aa.png" /> I was particularly relieved to finally stumble into [SFX](https://www.tomshardware.co.uk/power-supply-specifications-atx-reference,review-32338-4.html) form factor PSUs (wait, this has been a standard since 1997!?)
  - This case absolutely requires the short 100mm depth of more recently defined "PS3" sub species of SFX... any deeper and the power cable bundle would run into the optical drive bay.  So this got me into the right depth, but the stock SFX height didn't fill out the entire opening on the back of this case :\...
  - After fretting quite a bit, I finally noticed these can be fitted with an <u>extension plate</u> that covers the standard ATX PSU opening, exactly what I needed! <span class="hl">The ATX face plate combined with the SFX short depth is an absolute dream fit for this case</span>.
  - The horsepower these vendors are cramming into such a small box is pretty amazing when you look at a full size ATX PSU next to it.
  - The difference between the stock PSU this kit came with is rediculous. It's so cool we have such an abundant selection of high end supplies to choose from mainstream manufacturers like Corsair at this point: 750 watts, gold / even platinum level 80 plus certification, powder coated paint jobs, <u>modular cables</u>, of course including all the extra 12v lines required by modern multicore CPUs.

It all came together in a super pleasing DIY blend of modern components wrapped in retro =)

The ITX retrofitting puts it back on the beaten upgrade path for years to come.

## Current State (2019)

<div class="gallery"></div>
[![image](https://user-images.githubusercontent.com/6301228/232090343-b9a6e517-2506-4c3a-8ce2-c9227f879b4e.png)](https://user-images.githubusercontent.com/6301228/232090343-b9a6e517-2506-4c3a-8ce2-c9227f879b4e.png)
[![](https://user-images.githubusercontent.com/6301228/61926845-3805cb80-af27-11e9-9d45-774d6e673f3b.png)](https://user-images.githubusercontent.com/6301228/61926845-3805cb80-af27-11e9-9d45-774d6e673f3b.png)
[![IMG_2942](https://user-images.githubusercontent.com/6301228/64916135-1e655100-d72c-11e9-9e2e-211004a9ada3.JPG)](https://user-images.githubusercontent.com/6301228/64916135-1e655100-d72c-11e9-9e2e-211004a9ada3.JPG)
[![IMG_2940](https://user-images.githubusercontent.com/6301228/64916116-a1d27280-d72b-11e9-99fc-fb6a967ed446.JPG)](https://user-images.githubusercontent.com/6301228/64916116-a1d27280-d72b-11e9-99fc-fb6a967ed446.JPG)
[![](https://user-images.githubusercontent.com/6301228/61926906-78fde000-af27-11e9-9a90-f62c0eca7a34.png)](https://user-images.githubusercontent.com/6301228/61926906-78fde000-af27-11e9-9a90-f62c0eca7a34.png)
[![IMG_2954](https://user-images.githubusercontent.com/6301228/70576016-a8229000-1b5c-11ea-9821-e3bdf97c84a4.png)](https://user-images.githubusercontent.com/6301228/70576016-a8229000-1b5c-11ea-9821-e3bdf97c84a4.png)



## Mod'ing *(sortof =)*

<div class="gallery"></div>
[![IMG_2531](https://user-images.githubusercontent.com/6301228/64916167-4ef9ba80-d72d-11e9-8ceb-838ca34487e0.JPG)](https://user-images.githubusercontent.com/6301228/64916167-4ef9ba80-d72d-11e9-8ceb-838ca34487e0.JPG)
[![img_2538](https://user-images.githubusercontent.com/6301228/64916161-1823a480-d72d-11e9-9c2b-82756caa4ba2.jpg)](https://user-images.githubusercontent.com/6301228/64916161-1823a480-d72d-11e9-9c2b-82756caa4ba2.jpg)
[![IMG_2543](https://user-images.githubusercontent.com/6301228/64916185-a3049f00-d72d-11e9-995c-7d62f2b3a835.JPG)](https://user-images.githubusercontent.com/6301228/64916185-a3049f00-d72d-11e9-995c-7d62f2b3a835.JPG)
[![IMG_2541](https://user-images.githubusercontent.com/6301228/64916189-adbf3400-d72d-11e9-9ca4-4f37efdaa879.JPG)](https://user-images.githubusercontent.com/6301228/64916189-adbf3400-d72d-11e9-9ca4-4f37efdaa879.JPG)
[![IMG_2541](https://user-images.githubusercontent.com/6301228/70576206-2d0da980-1b5d-11ea-8488-0ff2375b220c.png)](https://user-images.githubusercontent.com/6301228/70576206-2d0da980-1b5d-11ea-8488-0ff2375b220c.png)
[![image](https://user-images.githubusercontent.com/6301228/70576462-d3f24580-1b5d-11ea-82ca-19fdcf702c5b.png)](https://user-images.githubusercontent.com/6301228/70576462-d3f24580-1b5d-11ea-82ca-19fdcf702c5b.png)
[![image](https://user-images.githubusercontent.com/6301228/70576900-eae56780-1b5e-11ea-8425-07689a009bb8.png)](https://user-images.githubusercontent.com/6301228/70576900-eae56780-1b5e-11ea-8425-07689a009bb8.png)
[![image](https://user-images.githubusercontent.com/6301228/70576324-76f68f80-1b5d-11ea-93b9-bf33337ca919.png)](https://user-images.githubusercontent.com/6301228/70576324-76f68f80-1b5d-11ea-93b9-bf33337ca919.png)
