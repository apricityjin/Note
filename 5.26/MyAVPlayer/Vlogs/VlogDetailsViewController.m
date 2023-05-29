//
//  VlogPlayerViewController.m
//  MyAVPlayer
//
//  Created by apricity on 2023/5/25.
//

#import "VlogDetailsViewController.h"

@interface VlogDetailsViewController ()

@property (assign, nonatomic) NSInteger currentVlogIndex;
@property (strong, nonatomic) NSMutableArray <VlogModel *> * dataMAry;
@property (assign, nonatomic) CGSize vlogSize;

@property (strong, nonatomic) AVPlayerItemVideoOutput * videoOutput;
@property (strong, nonatomic) AVPlayerItem * item;
@property (strong, nonatomic) UIView * contentView;
@property (strong, nonatomic) AVPlayer * player;
@property (strong, nonatomic) AVPlayerLayer * playerLayer;
@property (strong, nonatomic) UIButton * nextButton;
@property (strong, nonatomic) UIButton * playButton;
@property (strong, nonatomic) UIButton * previousButton;
@property (strong, nonatomic) UIButton * goforwardButton;
@property (strong, nonatomic) UIButton * gobackwardButton;
@property (strong, nonatomic) UIButton * closeButton;
@property (strong, nonatomic) UIButton * saveButton;
@property (strong, nonatomic) UISlider * timelineSlider;

@end

@implementation VlogDetailsViewController

- (instancetype)initWithVlogModels:(NSMutableArray *)dataMAry currentVlogIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        _dataMAry = dataMAry;
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
    return;
    VlogModel * model = self.dataMAry[self.currentVlogIndex];
    NSData * audioData = [NSData dataWithContentsOfURL:model.URL];
    // 创建CMBlockBufferRef
    CMBlockBufferRef audioBlockBuffer = NULL; // 编码后的输出数据
    OSStatus status = CMBlockBufferCreateWithMemoryBlock(NULL, (void *)audioData.bytes, audioData.length, kCFAllocatorNull, NULL, 0, audioData.length, kCMBlockBufferAssureMemoryNowFlag, &audioBlockBuffer);
    if (status != noErr) {
        NSLog(@"Failed to create audio block buffer");
        return;
    }
    // 创建AudioStreamBasicDescription 用于描述音频流数据格式信息，比如采样位深、声道数、采样率、每帧字节数、每包帧数、每包字节数、格式标识等。
    AudioStreamBasicDescription audioStreamBasicDescription;
    memset(&audioStreamBasicDescription, 0, sizeof(audioStreamBasicDescription));
    audioStreamBasicDescription.mSampleRate = 44100;
    audioStreamBasicDescription.mFormatID = kAudioFormatMPEG4AAC;
    audioStreamBasicDescription.mFormatFlags = kMPEG4Object_AAC_LC;
    audioStreamBasicDescription.mChannelsPerFrame = 2;

    // 创建CMAudioFormatDescriptionRef 包含了音频的数据格式、声道数、采样位深、采样率等参数。
    CMAudioFormatDescriptionRef audioFormatDescription = NULL;
    status = CMAudioFormatDescriptionCreate(NULL, &audioStreamBasicDescription, sizeof(audioStreamBasicDescription), NULL, 0, NULL, NULL, &audioFormatDescription);
    if (status != noErr) {
        NSLog(@"Failed to create audio format description");
        return;
    }
    CMSampleBufferRef sampleBuffer = NULL;
    CMItemCount numSamples = 1024;
    CMSampleTimingInfo timingInfo = {CMTimeMake(1, 44100), kCMTimeZero, kCMTimeInvalid};
    status = CMSampleBufferCreate(kCFAllocatorDefault, audioBlockBuffer, YES, NULL, NULL, audioFormatDescription, numSamples, 1, &timingInfo, 0, NULL, &sampleBuffer);
    if (status != noErr) {
        NSLog(@"Failed to create sample buffer");
        return;
    }
    // 获取样本数据
    size_t sampleSize = CMSampleBufferGetTotalSampleSize(sampleBuffer);
    void *sampleData = NULL;
    status = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, NULL, sizeof(CMSampleBufferRef), NULL, NULL, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &audioBlockBuffer);
    if (status != noErr) {
        NSLog(@"Failed to get audio buffer list");
        return;
    }
    // 获取时间戳和持续时间
    CMTime presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    CMTime duration = CMSampleBufferGetDuration(sampleBuffer);
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (pixelBuffer == NULL) {
        NSLog(@"Failed to get pixel buffer from sample buffer");
        return;
    }

    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    size_t dataSize = CVPixelBufferGetDataSize(pixelBuffer);

    uint8_t *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.image = image;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
}

