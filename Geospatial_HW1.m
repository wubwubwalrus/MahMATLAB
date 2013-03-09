%request input script
lat1 = input('Enter Lat1: ');
lon1 = input('Enter Lon1: ');
lat2 = input('Enter Lat2: ');
lon2 = input('Enter Lon2: ');

imshow(AerialComposite.GenerateMap(lat1, lon1, lat2, lon2))