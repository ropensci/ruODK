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

```
❯ checking CRAN incoming feasibility ... NOTE
  Maintainer: ‘Florian W. Mayer <Florian.Mayer@dbca.wa.gov.au>’
  
  New submission
  
  Version contains large components (0.6.6.9000)
  
  Package has help file(s) containing install/render-stage \Sexpr{} expressions but no prebuilt PDF manual.
  
  Size of tarball: 56390108 bytes

❯ checking installed package size ... NOTE
    installed size is  5.2Mb
    sub-directories of 1Mb or more:
      doc   4.5Mb
```      
      
* This is a new release.
* Version: currently a development version, will be incremented across ruODK
  features (patch), and kept in line with ODK Central versions (major and minor).
* Package help contains `\Sexpr{}`. PDF of manual can be included on request, 
  but currently not included as per advice from ROpenSci.
* Installation size:
  * The vignette "odata" contains a leaflet map with popups showing embedded
    photos, a highly sought after use case.
    The third party dependencies, especially leaflet-awesomemarkers (for map 
    popups), cost over 3MB. 
  * The other vignette "api" refers to the map in vignette "odata" as not to 
    duplicate the expensive map.
  * The example images have been resized aggressively to 200x150 px.
  * Included images for branding and attribution are at lowest legible size.
  