- (void)layoutMyViews {
    [self.view addSubview:self.contentView];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.saveButton];
    [self.view addSubview:self.previousButton];
    [self.view addSubview:self.playButton];
    [self.view addSubview:self.nextButton];
    [self.view addSubview:self.timelineSlider];
    [self.view addSubview:self.gobackwardButton];
    [self.view addSubview:self.goforwardButton];
    
    CGFloat padding = 20.;
    CGFloat maxWidth = UIScreen.mainScreen.bounds.size.width - padding * 2;
    CGFloat buttonWidth = (maxWidth - 4 * padding) / 5;
    
    self.contentView.frame = self.view.bounds;
    self.vlogSize = self.contentView.frame.size;
    
    self.videoOutput = [[AVPlayerItemVideoOutput alloc] init];
    self.item = [AVPlayerItem playerItemWithURL:self.dataMAry[self.currentVlogIndex].URL];
    [self.item addOutput:self.videoOutput];
    self.player = [AVPlayer playerWithPlayerItem:self.item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.contentView.layer addSublayer:self.playerLayer];
    self.playerLayer.frame = self.contentView.bounds;

    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view);
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
    [self.gobackwardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.previousButton.mas_right).mas_offset(padding);
        make.bottom.mas_equalTo(self.timelineSlider.mas_top);
        make.width.height.mas_equalTo(buttonWidth);
    }];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.gobackwardButton.mas_right).mas_offset(padding);
        make.bottom.mas_equalTo(self.timelineSlider.mas_top);
        make.width.height.mas_equalTo(buttonWidth);
    }];
    [self.goforwardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.playButton.mas_right).mas_offset(padding);
        make.bottom.mas_equalTo(self.timelineSlider.mas_top);
        make.width.height.mas_equalTo(buttonWidth);
    }];
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.goforwardButton.mas_right).mas_offset(padding);
        make.bottom.mas_equalTo(self.timelineSlider.mas_top);
        make.width.height.mas_equalTo(buttonWidth);
    }];
    
    __weak typeof(self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1, 600) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        CGFloat durationInSeconds = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
        if (isfinite(durationInSeconds)) {
            CGFloat timeInSeconds = CMTimeGetSeconds(time);
            CGFloat value = (timeInSeconds / durationInSeconds);
            [weakSelf.timelineSlider setValue:value animated:YES];
        }
    }];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playerDidFinishPlaying:)
     name:AVPlayerItemDidPlayToEndTimeNotification
     object:nil];
    [self.player addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    NSLog(@"dealloc");
    [[NSNotificationCenter defaultCenter]
     removeObserver:self];
    [self.player removeObserver:self forKeyPath:@"timeControlStatus"];
}

#pragma mark - observer

