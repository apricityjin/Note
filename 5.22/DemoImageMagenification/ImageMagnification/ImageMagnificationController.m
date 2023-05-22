//
//  ImageMagnificationController.m
//  DemoImageMagenification
//
//  Created by apricity on 2023/5/19.
//

#import "ImageMagnificationController.h"
#import "ImageModel.h"
#import "ImageCollectionViewCell.h"
#import "ImageBrowseViewController.h"
#import "Masonry.h"

@interface ImageMagnificationController ()
<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView * collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout * flowLayout;

@property (copy, nonatomic) NSArray * dataAry;

@end

@implementation ImageMagnificationController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadData];
    [self layoutMyViews];
}

- (void)loadData {
    self.dataAry = [ImageModel getImageModels];
    [self.collectionView reloadData];
}

- (void)layoutMyViews {
    [self.view addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(self.view);
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataAry.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ImageCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ImageCollectionViewCell.class) forIndexPath:indexPath];
    
    cell.cellModel = self.dataAry[indexPath.row];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageBrowseViewController * vc = [[ImageBrowseViewController alloc] init];
    NSMutableArray * mAry = [NSMutableArray array];
    for (ImageModel * model in self.dataAry) {
        [mAry addObject:model.imageName];
    }
    vc.imageNameAry = mAry.copy;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.indexPath = indexPath;            
    
    [self presentViewController:vc
                       animated:YES
                     completion:^{
    }];
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout

static const float kSeperatorLineWidth = 15;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (UIScreen.mainScreen.bounds.size.width - kSeperatorLineWidth * 4) / 3;
    CGFloat height = width;
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(kSeperatorLineWidth, kSeperatorLineWidth, kSeperatorLineWidth, kSeperatorLineWidth);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kSeperatorLineWidth;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kSeperatorLineWidth;
}

#pragma mark - getter

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = UIColor.whiteColor;
        [_collectionView registerClass:ImageCollectionViewCell.class forCellWithReuseIdentifier:NSStringFromClass(ImageCollectionViewCell.class)];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (_flowLayout == nil) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _flowLayout;
}

@end
