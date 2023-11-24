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

## Screenshot
![screenshot of v2.0.0](https://github.com/lectrode/xs-infopanel/blob/main/screenshots/v2.0.0.png?raw=true "v2.0.0")

## Additional features
* Bars and text change colors (white, yellow, red) based on usage
  * cpu:     yellow (more than 85%), red (more than 90%)
  * temp:    yellow (more than 70%), red (more than 85%)
  * storage: yellow (more than 75%), red (more than 90%)
* New network connection appears aqua until it has been cached
  * (wait until cached before disconnecting previous connection to avoid re-checking external ip)
  * (useful when switching between wired and wireless)

## Requirements
* Tested on conky version 1.14.0+
* Lua *not* required


## Usage
* Run `xs-infopanel.sh` or execute the included desktop file


