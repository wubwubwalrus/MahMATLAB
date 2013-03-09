function [img_out, meters] = GetMapOfBuilding(points, comments)

%points are the verticies of the mesh stored in a #pointsx3 matrix
%comments(1,1): bbox_offset in utm
%comments(1,2): geo_offset in lat long
%comments(1,3): zone information

%img_out stored the generated map
%meters(1) is length in x dim covered by map in meters
%meters(2) is length in y dim covered by map in meters

meters = zeros(1,2);
margin_of_err = 20; %about how much you think the geoposition will be off (meters)

b_minX = min(points(:,1));
b_minY = min(points(:,2));
b_maxX = max(points(:,1));
b_maxY = max(points(:,2));

b_xlength = b_maxX-b_minX;
b_ylength = b_maxY-b_minY;

temp = regexp(comments(1,1),'(\s)','split');
temp = [temp{:}];
easting = str2double(temp{1,2});
northing = str2double(temp{1,3});
temp = regexp(comments(1,3),'(\s)','split');
temp = [temp{:}];
zone = strcat(temp{1,4}, ' N');

northing1 = northing+(b_ylength/2)+margin_of_err;
easting1 = easting-(b_xlength/2)-margin_of_err;
northing2 = northing-(b_ylength/2)-margin_of_err;
easting2 = easting+(b_xlength/2)+margin_of_err;

[lat1,long1] = utm2deg(easting1,northing1,zone);
[lat2,long2] = utm2deg(easting2,northing2,zone);

img_out = AerialComposite.GenerateMap(lat1, long1, lat2, long2);
meters(1) = easting2-easting1;
meters(2) = northing1-northing2;

end

