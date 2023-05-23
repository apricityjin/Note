//
//  ShowImagesModel.m
//  DemoShowImages
//
//  Created by apricity on 2023/5/18.
//

#import "ShowImagesModel.h"

@implementation ShowImagesModel

+ (NSMutableArray<ShowImagesModel *> *)getShowImagesModelsWithNumber:(NSInteger)number
                                                                 row:(NSInteger)row{
    NSMutableArray * mAry = [NSMutableArray arrayWithCapacity:number];
    
    for (int i = 0; i < number; i++) {
        ShowImagesModel * model = [[ShowImagesModel alloc] init];
        model.imgName = [NSString stringWithFormat:@"image%zd", row];
        model.selected = NO;
        [mAry addObject:model];
    }
    
    return mAry;
}

@end
