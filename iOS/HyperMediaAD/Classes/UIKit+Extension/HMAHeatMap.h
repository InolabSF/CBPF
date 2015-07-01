#import <UIKit/UIKit.h>


@interface HMAHeatMap : NSObject

+ (UIImage *)heatMapWithRect:(CGRect)rect
                       boost:(float)boost
                      points:(NSArray *)points
                     weights:(NSArray *)weights;

+ (UIImage *)heatMapWithRect:(CGRect)rect
                       boost:(float)boost
                      points:(NSArray *)points
                     weights:(NSArray *)weights
    weightsAdjustmentEnabled:(BOOL)weightsAdjustmentEnabled
             groupingEnabled:(BOOL)groupingEnabled;

+ (UIImage *)heatIndexHeatmapWithRect:(CGRect)rect
                                boost:(float)boost
                               points:(NSArray *)points
                              weights:(NSArray *)weights;

+ (UIImage *)crimeHeatmapWithRect:(CGRect)rect
                            boost:(float)boost
                           points:(NSArray *)points
                          weights:(NSArray *)weights;

@end
