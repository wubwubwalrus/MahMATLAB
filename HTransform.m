function [img_out mappedspace]= HTransform(img_in)
% takes in a grayscale image, does edge detection, and uses a hough transform to try
% to find the lines in the images. Then it outputs the same image with the
% lines superimposed on it.
[height, width] = size(img_in);
edges = edge(img_in);

% set up the space to map to
tquant = .05;
pquant = 5;

thets = -pi/2:tquant:((pi/2)-tquant);
ps = -sqrt(height^2 + width^2):pquant:sqrt(height^2 + width^2);

mappedspace = zeros(length(thets),length(ps));
timax = length(thets);
for h = 1:height
    for w = 1:width
        if edges(h,w)
            for ti = 1:timax
                thet = thets(ti);
                p = w*cos(thet) + h*sin(thet);
                pind = find(hist(p,ps)==1);
                mappedspace(ti,pind) = mappedspace(ti,pind) + 1;
            end
        end
    end
end

img_out = img_in;
mappedspace = uint8(mappedspace*255/max(max(mappedspace)));
thresh = findThresh(mappedspace,.995);
for ti = 1:timax
    for pind = 1:length(ps)
        if (mappedspace(ti,pind)>thresh) && isLocalMax(mappedspace,ti,pind)
            for h = 1:height
                w = (ps(pind) - h*sin(thets(ti)))/cos(thets(ti));
                w = round(w);
                if (w>0)&&(w<=width)
                    img_out(h,w) = 255;
                end
            end
            for w = 1:width
                h = (ps(pind) - w*cos(thets(ti)))/sin(thets(ti));
                h = round(h);
                if (h>0)&&(h<=height)
                    img_out(h,w) = 255;
                end
            end
        end
    end
end
end

function thresh = findThresh(img_in,percent)
[height, width] = size(img_in);
limit = height*width*percent;
h = imhist(img_in);
sum = 0;
threshindex = 0;
while (sum < limit)
    threshindex = threshindex + 1;
    sum = sum + h(threshindex);
end
thresh = threshindex - 1;
end

function state = isLocalMax(img_in, hpos, wpos)
[height, width] = size(img_in);
state = true;
spread = 13;
for h = -spread:spread
    for w = -spread:spread
        hnew = h + hpos;
        wnew = w + wpos;
        if (hnew > 0) && (hnew <= height) && (wnew > 0) && (wnew <= width)
            if (img_in(hpos,wpos)==img_in(hnew, wnew))&&(hnew<hpos)&&(wnew<wpos)
                state = false;
            else
                state = state && (img_in(hpos, wpos) >= img_in(hnew, wnew));
            end
        end
    end
end
end