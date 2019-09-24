## Test environments
* GNU
  * local machine 
  * Ubuntu 19.04 "disco"
  * R version 3.6.1 (2019-07-05)
* GNU
  * Travis CI
  * Ubuntu 16.04.6 LTS "xenial"
  * R versions:
    * oldrel R version 3.5.3 (2017-01-27) 
    * release R version 3.6.1 (2017-01-27)
    * devel R Under development (unstable) (2019-09-19 r77195)
* Windows
  * AppVeyor CI
  * Windows Server 2012 R2 x64 (build 9600)
  * Platform: x86_64-w64-mingw32/x64 (64-bit)
  * R version 3.6.1 Patched (2019-09-14 r77193)

## R CMD check results

0 errors | 0 warnings | 2 notes

* This is a new release.
* "Package has help file(s) containing install/render-stage `\Sexpr{}`
  expressions but no prebuilt PDF manual."
  * Lifecycle badges on function help come out OK when installed, and fall back
    to text if not rendered.
  * PDF version of manual added but not picked up by CMD CHECK.
* "installed size is  5.5Mb, sub-directories of 1Mb or more: doc 4.6Mb":
  * The vignette "odata" contains a leaflet map with popups showing embedded
    photos, a highly sought after use case.
    The third party dependencies, especially leaflet-awesomemarkers (for map 
    popups), cost over 3MB. 
  * The other vignette "api" refers to the map in vignette "odata" as not to 
    duplicate the expensive map.
  * The example images have been resized aggressively to 200x150 px.
  * Included images for branding and attribution are at lowest legible size.
  