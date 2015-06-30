// range of map or layer
typedef struct BBox{
    double  left;
    double  bottom;
    double  right;
    double  top;
} BBox;

//----------------------------------------------------------------------------
NS_INLINE double xOfColumn(NSInteger column,NSInteger zoom){

    double x = column;
    double z = zoom;

    return x / pow(2.0, z) * 360.0 - 180;
}

//----------------------------------------------------------------------------

NS_INLINE  double yOfRow(NSInteger row,NSInteger zoom){

    double y = row;
    double z = zoom;

    double n = M_PI - 2.0 * M_PI * y / pow(2.0, z);
    return 180.0 / M_PI * atan(0.5 * (exp(n) - exp(-n)));
}

//-------------------------------------------------------------------------------------
NS_INLINE  double MercatorXofLongitude(double lon){
    return  lon * 20037508.34 / 180;
}

//------------------------------------------------------------
NS_INLINE double MercatorYofLatitude(double lat){
    double y = log(tan((90 + lat) * M_PI / 360)) / (M_PI / 180);
    y = y * 20037508.34 / 180;

    return y;
}

//------------------------------------------------------------
NS_INLINE BBox bboxFromXYZ(NSUInteger x, NSUInteger y, NSUInteger z){
    // BBOX in spherical mercator
    BBox bbox = {
        .left   = MercatorXofLongitude(xOfColumn(x,z)),  //minX
        .right  = MercatorXofLongitude(xOfColumn(x+1,z)), //maxX
        .bottom = MercatorYofLatitude(yOfRow(y+1,z)), //minY
        .top    = MercatorYofLatitude(yOfRow(y,z))      //maxY
    };
    return bbox;
}
