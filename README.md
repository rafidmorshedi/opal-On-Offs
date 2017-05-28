# Opal Train Tap On Tap of Visualisation

## Description
Code used to genareate a video of [Opal Tap On / Tap Off data](https://opendata.transport.nsw.gov.au/dataset/opal-tap-on-and-tap-off) from TfNSW's Open Data Hub.

The video can be found [here](https://www.youtube.com/watch?v=XCnU7nuON68).

It is inspired by a [similar video](https://www.youtube.com/watch?v=QQV3UHsZ_u4) by Oliver O'brien.

## The code
The frames are created using the [R](https://www.rstudio.com/) script. Then the individual png files are brought together using [ffmpeg](https://ffmpeg.org/) which is what the batch file does. If using windows you need to make sure ffmpeg is on the PATH.

[TO DO] More detailed instructions on usage

## Data Sources
Map tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, under <a href="http://www.openstreetmap.org/copyright">ODbL</a>.

Opal Data from [Transport for NSW](https://opendata.transport.nsw.gov.au/dataset/opal-tap-on-and-tap-off), under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
