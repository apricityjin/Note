//
//  ImageBrowseCollectionViewCell.m
//  DemoImageMagenification
//
//  Created by apricity on 2023/5/20.
//

#import "ImageBrowseCollectionViewCell.h"
#import "Masonry.h"

@interface ImageBrowseCollectionViewCell ()

@end

@implementation ImageBrowseCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        [self layoutMyViews];
    }
    return self;
}

- (void)setup {

}

- (void)layoutMyViews {
    [self.contentView addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.contentView);
        make.size.mas_lessThanOrEqualTo(self.contentView);
    }];
}

#pragma mark - getter

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
        _imageView.multipleTouchEnabled = YES;
    }
    return _imageView;
}

@end
