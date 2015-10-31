C:
cd C:\Program Files\FlightGear

SET FG_ROOT=C:\Program Files\FlightGear\\data
.\\bin\\win64\\fgfs --aircraft=Aerosonde --fdm=network,localhost,5501,5502,5503 --fog-fastest --disable-clouds --start-date-lat=2014:06:06:11:00:00 --in-air --enable-freeze --airport=EGKK --runway=08r --altitude=1123.4 --heading=0 --offset-distance=0.72 --offset-azimuth=0
