classdef AerialComposite
    
   properties (Constant)
      LinkPrefix = 'http://ecn.t3.tiles.virtualearth.net/tiles/a';
      LinkSuffix = '.bmp?g=1';
   end
   
   methods (Static)
       %go get the tile
       function tile = DownloadTile(quadKey)
           url = [AerialComposite.LinkPrefix quadKey AerialComposite.LinkSuffix];
           tile = imread(url);
       end
       
       function valid = ValidTile(quadKey)
           tile = AerialComposite.DownloadTile(quadKey);
           %the resolution not avaliable image has a max intensity of 7.
           %therefore, if it only has max of 8 or less, then it is not a
           %valid image.
           if max(max(max(tile)))<8
               valid = false;
           else
               valid = true;
           end
       end
       
       function contains = ContainsTile(latitude1, longitude1, latitude2, longitude2, quadKey)
           %is the tile in the bounding box??
           [tileX, tileY, levelOfDetail] = TileSystem.QuadKeyToTileXY(quadKey);
           [pixelX1, pixelY1] = TileSystem.LatLongToPixelXY(latitude1, longitude1, levelOfDetail);
           [tileX1, tileY1] = TileSystem.PixelXYToTileXY(pixelX1,pixelY1);
           [pixelX2, pixelY2] = TileSystem.LatLongToPixelXY(latitude2, longitude2, levelOfDetail);
           [tileX2, tileY2] = TileSystem.PixelXYToTileXY(pixelX2,pixelY2);
           contains = (tileX1 <= tileX2 && tileX <= tileX2) && (tileY1 <= tileY && tileY <= tileY2);
       end
       
       function levelOfDetail = MaxLevelOfDetail(latitude1, longitude1, latitude2, longitude2)
           %check for highest level of detail
           levelOfDetail = 24;
           valid = false;
           while ~valid
               levelOfDetail = levelOfDetail-1;
               [pixelX1, pixelY1] = TileSystem.LatLongToPixelXY(latitude1, longitude1, levelOfDetail);
               [pixelX2, pixelY2] = TileSystem.LatLongToPixelXY(latitude2, longitude2, levelOfDetail);
               [tileX1, tileY1] = TileSystem.PixelXYToTileXY(pixelX1, pixelY1);
               [tileX2, tileY2] = TileSystem.PixelXYToTileXY(pixelX2, pixelY2);
               for i=tileX1:tileX2
                   for j=tileY1:tileY2
                       quadKey = TileSystem.TileXYToQuadKey(i,j,levelOfDetail);
                       valid = AerialComposite.ValidTile(quadKey);
                       if ~valid
                           break;
                       end
                   end
                   if ~valid
                       break;
                   end
               end
           end
       end
       
       function composite = MakeComposite(latitude1, longitude1, latitude2, longitude2, levelOfDetail)
           %gets all the tiles, put them together, crop final image.
           [pixelX1, pixelY1] = TileSystem.LatLongToPixelXY(latitude1, longitude1, levelOfDetail);
           [pixelX2, pixelY2] = TileSystem.LatLongToPixelXY(latitude2, longitude2, levelOfDetail);
           [tileX1, tileY1] = TileSystem.PixelXYToTileXY(pixelX1, pixelY1);
           [tileX2, tileY2] = TileSystem.PixelXYToTileXY(pixelX2, pixelY2);
           
           composite = [];
           for i = tileX1:tileX2
               col = [];
               for j = tileY1:tileY2
                   quadKey = TileSystem.TileXYToQuadKey(i,j,levelOfDetail);
                   tile = AerialComposite.DownloadTile(quadKey);
                   col = cat(1, col, tile);
               end
               composite = cat(2, composite, col);
           end
           ix=mod(pixelX1, 256);
           iy=mod(pixelY1, 256);
           iwidth=mod(pixelX2,256)+(tileX2-tileX1)*256-ix;
           iheight=mod(pixelY2,256)+(tileY2-tileY1)*256-iy;
           composite=imcrop(composite, [ix iy iwidth iheight]);
               
       end
       
       function img_out = HistoEq(img_in)
           %histogram equalization!
           img_hsv = rgb2hsv(img_in);
           value = adapthisteq(img_hsv(:,:,3));
           img_hsv = cat(3, img_hsv(:,:,1:2), value);
           img_out = hsv2rgb(img_hsv);
       end
       
       function img_out = WhiteBalance(img_in)
            img_out = cat(3,imadjust(img_in(:,:,1)),imadjust(img_in(:,:,2)),...
                imadjust(img_in(:,:,3)));
       end
       
       function final = GenerateMap(latitude1, longitude1, latitude2, longitude2)
           %generates final image with histogram equalization and white
           %balance.
           levelOfDetail = AerialComposite.MaxLevelOfDetail(latitude1, longitude1, latitude2, longitude2);
           final = AerialComposite.MakeComposite(latitude1, longitude1, latitude2, longitude2, levelOfDetail);
           %final = AerialComposite.HistoEq(final);
           %final = AerialComposite.WhiteBalance(final);
       end
       
   end
    
end