- (void)playerDidFinishPlaying:(NSNotification *)notification {
    AVPlayerItem * playerItem = notification.object;
    [playerItem seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.player && [keyPath isEqualToString:@"timeControlStatus"]) {
        AVPlayerTimeControlStatus status = self.player.timeControlStatus;
        self.playButton.selected = (status == AVPlayerTimeControlStatusPlaying);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
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

- (void)saveButtonDidClicked:(UIButton *)button {
    dispatch_async(dispatch_queue_create("com.save", DISPATCH_QUEUE_SERIAL), ^{
        VlogModel * model = self.dataMAry[self.currentVlogIndex];
        AVAsset * asset = [AVAsset assetWithURL:model.URL];
        AVAssetImageGenerator * generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        generator.appliesPreferredTrackTransform = YES;
        generator.maximumSize = self.vlogSize;
        
        CMTime currentTime = self.player.currentTime;
        CGImageRef imageRef = [generator copyCGImageAtTime:currentTime actualTime:nil error:nil];
        UIImage * image = [UIImage imageWithCGImage:imageRef];
        
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString * imagePath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%f.png", model.title, CMTimeGetSeconds(currentTime)]];
        
        NSData * data = UIImagePNGRepresentation(image);
        [data writeToFile:imagePath atomically:YES];
    });
}

- (void)goforwardButtonDidClicked:(UIButton *)button {
    CMTime currentTime = self.player.currentTime;
    CMTime forwardTime = CMTimeAdd(currentTime, CMTimeMakeWithSeconds(5, 600));
    [self.player seekToTime:forwardTime];
}

- (void)gobackwardButtonDidClicked:(UIButton *)button {
    CMTime currentTime = self.player.currentTime;
    CMTime backwardTime = CMTimeAdd(currentTime, CMTimeMakeWithSeconds(-5, 600));
    [self.player seekToTime:backwardTime];
}

- (void)playButtonDidClicked:(UIButton *)button {
    if (self.player.rate == 0) {
        [self.player play];
        button.selected = YES;
    } else {
        [self.player pause];
        button.selected = NO;
    }
}

- (void)timelineSliderValueChanged:(UISlider *)slider {
    CMTime duration = self.player.currentItem.duration;
    CGFloat durationInSeconds = CMTimeGetSeconds(duration);
    CGFloat newTimeInSeconds = durationInSeconds * slider.value;
    CMTime newTime = CMTimeMakeWithSeconds(newTimeInSeconds, 1);
    [self.player seekToTime:newTime];
}

- (void)timelineSliderTouchDown:(UISlider *)slider {
    [self.player pause];
}

- (void)timelineSliderTouchUpInside:(UISlider *)slider {
    [self.player play];
}
#pragma mark - setter

- (void)setCurrentVlogIndex:(NSInteger)currentVlogIndex {
    _currentVlogIndex = currentVlogIndex;
    NSUInteger count = self.dataMAry.count;
    if (_currentVlogIndex < 0) {
        _currentVlogIndex = count - 1;
    } else if (_currentVlogIndex >= count) {
        _currentVlogIndex = 0;
    }
    VlogModel * model = self.dataMAry[self.currentVlogIndex];
    [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:model.URL]];
    [self.player play];
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

- (UIButton *)goforwardButton {
    if (_goforwardButton == nil) {
        _goforwardButton = [[UIButton alloc] init];
        [_goforwardButton addTarget:self
                         action:@selector(goforwardButtonDidClicked:)
               forControlEvents:(UIControlEventTouchUpInside)];
        [_goforwardButton setImage:[UIImage systemImageNamed:@"goforward.5"]
                      forState:(UIControlStateNormal)];
    }
    return _goforwardButton;
}

- (UIButton *)gobackwardButton {
    if (_gobackwardButton == nil) {
        _gobackwardButton = [[UIButton alloc] init];
        [_gobackwardButton addTarget:self
                              action:@selector(gobackwardButtonDidClicked:)
               forControlEvents:(UIControlEventTouchUpInside)];
        [_gobackwardButton setImage:[UIImage systemImageNamed:@"gobackward.5"]
                      forState:(UIControlStateNormal)];
    }
    return _gobackwardButton;
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

- (UIButton *)saveButton {
    if (_saveButton == nil) {
        _saveButton = [[UIButton alloc] init];
        [_saveButton addTarget:self action:@selector(saveButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_saveButton setImage:[UIImage systemImageNamed:@"arrow.down.circle"] forState:UIControlStateNormal];
    }
    return _saveButton;
}

- (UISlider *)timelineSlider {
    if (_timelineSlider == nil) {
        _timelineSlider = [[UISlider alloc] init];
        [_timelineSlider addTarget:self action:@selector(timelineSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_timelineSlider addTarget:self action:@selector(timelineSliderTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_timelineSlider addTarget:self action:@selector(timelineSliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _timelineSlider;
}

@end
