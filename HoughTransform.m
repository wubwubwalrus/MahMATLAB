function img_out = HoughTransform(img_in, p_qlvl, theta_qlvl)

    %performs Hough transform to detect lines on img_in and returns in
    %img_out. p_qlvl and theta_qlvl are quantization levels.
    
    img_in=rgb2gray(img_in);
    edges = edge(img_in, 'canny');
    [rows,cols] = size(edges);
    p_pix = round((2*sqrt(rows^2+cols^2))/p_qlvl);
    theta_pix = round(pi/theta_qlvl);
    param = zeros(theta_pix, p_pix);
    
    for i=1:rows
        y=rows+1-i;
        for j=1:cols
            x=j;
            if edges(y,x)>0
                for theta_q=1:theta_pix
                    theta=((theta_q-1)/theta_pix)*pi - (pi/2);
                    p=x*cos(theta)+y*sin(theta);
                    p_q=round((p+sqrt(rows^2+cols^2))/(2*sqrt(rows^2+cols^2))*p_pix);
                    if p_q>0 && p_q<=p_pix
                        param(theta_q, p_q)=param(theta_q, p_q)+1;
                    else
                        error='something is wrong with your math. trolololol.'
                    end
                end
            end
        end
    end
    
    figure
    imshow(param, [0 max(max(param))]);
    se = zeros(floor(theta_pix/30)+1, floor(p_pix/30)+1);
    [intersects, r_vecs, c_vecs] = DetectIntersects(param, se);
    figure
    imshow(intersects, [0 max(max(intersects))]);
    img_out=img_in;
    
    [~,num_intersects] = size(r_vecs);
    for i=1:num_intersects
        theta_q=theta_pix-r_vecs(1,i)+1;
        p_q=c_vecs(1,i);
        theta=((theta_q-1)/theta_pix)*pi - pi/2;
        p=(p_q/p_pix)*(2*sqrt(rows^2+cols^2))-sqrt(rows^2+cols^2);
        for x=1:cols
            y=floor(((p-(x)*cos(theta))/sin(theta)))+1;
            y=rows+1-y;
            if y>0 && y<=rows
                img_out(y,x)=255;
            end
        end
    end
    figure
    imshow(img_out, [0 255]);
end

function [img_out, r_vecs, c_vecs] = DetectIntersects(img_in, se)

    [theta_pix,p_pix] = size(img_in);
    %img_out = zeros(theta_pix, p_pix);
    img_out = img_in;
    [se_row, se_col] = size(se);
    boundry_r = floor(se_row/2);
    boundry_c = floor(se_col/2);
    prev_max = 0;
    threshold = max(max(img_in))/4;
    r_index=1;
    c_index=1;
    r_vecs=zeros(1,100);
    c_vecs=r_vecs;
    
    
    for i=boundry_r+1:theta_pix-boundry_r
        for j=boundry_c+1:p_pix-boundry_c
            if img_in(i,j)>threshold
                %in proximity, search for local max
                newmax=max(max(img_in(i-boundry_r:i+boundry_r, j-boundry_c:j+boundry_c)));
                if newmax~=prev_max
                    [r,c]=find(img_in(i-boundry_r:i+boundry_r, j-boundry_c:j+boundry_c)==newmax,1,'first');
                    %check if r,c is on edge of se
                    if ~(i-boundry_r+r-1==i-boundry_r || i-boundry_r+r-1==i+boundry_r) && ~(j-boundry_c+c-1==j-boundry_c || j-boundry_c+c-1==j+boundry_c)
                        if r_index>100 || c_index>100
                            error='exceeded max # of intersections.'
                        else
                            prev_max=newmax;
                            img_out(i-boundry_r+r-1,j-boundry_c+c-1) = img_out(i-boundry_r+r-1,j-boundry_c+c-1)*(5/3);
                            r_vecs(1, r_index) = i-boundry_r+r-1;
                            c_vecs(1, c_index) = j-boundry_c+c-1;
                            r_index=r_index+1;
                            c_index=c_index+1;
                        end
                    end
                end
            end
        end
    end
    
    [~,num_entries]=size(find(r_vecs));
    r_vecs=r_vecs(1,1:num_entries);
    c_vecs=c_vecs(1,1:num_entries);
    
    
end

