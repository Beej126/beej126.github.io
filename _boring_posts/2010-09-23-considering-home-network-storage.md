---
title: Considering Home Network Storage Alternatives
author: Beej
type: post
date: 2010-09-23T16:47:00+00:00
year: "2010"
month: "2010/09"
url: /2010/09/considering-home-network-storage.html
blogger_bid:
  - 7726907200224433699
blogger_blog:
  - www.beejblog.com
blogger_id:
  - 5452798441869646933
blogger_author:
  - g108669953529091704409
blogger_permalink:
  - /2010/09/considering-home-network-storage.html
dsq_thread_id:
  - 5510969455
tags:
  - Hardware
  - Music
  - Networking
  - SysAdmin
  - Video

---
My current bottom line is that I've got a 6 x SATA ICH9R just sitting there on my main Windows 7 machine's mobo for _free_ so I slapped on 2 TB x 2 in RAID1, published a few shared folders and leave that machine powered on 24/7. After everything else (optical & OS drives) I had two ports left doing nothing so the previous gen 750GB's x 2 are in RAID0 receiving scheduled backups for a little more cheap peace of mind. I'm hoping by the time I actually need more space, that there will be something along the lines of a 5-bay Drobo engineered around <a href="https://en.wikipedia.org/wiki/Serial_ATA#SATA_Revision_3.0_.28SATA_6_Gbit.2Fs.29" target="_blank">SATA 3.0 (6 Gb/s)</a> internally and <a href="https://en.wikipedia.org/wiki/Universal_Serial_Bus#USB_3.0" target="_blank">USB 3.0 (5 Gb/s!!)</a> externally to finally give us some serious speed for that $700 price point. My big up front consideration: NAS vs DAS 

  * What's better, a true stand alone NAS box –OR- a large/fast <a href="https://en.wikipedia.org/wiki/Direct_attached_storage" target="_blank">DAS</a> array shared from your primary machine??? 
  * FOR THE HOME scenario: I always go back to preferring DAS connected to my main beefiest workstation/"home-server" 
  * You get to rally the performance wagons around at least one location where you have absolute top end HDD access when you want it… 
  * If you go with a NAS, you basically accept that GbE is your top end… true, even DAS RAID0 HDD configs generally level out around 100MB/s average xfer rate which is basically the GbE saturation point (1 Gb/s = 125 MB/s minus some packet overhead puts you right around 100 MB/s)… but sequential burst rates can go upwards of 300MB/s (2.4 Gb/s) … so I believe NAS over GbE could very well prevent your drives from spitting the bits as fast as they're capable. 
  * After chasing NAS box performance specs for a while you start to realize that the end game is basically spec'ing out a mid-range PC… so that's why I can't stop swinging back to throwing my money at the primary machine's horsepower and just leave that powered up all the time to share files. 
  * My current working scenario is based on a main machine that's sits at the center of our home's media universe as the do-it-all living room media player… projector, good speakers, VLC, iTunes, etc… after that, it's a matter of streaming (primarily video) wirelessly for individual needs (<a href="/2008/08/samsung-q1u-umpc.html" target="_blank">internet tablet</a>, wifey's PC, etc)… even if I did have the luxury of hiding that main machine somewhere other than the main living space, I think I'd just roll with a cheapo networked media player (e.g. <a href="/2009/06/portable-media-players.html" target="_blank">Western Digital TV</a>) in the living room with network storage requirements still covered by the main box. 
  * Invariably one wants to share a few things out on the internet as well as around the home… my config readily lends itself to accomplishing this from simple IIS Directory Browsing up to a full blown photo gallery (PHP/MySQL based <a href="/2010/10/self-hosting-zenphoto-on-windows-7-iis7.html" target="_blank">zenPhoto</a>, love it!!)… other NAS boxes (Synology, etc.) market themselves on more and more "server" oriented features, but why fuss with learning and navigating around the limitations of various embedded linux flavors when you can have the full power of your primary machine's OS to load up all kinds of goodies?? e.g. Synology's built in photo gallery is nice but open source is always going to be ahead of the game 
  * Another consideration: you don't hear much talk about virus checking and NAS… maybe I'm worrying about this too much but full scans are something that one must do from time to time… ok yes, most of what we're putting out there is going to be non executable media that doesn't require scanning… but being a developer, I've developed a fairly extensive library of software that I like to have on hand… it's doesn't add up as fast as movies but it's substantial… and apparently even JPG's can get viruses… the thought of scanning all those files over the wire (repeatedly) just doesn't appeal to me. 
  * I like the idea of running a reasonable database in this space… granted the optimal database drive configuration is not the same as your primary storage volume –BUT- you do still benefit from having those byte buckets _near_ each other for backups and such 
  * [29 Sep 2010] Another one hit me: We finally have full <a href="https://en.wikipedia.org/wiki/Symbolic_link#Windows_7_.26_Vista_symbolic_link" target="_blank">symbolic/hard-link</a> flexibility under Windows 7 NTFS… we can cross phyiscal drives with a link, etc… this allows full granularity to choose exactly what consumes the more valuable RAID1 space but still _symlink_ anything into the same visible folder hierarchy… e.g. a single "movie" shared folder is physically comprised of "classics" subfolder (hosted on RAID1) in addition to "unwatched" (hosted on RAID0)… <a href="https://schinagl.priv.at/nt/hardlinkshellext/hardlinkshellext.html" target="_blank">Shell Link Extension</a> makes symlinks awesomely convenient to create with Windows Explorer. 
  * For the <u>**HOME**</u> sized problem: There starts to be a pile of compelling reasons in favor of connecting the physical storage to the main CPU horsepower over the highest bandwidth possible 

