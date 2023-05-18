//
//  ViewController.m
//  Demococos2d
//
//  Created by apricity on 2023/5/18.
//

#import "ViewController.h"
#import "ContentView.h"
#import "ContentView2.h"

@interface ViewController ()

@property (nonatomic, strong) ContentView * cView;
@property (nonatomic, strong) ContentView2 * dView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self.view addSubview:self.cView];
    [self.view addSubview:self.dView];
}

#pragma - lazy

- (ContentView2 *)dView {
    if (_dView == nil) {
        _dView = [[ContentView2 alloc] initWithFrame:self.view.frame];
        _dView.backgroundColor = UIColor.whiteColor;
    }
    return _dView;
}

- (ContentView *)cView {
    if (_cView == nil) {
        _cView = [[ContentView alloc] initWithFrame:self.view.frame];
        _cView.backgroundColor = UIColor.whiteColor;
    }
    return  _cView;
}

@end
