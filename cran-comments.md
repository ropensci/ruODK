## Test environments
* Local machine
  * Ubuntu 19.10 "eoan"
  * R version 4.0.0 (2020-04-24)
* Travis CI
  * Ubuntu 16.04.6 LTS "xenial"
  * R versions:
    * oldrel
    * release
    * devel
* AppVeyor CI
  * Windows Server 2012 R2 x64 (build 9600)
  * Platform: x86_64-w64-mingw32/x64 (64-bit)
  * R version 3.6.1 Patched (2019-09-14 r77193)
* GitHub Actions
  * Windows-latest (Windows Server 2019) with R devel, release, oldrel
  * Windows Server 2016 with R devel, release, oldrel
  * MacOS-lastest (MacOS Catalina 10.05)  with R devel, release, oldrel
  * Ubuntu latest (Ubuntu 18.04)  with R release, oldrel (devel fails setup)
  * Ubuntu 20.04  with R release, oldrel coming once supported

## R CMD check results

0 errors | 0 warnings | 2 notes

```
❯ checking CRAN incoming feasibility ... NOTE
  Maintainer: ‘Florian W. Mayer <Florian.Mayer@dbca.wa.gov.au>’
  
  New submission
  
  Version contains large components (0.6.6.9025)
  
  Package has help file(s) containing install/render-stage \Sexpr{} expressions but no prebuilt PDF manual.
  
  Size of tarball: 11927761 bytes

> checking installed package size ... NOTE
    installed size is  6.6Mb
    sub-directories of 1Mb or more:
      doc    4.2Mb
      help   1.9Mb
```      
      
* This is a new release.
* Version note about large components: 
  v 0.6.6.0* is the development version, will be incremented across ruODK
  features (patch), and kept in line with ODK Central versions (major and 
  minor).
* Package help contains `\Sexpr{}` which causes R CMD CHECK warnings. 
* Possibly invalid URLs:
  * The package comparison section in the README contains Markdown badges with 
    CRAN links to packages that are not yet or not any more on CRAN. These
    links are correct, and while they currently do not resolve, they will once
    the packages are (re-)submitted to CRAN.
  * The README contains an ODK Central form OData service URL to illustrate 
    setting up ruODK. The URL redirects to a login screen if followed directly.
    This is expected behaviour.
    
* The PDF version of the manual can be included on request, but is currently 
  not included as per advice from ROpenSci.
* The example data contains UTF-8 strings. This is a realistic scenario. 
  The note has disappeared after the R version 4 release.
* Installation size:
  * The vignette "odata-api" contains a leaflet map with popups showing embedded
    photos, a highly sought after use case.
    The third party dependencies, especially leaflet-awesomemarkers (for map 
    popups), add over 3MB. 
  * The other vignette "restful-api" refers to the map in vignette "odata" as 
    not to duplicate the expensive map.
  * The example images have been resized aggressively to 200x150 px.
  * Included images for branding and attribution are at lowest legible size.
* Test coverage: All functionality supporting the current ODK Central release is 
  covered by tests. 
  The only exception is `form_schema{_parse}`, which supports a breaking 
  change between ODK Central 0.7 and 0.8. The test server runs ODK Central 0.8,
  a production server (used by the package author, but not accessible to other 
  maintainers) runs 0.7 successfully.