function mask = maskSky(img, headerlns)
% Experimental function for masking out the sky in 
% PhenoCam images. Seems to work very well, but needs
% more testing.

    gray = rgb2gray(img);
    mask = ones(size(gray));
    
    %Not sure how all of this works yet...but its pretty reliable lolol
    se = strel('disk', 20);
    Ie = imerode(gray, se);
    Iobr = imreconstruct(Ie, gray);
    Iobrd = imdilate(Iobr, se);
    Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
    Iobrcbr = imcomplement(Iobrcbr);
    bw = im2bw(Iobrcbr, graythresh(Iobrcbr));
   
    %remove sky from image
    mask = bw;
    if headerlns > 0
        mask(1:28*headerlns,:) = 1;
    end
    %Can't get connected components to work....??? 
    % do this method for now. May not work for all sites......
    mask = ~mask;
    %CC = bwconncomp(mask);
    %mask(CC.PixelIdxList{1}) = 0;
end
