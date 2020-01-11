# BC_Docker_Containers
BC Docker Containers

republished from waldo

List all Business Central Docker Image Tags on Microsoft Container Services

By waldo in MS Dynamics NAVJanuary 18, 2019

A while ago, I blogged about how you can get to all the tags on Docker Hub, for all images of Microsoft Dynamics NAV. This was more useful than I ever imagined, as many people referred to it, or I had to refer to it for others. In any case, for us “simple” NAV “dinosaurs”, these docker tags doesn’t always seem to be easy to “assemble”, so getting a list of all of them, is sometimes nice to get to the very specific one that one might need – or just to get an idea of what else is out there (or better yet “in there”).

Here you can find that blogpost: List all NAV Docker Image Tags on Docker Hub

Important word in that title: “Docker Hub”.

Not too long ago, Freddy introduced images on “Azure Container Registry”, “Microsoft syndicates container catalog”, “Microsoft Container Registry” or however you want to call “mcr.microsoft.com” 😉 – which makes very much sense (just think “Azure Container Service” in the future) – by creating repos like:

mcr.microsoft.com/businesscentral/onprem
mcr.microsoft.com/businesscentral/bcsandbox
Thing was, I was not able to get to a list of tags for those repos. So regarding tags, it was back to square one: figuring it out the tags by trial and error (at least, that’s what I did ;-)).

Until today. I saw a tweet from Tobias Fenster, who announced that Microsoft now supports the so-called “Hub Catalog API” (whatever that is, but it sounds good). Back in business! And we don’t even need PowerShell for this … these URLs get you straight to a JSON with all the tags:

https://mcr.microsoft.com/v2/businesscentral/sandbox/tags/list
https://mcr.microsoft.com/v2/businesscentral/onprem/tags/list

Then again – I wouldn’t be waldo if I didn’t put this in some kind of PowerShell script, which you can find here. Nothing too fancy, but an easy ability to filter, search, loop, … through the image tags. If you want to loop through all the tags to download them all – go nuts! ;-).

This made me think though – what is actually the current overview of all docker repos (regarding Dynamics NAV and Business Central) that Freddy makes available for us ? I might put this in a next post ;-).  For now – have a nice weekend!
