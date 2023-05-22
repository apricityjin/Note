//
//  ImageCollectionViewCell.m
//  DemoImageMagenification
//
//  Created by apricity on 2023/5/19.
//

#import "ImageCollectionViewCell.h"
#import "Masonry.h"

@interface ImageCollectionViewCell ()

@property (strong, nonatomic) UIImageView * imageView;

@end

@implementation ImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutMyViews];
    }
    return self;
}

- (void)layoutMyViews {
    [self.contentView addSubview:self.imageView];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.contentView);
    }];
}

#pragma mark - setter

- (void)setCellModel:(ImageModel *)cellModel {
    _cellModel = cellModel;
    self.imageView.image = [UIImage imageNamed:cellModel.imageName];
}

#pragma mark - getter

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.cornerRadius = 10;
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}

@end
