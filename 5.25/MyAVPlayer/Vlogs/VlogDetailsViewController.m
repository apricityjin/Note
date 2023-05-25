//
//  VlogPlayerViewController.m
//  MyAVPlayer
//
//  Created by apricity on 2023/5/25.
//

#import "VlogDetailsViewController.h"

@interface VlogDetailsViewController ()

@property (strong, nonatomic) UIView * contentView;
@property (strong, nonatomic) AVPlayer * player;
@property (strong, nonatomic) AVPlayerLayer * playerLayer;
@property (assign, nonatomic) NSUInteger currentVlogIndex;
@property (strong, nonatomic) NSMutableArray <VlogModel *> * dataMAry;

@property (strong, nonatomic) UIButton * nextButton;
@property (strong, nonatomic) UIButton * playButton;
@property (strong, nonatomic) UIButton * previousButton;
@property (strong, nonatomic) UIButton * closeButton;
@property (strong, nonatomic) UISlider * timelineSlider;

@end

@implementation VlogDetailsViewController

- (instancetype)initWithVlogModels:(NSMutableArray *)dataMAry currentVlogIndex:(NSUInteger)index
{
    self = [super init];
    if (self) {
        self.dataMAry = dataMAry;
        _currentVlogIndex = index;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.dataMAry[self.currentVlogIndex].title;
    self.view.backgroundColor = UIColor.whiteColor;
    [self layoutMyViews];
    [self.player play];
}

- (void)layoutMyViews {
    [self.view addSubview:self.contentView];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.previousButton];
    [self.view addSubview:self.playButton];
    [self.view addSubview:self.nextButton];
    [self.view addSubview:self.timelineSlider];

    CGFloat padding = 20.;
    CGFloat maxWidth = UIScreen.mainScreen.bounds.size.width - padding * 2;
    CGFloat buttonWidth = (maxWidth - 2 * padding) / 3;
    
    self.contentView.frame = self.view.bounds;
    
    self.player = [[AVPlayer alloc] initWithURL:self.dataMAry[self.currentVlogIndex].URL];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.contentView.layer addSublayer:self.playerLayer];
    self.playerLayer.frame = self.contentView.bounds;
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_safeAreaLayoutGuideLeft);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [self.timelineSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).mas_offset(padding);
        make.right.mas_equalTo(self.view).mas_offset(-padding);
        make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
    [self.previousButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).mas_offset(padding);
        make.bottom.mas_equalTo(self.timelineSlider.mas_top);
        make.width.height.mas_equalTo(buttonWidth);
    }];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.previousButton.mas_right).mas_offset(padding);
        make.bottom.mas_equalTo(self.timelineSlider.mas_top);
        make.width.height.mas_equalTo(buttonWidth);
    }];
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.playButton.mas_right).mas_offset(padding);
        make.bottom.mas_equalTo(self.timelineSlider.mas_top);
        make.width.height.mas_equalTo(buttonWidth);
    }];
}

#pragma mark - event action

- (void)nextButtonDidClicked:(UIButton *)button {
    self.currentVlogIndex += 1;
}

- (void)previousButtonDidClicked:(UIButton *)button {
    self.currentVlogIndex -= 1;
}

- (void)closeButtonDidClicked:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:^{
            
    }];
}

- (void)playButtonDidClicked:(UIButton *)button {
    if (self.player.rate == 0) {
        
    }
}

- (void)timelineSliderValueChanged {
    
}

#pragma mark - setter

- (void)setCurrentVlogIndex:(NSUInteger)currentVlogIndex {
    NSUInteger count = self.dataMAry.count;
    if (_currentVlogIndex < 0) {
        _currentVlogIndex = count - 1;
    } else if (_currentVlogIndex >= count) {
        _currentVlogIndex = 0;
    }
    VlogModel * model = self.dataMAry[self.currentVlogIndex];
    [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:model.URL]];
    self.title = model.title;
}

#pragma mark - getter

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = UIColor.whiteColor;
    }
    return _contentView;
}

- (UIButton *)nextButton {
    if (_nextButton == nil) {
        _nextButton = [[UIButton alloc] init];
        [_nextButton addTarget:self action:@selector(nextButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_nextButton setImage:[UIImage systemImageNamed:@"forward.frame.fill"] forState:UIControlStateNormal];
    }
    return _nextButton;
}

- (UIButton *)playButton {
    if (_playButton == nil) {
        _playButton = [[UIButton alloc] init];
        [_playButton addTarget:self action:@selector(playButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage systemImageNamed:@"pause.fill"] forState:UIControlStateSelected];
    }
    return _playButton;
}

- (UIButton *)previousButton {
    if (_previousButton == nil) {
        _previousButton = [[UIButton alloc] init];
        [_previousButton addTarget:self action:@selector(previousButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_previousButton setImage:[UIImage systemImageNamed:@"backward.frame.fill"] forState:UIControlStateNormal];
    }
    return _previousButton;
}

- (UIButton *)closeButton {
    if (_closeButton == nil) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton addTarget:self
                         action:@selector(closeButtonDidClicked:)
               forControlEvents:(UIControlEventTouchUpInside)];
        [_closeButton setImage:[UIImage systemImageNamed:@"xmark"]
                      forState:(UIControlStateNormal)];
    }
    return _closeButton;
}

- (UISlider *)timelineSlider {
    if (_timelineSlider == nil) {
        _timelineSlider = [[UISlider alloc] init];
        [_timelineSlider addTarget:self action:@selector(timelineSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    }
    return _timelineSlider;
}

@end
