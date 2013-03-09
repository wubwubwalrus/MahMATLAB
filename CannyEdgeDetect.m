function img_out = CannyEdgeDetect(img_in)
    img_in = rgb2gray(img_in);
    img_out = GaussSmoothing(img_in, 5, 3);
    figure
    imshow(img_out, [0 255]);
    [M, T] = imgradient(img_in);
    brightest = max(max(M));
    figure
    imshow(M, [0 brightest])
    M = NonmaximaSupress(M,T);
    figure
    imshow(M, [0 brightest])
    [T_low, T_high] = FindThreshold(M, 0.93);
    [low, high] = ApplyThreshold(T_low, T_high, M);
    figure
    imshow(low, [0 brightest])
    figure
    imshow(high, [0 brightest])
    img_out = EdgeLinking(low, high);
    figure
    imshow(img_out, [0 255]);
end

    
function img_out = GaussSmoothing(img_in, n, Sigma)
    r = [1 0;
         0 1];
    h = zeros(n);
    for i=1:n
        for j=1:n
            u=r*[j-(n+1)/2 i-(n+1)/2]';
            h(i,j) = gauss(u(1),Sigma)*gauss(u(2),Sigma);
        end
    end
    h = h/sqrt(sum(sum(h.*h)));
    h = h./sum(h(:));
    
    img_out=uint8(conv2(single(img_in), single(h), 'same'));
         
end

function M = NonmaximaSupress(Mag, Theta)
    [row,col] = size(Mag);
    Theta=round((Theta+180).*(8/360));
    for i=2:row-1
        for j=2:col-1
            if Theta(i,j)==0 || Theta(i,j)==8 || Theta(i,j)==4
                maximum=FindMax(Mag(i,j-1),Mag(i,j),Mag(i,j+1));
                if Mag(i,j-1)<maximum
                    Mag(i,j-1)=0;
                end
                if Mag(i,j)<maximum
                    Mag(i,j)=0;
                end
                if Mag(i,j+1)<maximum
                    Mag(i,j+1)=0;
                end
            elseif Theta(i,j)==1 || Theta(i,j)==5
                maximum=FindMax(Mag(i-1,j+1),Mag(i,j),Mag(i+1,j-1));
                if Mag(i-1,j+1)<maximum
                    Mag(i-1,j+1)=0;
                end
                if Mag(i,j)<maximum
                    Mag(i,j)=0;
                end
                if Mag(i+1,j-1)<maximum
                    Mag(i+1,j-1)=0;
                end
            elseif Theta(i,j)==2 || Theta(i,j)==6 
                maximum=FindMax(Mag(i-1,j),Mag(i,j),Mag(i+1,j));
                if Mag(i-1,j)<maximum
                    Mag(i-1,j)=0;
                end
                if Mag(i,j)<maximum
                    Mag(i,j)=0;
                end
                if Mag(i+1,j)<maximum
                    Mag(i+1,j)=0;
                end
            elseif Theta(i,j)==3 || Theta(i,j)==7
                maximum=FindMax(Mag(i-1,j-1),Mag(i,j),Mag(i+1,j+1));
                if Mag(i-1,j-1)<maximum
                    Mag(i-1,j-1)=0;
                end
                if Mag(i,j)<maximum
                    Mag(i,j)=0;
                end
                if Mag(i+1,j+1)<maximum
                    Mag(i+1,j+1)=0;
                end
            end
        end
    end
    M=Mag;
end

function maximum = FindMax(v1, v2, v3)
    temp = zeros(1,3);
    temp(1)=v1;
    temp(2)=v2;
    temp(3)=v3;
    maximum = max(temp(1,:));
end

function [T_low, T_high] = FindThreshold(Mag, percentageOfNonEdge)
    [row, col]=size(Mag);
    A=row*col;
    H_high=0;
    H_high_target=A*(1-percentageOfNonEdge);
    last_bin=floor(max(max(Mag)))+1;
    histogram=zeros(1,last_bin);
    for i=1:row
        for j=1:col
            histogram(floor(Mag(i,j)+1))=histogram(floor(Mag(i,j)+1))+1;
        end
    end
    index=last_bin;
    while (H_high<H_high_target)
        H_high=H_high+histogram(index);
        index=index-1;
    end
    T_high=index;
    T_low=T_high/2;
end

function [low, high] = ApplyThreshold(T_low, T_high, Mag)
    [row,col]=size(Mag);
    high=Mag;
    low=Mag;
    for i=1:row
        for j=1:col
            if Mag(i,j)<T_low
                low(i,j)=0;
            end
            if Mag(i,j)<T_high
                high(i,j)=0;
            end
        end
    end
end

function E = EdgeLinking(MagLow, MagHigh)
    high_decision = 0;%max(max(MagHigh))*(1/100);
    [row,col]=size(MagLow);
    E=zeros(row,col);
    count=0;
    for i=2:row-1
        for j=2:col-1
            if MagHigh(i,j)>high_decision && E(i,j)==0
                [E,~] = RecurseOnNeighbours(E, MagLow, MagHigh, i, j, high_decision, count);
            end
        end
    end
end

function [E,ncount] = RecurseOnNeighbours(CurrE, low, high, row, col, hd, count)
    ncount=count+1;
    [r,c]=size(CurrE);
    CurrE(row,col)=255;
    endpoint=1;
    for i=1:3
        for j=1:3
            if row-2+i>0 && row-2+i<r+1 && col-2+i>0 && col-2+i<c+1
                if high(row-2+i, col-2+i)>hd && CurrE(row-2+i,col-2+i)==0
                    endpoint=0;
                    [CurrE, ncount] = RecurseOnNeighbours(CurrE, low, high, row-2+i, col-2+i, hd, ncount);
                    ncount= ncount-1;
                end
            end
        end
    end
    %if strong endpoint, check for weak
    if endpoint==1
        CurrWeak=zeros(r,c);
        ld=0;%max(max(low))*(1/1000);
        [E,~,~]=WeakRecurseOnNeighbours(CurrWeak, CurrE, low, high, row, col, ld, hd, ncount);
    else
        E=CurrE;
        return;
    end
end

function [E, W, ncount] = WeakRecurseOnNeighbours(CurrWeak, CurrE, low, high, row, col, ld, hd, count)
    ncount = count+1;
    [r,c]=size(CurrE);
    CurrWeak(row,col)=255;
    for i=1:3
        for j=1:3
            if row-2+i>0 && row-2+i<r+1 && col-2+i>0 && col-2+i<c+1
                if high(row-2+i, col-2+i)>hd && CurrE(row-2+i, col-2+i)==0
                    E=CurrE+CurrWeak;
                    W=CurrWeak;
                    debug='found new strong edge!'
                    return;
                elseif low(row-2+i, col-2+i)>ld && CurrWeak(row-2+i, col-2+i)==0 && CurrE(row-2+i, col-2+i)==0 && ncount<900;
                    %debug='found weak edge, recurse!'
                    [CurrE, CurrWeak, ncount]=WeakRecurseOnNeighbours(CurrWeak, CurrE, low, high, row-2+i, col-2+i, ld, hd, ncount);
                    ncount = ncount-1;
                end
            end
        end
    end
    E=CurrE;
    W=CurrWeak;
    return;
end
   
function y = gauss(x,std)
    y = exp(-x^2/(2*std^2)) / (std*sqrt(2*pi));
end