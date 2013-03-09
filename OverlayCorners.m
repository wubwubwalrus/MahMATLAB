function [img_out] = OverlayCorners(img_in, meters, points, faces, shift)

%img_in is map containing building
%meters contain x and y dim of meters covered by map
%points contain corners of building mesh

[y_pix, x_pix, ~] = size(img_in);
[num_faces, ~] = size(faces);
ppm = x_pix/meters(1);
shiftx=shift(1)*x_pix/2;
shifty=shift(2)*y_pix/2;


points(:,1)=floor(x_pix/2+points(:,1)*ppm)+shiftx;
points(:,2)=floor(y_pix/2-points(:,2)*ppm)+shifty;
figure, imshow(img_in)
hold on
for i=1:num_faces
    plot([points(faces(i,1),1), points(faces(i,2),1), points(faces(i,3),1)],[points(faces(i,1),2), points(faces(i,2),2), points(faces(i,3),2)],'Color','r','LineWidth',2)
end
print(gcf,'-dbmp', 'overlay.bmp')
img_out = imread('overlay.bmp', 'bmp');
hold off


end