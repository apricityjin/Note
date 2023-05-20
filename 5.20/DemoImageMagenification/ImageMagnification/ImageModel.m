//
//  ImageModel.m
//  DemoImageMagenification
//
//  Created by apricity on 2023/5/19.
//

#import "ImageModel.h"

@implementation ImageModel

+ (NSArray<ImageModel *> *)getImageModels {
    NSMutableArray * mAry = [NSMutableArray arrayWithCapacity:20];
    
    for (int i = 0; i < 20; i++) {
        ImageModel * model = [[ImageModel alloc] init];
        model.imageName = [NSString stringWithFormat:@"image%d", i % 3];
        [mAry addObject:model];
    }
    
    return [mAry copy];
}

@end
