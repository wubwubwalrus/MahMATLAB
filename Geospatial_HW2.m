filename = input('Enter name of ply file: ', 's');
[v,f,com] = read_ply(filename);
[map, meters] = GetMapOfBuilding(v,com);
shift = GenerateShiftVector(map, meters, v, f);
img_out = OverlayCorners(map, meters, v, f, shift);