Pertinent specs: 

  * MB/s = MegaBytes per second, Mbit/s & Mb/s = MegaBits per sec, GbE = GigaBit Ethernet, Gb/s = GigaBits per sec 
  * Notable NAS vendors: <a href="https://www.synology.com/enu/products/index.php" target="_blank">Synology</a>, <a href="https://www.qnap.com/Products.asp" target="_blank">QNap</a>… <a href="https://buffalotech.com/products/network-storage/" target="_blank">Buffalo</a>, <a href="https://www.lacie.com/us/products/range.htm?id=10007" target="_blank">LaCie</a>… <a href="https://h18006.www1.hp.com/storage/nas/index.html" target="_blank">HP</a>, <a href="https://us.acer.com/acer/seu26e.do?link=ln107e&ctx2.c2att1=0&ctx1.att21k=1&CountryISOCtxParam=US&kcond48e.c2att101=-1&kcond37e.c2att92=164&sp=page17e&ctx1g.c2att92=164&LanguageISOCtxParam=en&CRC=2719346131" target="_blank">Acer</a>, <a href="https://event.asus.com/server/tsmini" target="_blank">Asus</a>… <a href="https://www.netgear.com/products/home/storage/default.aspx" target="_blank">NetGear</a>, <a href="https://www.cisco.com/cisco/web/solutions/small_business/products/storage/index.html" target="_blank">Cisco</a>, <a href="https://us.zyxel.com/Products/details.aspx?PC1IndexFlag=20050125090459&L2=20060726153111&L3=20060726153118&CategoryGroupNo=0B6ADF90-564F-4A64-A5B3-2DBA424D6326" target="_blank">ZyXEL</a> 
  * <a href="https://www.smallnetbuilder.com/nas/nas-reviews/31022-hp-storageworks-data-vault-x510-reviewed?start=2" target="_blank">Performance rundown of many popular NAS boxes</a> 
      * RAID0 based units hold the crown – and nothing tops out much over 100MB/s read or write 
      * Didn't realize the Qnap's were kicking so much arse 
      * The NetGear seems to be the champ but she's pricey (see my note about their X-RAID technology below under Holy Grail) 
  * HD Video Streaming, minimum required bandwidth: in the ballpark of <10MB/s (per client) 
      * <a href="https://en.wikipedia.org/wiki/Blu-ray_Disc" target="_blank">Blu-ray spec</a> max data transfer rate = 54 Mbit/s (~7 MB/s) 
      * HD DVD spec max data transfer rate = 36 Mbit/s 

<div style="margin-top: 20px; margin-bottom: 3px">
  The Holy Grail (at the raw storage level):
</div>

  1. Single Volume - a single logical storage pool 
  2. Redundancy - at least single drive failure redundancy (with RAID 5 style efficiency) 
  3. Different Size Drives – we all want to take advantage of the biggest/cheapest drive available from one year to the next 



<div>
  These are the only options I'm currently aware of:
</div>

  * <a href="https://www.drobo.com/" target="_blank">Drobo</a> 
  * Windows Home Server 
  * NeatGear has something called <a href="https://www.readynas.com/?p=656" target="_blank">X-RAID2</a> in their ReadyNAS line that looks pretty good as well… <a href="https://www.google.com/products/catalog?q=netgear+readynas+Pro+X-RAID2&hl=en&cid=17325155851262376306&ei=v9OXTKvYFZnWiwTi_sSdCw&sa=button&ved=0CA4QgggwATgA#p" target="_blank">6 bay Pro model (<u>empty</u>) = $1000 street <yikes></a> 
  * <a href="https://en.wikipedia.org/wiki/ZFS" target="_blank">zFS</a> - Solaris only…various OpenSolaris based versions out there… people do run it under a Windows VM with some success but seems clunky 

<div style="margin-top: 20px; margin-bottom: 3px">
  <a href="https://www.drobo.com/" target="_blank"><u>Drobo</u></a>
