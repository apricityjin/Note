//
//  ContentView2.m
//  Demococos2d
//
//  Created by apricity on 2023/5/18.
//

#import "ContentView2.h"

@implementation ContentView2

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, UIColor.redColor.CGColor);
    CGContextSetFillColorWithColor(context, UIColor.yellowColor.CGColor);
    CGContextSetLineWidth(context, 2);
//    [self drawCircle:context];
//    [self drawArc:context];
//    [self drawCurve:context];
//    [self drawText:context];
    [self drawImage:context];
}

// draw image
- (void)drawImage:(CGContextRef)context {
    [[UIImage systemImageNamed:@"square.and.arrow.up.circle"] drawInRect:(CGRectMake(20, 100, 100, 100))];
}

// draw text
- (void)drawText:(CGContextRef)context {
    [@"abcdefg" drawAtPoint:(CGPointMake(100, 100))
             withAttributes:NULL];
//    [@"opopopop" drawInRect:CGRectMake(20, 100, 100, 100)
//             withAttributes:NULL];
}

// draw curve (bezier line)
- (void)drawCurve:(CGContextRef)context {
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, 20, 100);
    
    // 一次贝塞尔曲线
//    CGContextAddQuadCurveToPoint(context, 130, 260, 300, 200);
    // 二次贝塞尔曲线
    CGContextAddCurveToPoint(context, 130, 50, 260, 260, 300, 200);
    
    CGContextStrokePath(context);
}

// draw arc
- (void)drawArc:(CGContextRef)context {
    CGContextBeginPath(context);
    /*
     *  @param c          当前图形
     *  @param x          圆弧的中心点坐标x
     *  @param y          曲线控制点的y坐标
     *  @param radius      指定点的x坐标值
     *  @param startAngle  弧的起点与正X轴的夹角
     *  @param endAngle    弧的终点与正X轴的夹角
     *  @param clockwise  指定0创建一个顺时针的圆弧，或是指定1创建一个逆时针圆弧
     */
    CGContextAddArc(context, 100, 100, 50, M_PI / 3, M_PI, 1);
    CGContextFillPath(context);
    
}

- (void)drawCircle:(CGContextRef)context {
    CGContextStrokeEllipseInRect(context, CGRectMake(10, 10, 90, 60));
}


@end
