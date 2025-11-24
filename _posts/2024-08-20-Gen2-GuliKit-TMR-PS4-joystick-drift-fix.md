---
title: "Gen2 GuliKit TMR PS4 joystick drift fix"
date: 2024-08-20
type: post
author: Beej
tags:
  - Hardware
thumbnail-img: /images/uploads/2024/GuliKit-TMR-1.png
---

Bottom line up front, just like other reviewers have said, my controller went from REAL BAD jitter on the right stick to absolute ZERO drift, pegging very very close to center w/o any tuning... super happy with the result!

([posted here](https://www.amazon.com/gp/customer-reviews/R8FIYBK1X56SJ/ref=cm_cr_dp_d_rvw_ttl?ie=UTF8&ASIN=B0D9Q16NJX))

I bricked two!! other PS5 controllers a few months back attempting to install the older yellow hall effect sticks, really painful learning?? experience =( Recently stumbled on a very positive YT review of these new TMR GuliKits over the previous gen and gathered the courage to try again.

If you have the gusto to dive in and pull this off, my hat is truly off to you. I found the whole process very very nerve racking.... my tips:
+ Be SUPER careful with the two ribbon cables... fairly easy to get out, but incredibly prone to breaking during re-INSERTION.
+ if you haven't soldered (much) before, please watch some general videos, especially on modern "surface mount" "PCB"
+ FLUX!! definitely use - i had no idea how helpful and important this is for getting clean solder joints in general... seriously, don't skip this... i started with the MG Chemicals 8341 10ml syringe and it's been great... and we can then just get the 50ml jar for refilling the syringe
  + have some isopropyl alcohol and q-tips on hand to CLEAN OFF the flux... supposedly flux can be a mild conductor, not good to leave on and besides it typically gets a bit burned and alcohol makes everything look nice after
+ Get yourself a decent soldering iron... i've since discovered the "FNIRSI" irons which are little more $ but very sleek looking > [tom's hardware](https://www.tomshardware.com/maker-stem/fnirsi-hs-02-review) recommends the [HS-02A](https://www.amazon.com/gp/product/B0DBLMH1HS) vs B due to more tips
  + prior to finding the FNIRSI i got the the WEP 926D iron station which was has very decent for me in that $50 range
+ Based on videos & my own experience, go with the "knife blade" shaped soldering tip or conical bevel (images below)... tom's favorite is the conical and i'll have to give that a try next time around
+ Doing some quick searching, 300 CELSIUS seems like a good safe starting point for typical lead solder
+ Get a decent desoldering sucker iron! ... the joysticks have 14!! connections to get all the solder removed so that you can a) remove the old one and b) cleanly insert the new one... having a heated sucker this time around really improved my odds of not melting other stuff like past attempts with a "hot air rework station" (bad investment in my opinion). I just got the economy priced orange "KeenWise" sucker and I can attest, it does a decent job, sometimes requiring a few shots to get a joint fully cleared. I wasn't quite ready to invest the $100+ in a more upscale "948" unit. Maybe the "929" would be good too.
+ Be very careful not to put too much heat on anything for too long, both de-soldering and soldering... i've definitely irreparably killed stuff just in the desoldering step and i have to assume it's due to heat
+ Make sure you find the right iFixIt teardown for your exact controller MODEL #... the controller guts change just enough over time.

![image1]({{ site.baseurl }}/images/uploads/2024/GuliKit-TMR-1.png)
![image2]({{ site.baseurl }}/images/uploads/2024/GuliKit-TMR-2.png)

![image](https://github.com/user-attachments/assets/aecb14d7-ac0f-462b-a5f6-767f4a219186)
![image](https://github.com/user-attachments/assets/8d2fe80f-d6a8-41c9-842b-f6ef930b897f)
