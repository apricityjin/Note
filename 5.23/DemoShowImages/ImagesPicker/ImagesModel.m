//
//  ImagesModel.m
//  DemoShowImages
//
//  Created by apricity on 2023/5/18.
//

#import "ImagesModel.h"

@implementation ImagesModel

+ (NSArray<ImagesModel *> *)getImagesModels {
    NSArray<NSDictionary *>* models = @[
        @{
            @"title": @"手机图片",
            @"number": @225,
            @"imgName":@"image0"
        },
        @{
            @"title": @"内置图片",
            @"number": @67,
            @"imgName":@"image1"
        },
        @{
            @"title": @"其他图片",
            @"number": @13,
            @"imgName":@"image2"
        }];
    NSMutableArray * mAry = [NSMutableArray array];
    for (NSDictionary * model in models) {
        ImagesModel * m = [[ImagesModel alloc] init];
        m.title = [model valueForKey:@"title"];
        m.number = [[model valueForKey:@"number"] intValue];
        m.imgName = [model valueForKey:@"imgName"];
        [mAry addObject:m];
    }
    
    return [mAry copy];
}

@end
