function shift = GenerateShiftVector(img_in, meters, points, faces)

[y_pix, x_pix, ~] = size(img_in);
[num_faces, ~] = size(faces);
ppm = x_pix/meters(1);
corners=zeros(y_pix, x_pix);
points(:,1)=floor(x_pix/2+points(:,1)*ppm);
points(:,2)=floor(y_pix/2-points(:,2)*ppm);

figure, imshow(corners)
hold on
for i=1:num_faces
    plot([points(faces(i,1),1), points(faces(i,2),1), points(faces(i,3),1)],[points(faces(i,1),2), points(faces(i,2),2), points(faces(i,3),2)],'Color','r','LineWidth',2)
end

f=getframe;
hold off
close
[im,map] = frame2im(f);    %Return associated image data 
if isempty(map)            %Truecolor system
  mesh = im;
else                       %Indexed system
  mesh = ind2rgb(im,map);   %Convert image data
end

figure, imshow(img_in)
hold on
f=getframe;
hold off
close
[im,map] = frame2im(f);    %Return associated image data 
if isempty(map)            %Truecolor system
  map = im;
else                       %Indexed system
  map = ind2rgb(im,map);   %Convert image data
end

%now that have two images, edge detect and compare!
mesh_edge = double(edge(rgb2gray(mesh)));
map_edge = double(edge(rgb2gray(map)));

%[mey, mex] = size(mesh_edge);
[may, mapx] = size(map_edge);

%apply a gaussian to lower the matches of the stuff around the building
myfilter = fspecial('gaussian',[may mapx], may/3.5);
myfilter = myfilter.*(1/max(max(myfilter)));

map_edge=myfilter.*map_edge;

% figure, imshow(map_edge)
% figure, imshow(mesh_edge)

results = xcorr2(mesh_edge, map_edge);
maxc = max(max(results));
[row col] = find(results==maxc);
row=-(row-may);
col=col-mapx;
shiftx = col/(mapx/2);
shifty = row/(mapx/2);
shift = [shiftx shifty];

end