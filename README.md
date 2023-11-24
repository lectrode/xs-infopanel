# xs-infopanel

This is a conky config based on / inspired by [Minimalis Conky](https://www.gnome-look.org/p/1112273) and [Infopanel](https://www.gnome-look.org/p/1006397)



## No required tweaking to get up and running

This config has scripts to automatically/dynamically detect the following:
* Number of CPU Cores
* Mounted storage partitions (deduped)
* Available network adapters
* External IP
  * last value cached to avoid spamming requests
  * only checks once every 24 hours or if all local IP addresses change



