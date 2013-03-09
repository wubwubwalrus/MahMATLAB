function img_out = CornerDetect(img_in)

%img_in is a color img
[row,col,~] = size(img_in);
gray=zeros(row,col);
for i=1:row
    for j=1:col
        gray(i,j)=(img_in(i,j,1)+img_in(i,j,2)+img_in(i,j,3))/3;
    end
end

edges=double(edge(gray)).*256;
myfilter = fspecial('gaussian',[row col], row/3);
myfilter = myfilter.*(1/max(max(myfilter)));
%imshow(myfilter)
img_out = edges.*myfilter;
se = strel('disk',5);
img_out = imclose(img_out, se);
%for i=1:row
%    for j=1:col
%        if img_out(i,j)<128
%            img_out(i,j)=0;
%        else
%            img_out(i,j)=256;
%        end
%    end
%end


figure
imshow(img_out, [0 256])
end