</div>

  * <a href="https://datarobotics.com/resources/beyondraid.php" target="_blank">BeyondRAID</a> is like RAID 5 **striping & redundancy** yet with the freedom of <u>on-the-fly swapping</u> of <u>any drive size</u> 
  * Pre-emptive, automatic self healing 
  * Tool-less, Tray-less HDD slots 
  * Sexy Health lights 
  * OS X TimeMachine compatible 
  * Downsides: 
      * - a bit pricey (5 bay, eSata "Drobo S" = <a href="https://www.google.com/products/catalog?q=drobo+s&cid=4867300101378647121&ei=HVSXTKq2IJSy-gbB4vivDQ&sa=button&ved=0CAkQgggwADgA#scoring=p" target="_blank">~$700</a> empty!) … i feel like they're charging about $100-$200 over average hardware for their secret sauce 
      * - unfortunately it's run of the mill speedy (60-90 MB/s over eSATA)… too bad we can't justify the cost with some extra performance 
      * - unavoidably it's running a proprietary format in order to work its magic … the million dollar questions is: What is Drobo's track record now that they've been out there a while??  Definitely need to dig up some solid reliability satistics…  If it ever does totally puke on you, you'd have to wait for a replacement unit to drop in your drives and see what's still there… and after that, only Data Robotics Inc can possibly save you and it'll cost you. 
      * but is this really any different than RAID5?  RAID is pretty much the same vendor specific lock-in isn't it??… if your RAID controller up and dies (for me that'd be my mobo 😐 … you'd have to obtain nearly identical duplicate hardware to salvage your drives… <a href="https://www.tomshardware.com/reviews/RAID-MIGRATION-ADVENTURE,1640.html" target="_blank">apparently you can migrate across same vendor like ICH9R –> ICH10R which does give slightly more flexibility</a> 

<div style="margin-top: 20px; margin-bottom: 3px">
  <u>Windows Home Server</u>
</div>

  * <a href="https://www.wegotserved.com/2010/05/09/how-to-install-php-on-windows-home-server-vail/" target="_blank">You can install PHP</a> 
  * <a href="https://www.edbott.com/weblog/2008/07/running-windows-home-server-in-a-virtual-machine/" target="_blank">It does run fine in a VM</a> 
  * OS X TimeMachine compatible 
  * - When you add a drive you must designate it as either Storage or Backup (the Storage pool offers no redundancy) 
  * - Obnoxious – there's something whacky about how it <a href="https://hardforum.com/showthread.php?t=1376478&page=2" target="_blank">does not balance allocation very well across available drives</a> 
  * <a href="https://connect.microsoft.com/WindowsHomeServer" target="_blank">WHS "v2" aka "Vail"</a> due sometime 2010 (V2 is Windows 2008 based, V1 is Windows 2003 based) 
  * Great <a href="https://www.anandtech.com/show/3677/windows-home-server-v2-vail-beta-drive-extender-v2-dissected" target="_blank">AnandTech.com dissection</a> 
      * v1 was basically a fancy _tack-on_ above NTFS - "_Drive Extender was the biggest component of the secret sauce that made WHS unique from any other Microsoft OS. It was Drive Extender that abstracted the individual hard drives from the user so that the OS could present a single storage pool, and it was Drive Extender that enabled RAID-1 like file duplication on WHS v1. Drive Extender was also the most problematic component of WHS v1 however: it had to be partially rewritten for WHS Power Pack 1 after it was discovered that Drive Extender was leading to file corruption under certain situations._" 
      * v2 Drive Extender is now 'below' NTFS… proprietary block based storage… single file can/will be spread across multiple disks ("chunking") 
          * biggest downside is that you can no longer just plop a WHS drive in another server to pull files in an emergency 
          * chunking means that you're in a more RAID0 like risk category for your main storage 
          * enables backup of open files… to me, Drive Extender v2 provides similar freedoms to what <a href="https://en.wikipedia.org/wiki/Shadow_Copy" target="_blank">Volume Shadow Copy</a> provides us elsewhere 
      * Great stuff in the many comments: 
          * This comment basically sums up my WHS vs Drobo question => [<a>RE: Almost there</a> by <a>davepermen</a> on _Wednesday, April 28, 2010, on comment page 2]_ – "_in storage-loss for the security, raid5 is superior. if all your data is in duplication mode on whs, it needs 2x the storage space. raid5 needs "one additional disk"._" … so Drobo is more like WHS flexibility + RAID5 reliability… so they really are the only game in town and hence the price. 
  * Generally accepted as a solid WHS implementation: <a href="https://www.google.com/products/catalog?q=HP+Storage+Works+x510&oe=utf-8&client=firefox-a&cid=9030227221152944036&ei=_82XTIWvOJPijASNnb2bCw&sa=button&ved=0CBkQgggwATgA&os=tech-specs" target="_blank">HP Storage Works x510</a> (rebranded MediaSmart EX495) 
      * <a href="https://www.google.com/products/catalog?q=HP+Storage+Works+x510&oe=utf-8&client=firefox-a&hl=en&cid=9030227221152944036&ei=Vs2XTJPvMJi4iwTI672fCw&sa=button&ved=0CBkQgggwATgA#p" target="_blank">2TB config = $700 street</a> 
      * <a href="https://www.mediasmartserver.net/2009/10/06/review-hp-storageworks-x510-data-vault/" target="_blank">Good review</a> 
      * <a href="https://www.smallnetbuilder.com/nas/nas-reviews/31022-hp-storageworks-data-vault-x510-reviewed?start=2" target="_blank">Very good burst speeds, 80-90MB/s average read/write</a> 

<a name="PogoPlug"></a>   
Links: 

  * <https://www.smallnetbuilder.com/nas/nas-charts/view>