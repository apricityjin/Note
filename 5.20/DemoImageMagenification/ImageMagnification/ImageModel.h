//
//  ImageModel.h
//  DemoImageMagenification
//
//  Created by apricity on 2023/5/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageModel : NSObject

@property (copy, nonatomic) NSString * imageName;

+ (NSArray <ImageModel *>*)getImageModels;

@end

NS_ASSUME_NONNULL_END
