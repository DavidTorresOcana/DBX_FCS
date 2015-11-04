C:
cd C:\Program Files\FlightGear

SET FG_ROOT=C:\Program Files\FlightGear\\data
.\\bin\\win64\\fgfs --aircraft=Aerosonde --fdm=network,localhost,5501,5502,5503 --disable-clouds  --on-ground --enable-freeze --altitude=610 --lat=40.463650 --lon=-3.554389 --heading=0 --airport=LEMD --runway=33L  --offset-distance=0.72 --offset-azimuth=0
