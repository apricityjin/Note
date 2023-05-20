//
//  ImageCollectionViewCell.h
//  DemoImageMagenification
//
//  Created by apricity on 2023/5/19.
//

#import <UIKit/UIKit.h>
#import "ImageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImageCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) ImageModel * cellModel;

@end

NS_ASSUME_NONNULL_END
