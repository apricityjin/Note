//
//  ImagesModel.h
//  DemoShowImages
//
//  Created by apricity on 2023/5/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImagesModel : NSObject

@property (copy, nonatomic) NSString * title;
@property (assign, nonatomic) NSInteger number;
@property (copy, nonatomic) NSString * imgName;

+ (NSArray <ImagesModel *> *)getImagesModels;

@end

NS_ASSUME_NONNULL_END
