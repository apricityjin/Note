//
//  ContentView.m
//  Demococos2d
//
//  Created by apricity on 2023/5/18.
//

#import "ContentView.h"

@implementation ContentView

- (void)drawRect:(CGRect)rect {
    NSLog(@"draw begin...");
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();//获取上下文
    CGMutablePathRef path = CGPathCreateMutable();//创建路径
    CGPathMoveToPoint(path, nil, 20, 50);//移动到指定位置（设置路径起点）
    CGPathAddLineToPoint(path, nil, 20, 100);//绘制直线（从起始位置开始）
    CGPathAddLineToPoint(path, nil, 40, 100);
    
    CGContextAddPath(context, path);//把路径添加到上下文（画布）中
    
    CGContextSetRGBStrokeColor(context, 1.0, 0, 0, 1);
    CGContextSetRGBFillColor(context, 0, 1.0, 0, 1);
    
    CGContextSetLineWidth(context, 2);
    CGContextSetLineCap(context, kCGLineCapRound);//设置顶点样式
    CGContextSetLineJoin(context, kCGLineJoinRound);//设置连接点样式
//    CGFloat lengths[2] = { 18, 9 };
//    CGContextSetLineDash(context, 0, lengths, 2);
    CGContextSetShadowWithColor(context, CGSizeMake(2, 2), 0, [UIColor whiteColor].CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);//最后一个参数是填充类型
    
    NSLog(@"draw end...");
}


@end
