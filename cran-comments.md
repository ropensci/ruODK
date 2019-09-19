## Test environments
* local Ubuntu 19.10 install, R 3.6.1
* ubuntu 14.04 (on travis-ci), R 3.6.1 (oldrel, release, devel)
* win-builder (release)

## R CMD check results

0 errors | 0 warnings | 2 notes

* This is a new release.
* "installed size is  5.0Mb, sub-directories of 1Mb or more: doc 4.4Mb":
  The vignette "odata" contains a leaflet map with popups showing embedded
  photos, a highly sought after use case.
  The third party dependencies, especially leaflet-awesomemarker, cost over 3MB. 
  The example images have been resized aggressively to 200x150 px.
  The other vignette "api" refers to the map in vignette "odata" as not to 
  duplicate the expensive map.
