classdef TileSystem
   properties (Constant)
        EarthRadius = 6378137;
        MinLatitude = -85.05112878;
        MaxLatitude = 85.05112878;
        MinLongitude = -180;
        MaxLongitude = 180;
   end
    
   methods (Static)
       function clipped = Clip(n, minValue, maxValue)
           clipped = min(max(n, minValue),maxValue);
       end
       
       function map_width = MapSize(levelofDetail)
           map_width = 256*2.^levelofDetail;
       end
       
       function gnd_res = GroundResolution(latitude, levelofDetail)
           latitude = TileSystem.Clip(latitude, TileSystem.MinLatitude, TileSystem.MaxLatitude);
           gnd_res = cos(latitude*pi/180) * 2 * pi * TileSystem.EarthRadius / Mapsize(levelofDetail);
       end
       
       function mapscale = MapScale(latitude, levelofDetail, screenDpi)
           mapscale = TileSystem.GroundResolution(latitude, levelofDetail) * screenDpi / 0.0254;
       end
       
       function [pixelX, pixelY] = LatLongToPixelXY(latitude, longitude, levelOfDetail)
           latitude = TileSystem.Clip(latitude, TileSystem.MinLatitude, TileSystem.MaxLatitude);
           longitude = TileSystem.Clip(longitude, TileSystem.MinLongitude, TileSystem.MaxLongitude);
           
           x = (longitude+180)/360;
           sinLatitude = sin(latitude*pi/180);
           y = 0.5 - log((1+sinLatitude)/(1-sinLatitude)) / (4*pi);
           
           mapSize = TileSystem.MapSize(levelOfDetail);
           pixelX = floor(TileSystem.Clip(x*mapSize+0.5, 0, mapSize-1));
           pixelY = floor(TileSystem.Clip(y*mapSize+0.5, 0, mapSize-1));
       end
       
       function [latitude, longitude] = PixelXYToLatLong(pixelX, pixelY, levelOfDetail)
            mapSize = TileSystem.MapSize(levelOfDetail);
            x = (TileSystem.Clip(pixelX, 0, mapSize - 1) / mapSize) - 0.5;
            y = 0.5 - (TileSystem.Clip(pixelY, 0, mapSize - 1) / mapSize);

            latitude= 90 - 360 * atan(exp(-y * 2 * pi)) / pi;
            longitude= 360 * x;
        end
       
       function [tileX, tileY] = PixelXYToTileXY(pixelX, pixelY)
           tileX = floor(pixelX/256);
           tileY = floor(pixelY/256);
       end
       
       function [pixelX, pixelY] = TileXYToPixelXY(tileX, tileY)
           pixelX = tileX*256;
           pixelY = tileY*256;
       end
       
       function quadKey = TileXYToQuadKey(tileX, tileY, levelOfDetail)
           quadKey = '';
           for i=1:levelOfDetail
               digit = 0;
               mask = bitshift(1, levelOfDetail-i);
               if bitand(tileX, mask) ~= 0
                   digit = digit+1;
               end
               if bitand(tileY, mask) ~= 0
                   digit = digit+2;
               end
               quadKey = [quadKey int2str(digit)];
           end
       end
       
       function [tileX, tileY, levelofDetail] = QuadKeyToTileXY(quadKey)
           tileX = 0;
           tileY = 0;
           levelofDetail = length(quadKey);
           i = levelofDetail;
           while(i>0)
               mask = bitshift(1,i-1);
               switch quadKey(levelofDetail-i+1)
                   case '1'
                       tileX = bitor(tileX, mask);
                   case '2'
                       tileY = bitor(tileY, mask);
                   case '3'
                       tileX = bitor(tileX, mask);
                       tileY = bitor(tileY, mask);
               end
               i=i-1;
           end
       end
           
       function quadKey = LatLongToQuadKey(latitude, longitude, levelOfDetail)
           [pixelX, pixelY] = TileSystem.LatLongToPixelXY(latitude, longitude, levelOfDetail);
           [tileX, tileY] = TileSystem.PixelXYToTileXY(pixelX, pixelY);
           quadKey = TileSystem.TileXYToQuadKey(tileX, tileY, levelOfDetail);
       end
   end
end