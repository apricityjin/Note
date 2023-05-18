# 1 简介

Core Graphics是Quartz 2D的高级绘图引擎。底层是C语言，提供大量低层次。轻量级的2D渲染API。

# 2 绘制一个简单图形

```objc
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
    CGContextDrawPath(context, kCGPathFillStroke);//最后一个参数是填充类型

    NSLog(@"draw end...");
}
```

# 3 绘制复杂图形（圆、圆弧、贝塞尔曲线……）

```objc
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, UIColor.redColor.CGColor);
    CGContextSetFillColorWithColor(context, UIColor.yellowColor.CGColor);
    CGContextSetLineWidth(context, 2);
//    [self drawCircle:context];
//    [self drawArc:context];
    [self drawCurve:context];
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
```

# 4 绘制文字、图片

```objc
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
```
