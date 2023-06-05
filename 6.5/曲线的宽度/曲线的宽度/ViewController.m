//
//  ViewController.m
//  曲线的宽度
//
//  Created by apricity on 2023/6/5.
//

#import "ViewController.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import "DMShaderTypes.h"

@interface ViewController ()

<MTKViewDelegate>

// view
@property (nonatomic, strong) MTKView *mtkView;

// data
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;

@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;
@property (nonatomic, assign) NSInteger vertexBufferLength;
@property (nonatomic, assign) NSUInteger vertexCount;

@property (nonatomic, strong) id<MTLBuffer> viewportSizeBuffer;
@property (nonatomic, assign) vector_float2 viewportSize;

@property (nonatomic, strong) id<MTLBuffer> indexBuffer;
@property (nonatomic, assign) NSInteger indexBufferLength;
@property (nonatomic, assign) NSUInteger indexCount;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mtkView = [[MTKView alloc] initWithFrame:self.view.bounds];
    self.mtkView.device = MTLCreateSystemDefaultDevice(); // 获取默认的device
    self.view = self.mtkView;
    self.mtkView.delegate = self;
    self.viewportSize = (vector_float2){self.mtkView.drawableSize.width, self.mtkView.drawableSize.height};
    
    [self setupPipeline];
    // 定义输入多边形（三角形）
    
    pointCount = 0;
    {
        vector_float2 P0 = { 79.549, 9.2548 };
        vector_float2 P1 = { 85.0512, -1.89389 };
        vector_float2 P2 = { 100.949, -1.8939};
        vector_float2 P3 = { 106.451, 9.25478 };
        bezier(P0.x,P0.y, P1.x,P1.y, P2.x,P2.y, P3.x,P3.y);
    }
    {
        vector_float2 P0 = { 123.308 ,43.4099 };
        vector_float2 P1 = { 125.493 ,47.837  };
        vector_float2 P2 = {  129.716 ,50.9056};
        vector_float2 P3 = {  134.602 ,51.6155};
        bezier(P0.x,P0.y, P1.x,P1.y, P2.x,P2.y, P3.x,P3.y);
    }
    {
        vector_float2 P0 = { 172.294 ,57.0925};
        vector_float2 P1 = { 184.597 ,58.8803 };
        vector_float2 P2 = {  189.51 ,73.9999 };
        vector_float2 P3 = {  180.607, 82.6779};
        bezier(P0.x,P0.y, P1.x,P1.y, P2.x,P2.y, P3.x,P3.y);
    }
    {
        vector_float2 P0 = { 153.333, 109.264};
        vector_float2 P1 = { 149.797, 112.71 };
        vector_float2 P2 = { 148.184, 117.675};
        vector_float2 P3 = { 149.019, 122.541};
        bezier(P0.x,P0.y, P1.x,P1.y, P2.x,P2.y, P3.x,P3.y);
    }
    {
        vector_float2 P0 = { 155.457, 160.081 };
        vector_float2 P1 = { 157.559, 172.335 };
        vector_float2 P2 = { 144.698, 181.679 };
        vector_float2 P3 = { 133.693, 175.894 };
        bezier(P0.x,P0.y, P1.x,P1.y, P2.x,P2.y, P3.x,P3.y);
    }
    {
        vector_float2 P0 = { 99.9801 ,158.17 };
        vector_float2 P1 = { 95.6103 ,155.872  };
        vector_float2 P2 = {  90.3897, 155.872  };
        vector_float2 P3 = {  86.0199, 158.17 };
        bezier(P0.x,P0.y, P1.x,P1.y, P2.x,P2.y, P3.x,P3.y);
    }
    {
        vector_float2 P0 = { 52.3068 ,175.894 };
        vector_float2 P1 = { 41.3024 ,181.679 };
        vector_float2 P2 = {  28.4409, 172.335  };
        vector_float2 P3 = {  30.5425, 160.081 };
        bezier(P0.x,P0.y, P1.x,P1.y, P2.x,P2.y, P3.x,P3.y);
    }
    {
        vector_float2 P0 = {  36.9812, 122.541   };
        vector_float2 P1 = {  37.8157, 117.675   };
        vector_float2 P2 = {  36.2025, 112.71   };
        vector_float2 P3 = {  32.6672, 109.264  };
        bezier(P0.x,P0.y, P1.x,P1.y, P2.x,P2.y, P3.x,P3.y);
    }
    {
        vector_float2 P0 = {  5.39275, 82.6779   };
        vector_float2 P1 = {  -3.51001, 73.9999    };
        vector_float2 P2 = {    1.40263, 58.8803   };
        vector_float2 P3 = {    13.7059, 57.0925  };
        bezier(P0.x,P0.y, P1.x,P1.y, P2.x,P2.y, P3.x,P3.y);
    }
    {
        vector_float2 P0 = {  51.3983, 51.6155   };
        vector_float2 P1 = {  56.284, 50.9056   };
        vector_float2 P2 = {   60.5075, 47.837   };
        vector_float2 P3 = {   62.6924, 43.4099  };
        bezier(P0.x,P0.y, P1.x,P1.y, P2.x,P2.y, P3.x,P3.y);
    }
    addPoint(79.549, 9.2548);
    
    int bezierPointsCount = pointCount;
    int bezierPointsSize = pointCount * 2 * sizeof(float);
    float* bezierPoints = malloc(bezierPointsSize);
    memcpy(bezierPoints, polygon, bezierPointsSize);
    // 接下来求法线
    int normalPointsCount = pointCount * 2 - 2; // 每个顶点求法线的正反方向, 未做闭合处理的判断
    int normalPointsSize = pointCount * 2 * sizeof(float) * 2; // 每个顶点求法线的正反方向
    float* normalPoints = malloc(normalPointsSize);
    float lineWidth = 4.0;
    int circlePointsCount = 0; // 圆的点
    normalLines(normalPoints, normalPointsCount, bezierPoints, bezierPointsCount, lineWidth, &circlePointsCount);
//    for (int i = 0; i < (normalPointsCount + circlePointsCount) * 2; i++) {
//        printf("%f ", normalPoints[i]);
//    }
    
    // 接下来进行起始和结束位置圆弧坐标的运算
    float a  = bezierPoints[bezierPointsCount * 2 - 4], b  = bezierPoints[bezierPointsCount * 2 - 3];
    float xt = normalPoints[normalPointsCount * 2 - 4], yt = normalPoints[normalPointsCount * 2 - 3];
    float xb = normalPoints[normalPointsCount * 2 - 2], yb = normalPoints[normalPointsCount * 2 - 1];
    float radius = lineWidth * 3, tolerance = 0.1; // 像素坐标转化为屏幕坐标，对应关系是 3 : 1
    tolerance = MIN(radius, tolerance);
    int circleFlatteningStep = 2 * sqrt(2 * radius * tolerance - tolerance * tolerance) + 0.5; // 四舍五入
    circlePointsCount = circleFlatteningStep + 2;
    float * circlePoints = malloc(sizeof(float) * circlePointsCount * 2);
    circlePoints[0] = a;
    circlePoints[1] = b;
    circlePoints[2] = xt;
    circlePoints[3] = yt;
    float angle = - M_PI / circleFlatteningStep; // 顺时针
    float cos_angle = cos(angle), sin_angle = sin(angle);
    for (int i = 2; i < circleFlatteningStep + 2; i++)
    {
        float u1 = xt - a,                          v1 = yt - b;
        float u2 = u1 * cos_angle - v1 * sin_angle, v2 = u1 * sin_angle + v1 * cos_angle;
        float xc = a + u2,                          yc = b + v2;
        circlePoints[i * 2]     = xc;
        circlePoints[i * 2 + 1] = yc;
        xt = xc;
        yt = yc;
        
//        printf("%f, %f\n", xc, yc);
    }
    
    float * verPoints = malloc(sizeof(float) * (normalPointsCount + circlePointsCount) * 2);
    int circlePointsSize = 2 * circlePointsCount * sizeof(float);
    memcpy(verPoints, normalPoints, normalPointsSize);
    memcpy(verPoints + normalPointsCount * 2, circlePoints, circlePointsSize);
    free(normalPoints);
//    free(circlePoints);
    normalPoints = verPoints;
    for (int i = 0; i < (normalPointsCount + circlePointsCount) * 2; i++) {
        printf("%f ", normalPoints[i]);
    }
    
    
    // 转换为 vector_float4 坐标
    self.vertexCount = normalPointsCount + circlePointsCount;
    self.vertexBufferLength = sizeof(DMVertex) * self.vertexCount;
    self.vertexBuffer =
    [self.mtkView.device newBufferWithLength:self.vertexBufferLength
                                     options:MTLResourceStorageModeShared];
    void* vertexBufferPointer = [self.vertexBuffer contents];
    DMVertex *ver = vertexBufferPointer;
    for (int i = 0; i < self.vertexCount; i++)
    {
        ver[i] = (DMVertex){
            { normalPoints[i * 2], normalPoints[i * 2 + 1], 0.0, 1.0 }
        };
    }
    
    self.indexCount = (normalPointsCount - 2 + circlePointsCount - 2) * 3;
    self.indexBufferLength = sizeof(int) * self.indexCount;
    int * indexes = malloc(self.indexBufferLength);
    for (int i = 0; i < normalPointsCount - 2; i++) {
        indexes[i * 3]     = i;
        indexes[i * 3 + 1] = i + 1;
        indexes[i * 3 + 2] = i + 2;
//        NSLog(@"%d : %d %d %d", i * 3, i, i + 1, i + 2);
    }
    // 结束点的圆需要处理index
//    for (int i = 0; i < self.indexCount; i++) {
//        printf("%d ", indexes[i]);
//    }
    for (int i = 0; i < circlePointsCount - 2; i++) {
        indexes[(normalPointsCount - 2 + i) * 3]     = normalPointsCount;
        indexes[(normalPointsCount - 2 + i) * 3 + 1] = normalPointsCount + i + 1;
        indexes[(normalPointsCount - 2 + i) * 3 + 2] = normalPointsCount + i + 2;
        
//        printf("%d %d %d",normalPointsCount,normalPointsCount + i + 1,normalPointsCount + i + 2);
        
    }
    
//    for (int i = 0; i < self.vertexCount; i++) {
//        printf("<path d=\"M%f %fL%f %fL%f %fZ\" fill=\"#FF8C8C\"/>\n", ver[i].position.x,ver[i].position.y, ver[i + 1].position.x, ver[i + 1].position.y, ver[i + 2].position.x,ver[i + 2].position.y);
//    }
    
    self.indexBuffer =
    [self.mtkView.device newBufferWithLength:self.indexBufferLength
                                    options:MTLResourceStorageModeShared];
    void* indexBufferPointer = [self.indexBuffer contents];
    memcpy(indexBufferPointer, indexes, self.indexBufferLength);
    
//    free(bezierPoints);
//    free(normalPoints);
//    free(indexes);
}

- (void)setupPipeline
{
    id<MTLLibrary> defaultLibrary = [self.mtkView.device newDefaultLibrary]; // .metal
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"]; // 顶点shader，vertexShader是函数名
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"]; // 片元shader，samplingShader是函数名
    
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = self.mtkView.colorPixelFormat;
    self.pipelineState =
    [self.mtkView.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                        error:NULL]; // 创建图形渲染管道，耗性能操作不宜频繁调用
    self.commandQueue = [self.mtkView.device newCommandQueue]; // CommandQueue是渲染指令队列，保证渲染指令有序地提交到GPU
}

static float polygon[100][2];
static int pointCount = 0;

void normalLines(float * normalPoints,
                 int normalPointsCount,
                 float * bezierPoints,
                 int bezierPointsCount,
                 float lineWidth,
                 int * circlePointCount)
{

    for (int i = 0; i < bezierPointsCount - 1; i++)
    {
        float x0 = bezierPoints[i * 2],     y0 = bezierPoints[i * 2 + 1];
        float x1 = bezierPoints[i * 2 + 2], y1 = bezierPoints[i * 2 + 3];
        
        float dx = x1 - x0, dy = y1 - y0;
        float modulusLength = pow(dx * dx + dy * dy, 0.5);
        float normal1_x = - dy * lineWidth / modulusLength + x0;
        float normal1_y =   dx * lineWidth / modulusLength + y0; // PI * (1 / 2)
        float normal2_x =   dy * lineWidth / modulusLength + x0;
        float normal2_y = - dx * lineWidth / modulusLength + y0; // PI * (3 / 2)
        // width
        normalPoints[i * 4]     = normal1_x;
        normalPoints[i * 4 + 1] = normal1_y;
        normalPoints[i * 4 + 2] = normal2_x;
        normalPoints[i * 4 + 3] = normal2_y;
//        printf("%d:(%f, %f)\n", i, x0, y0);
    }
}

void bezier(float x0, float y0,
            float x1, float y1,
            float x2, float y2,
            float x3, float y3)
{
    addPoint(x0, y0);
    recursive_bezier(x0, y0, x1, y1, x2, y2, x3, y3, 0);
    addPoint(x3, y3);
    return;
}

/// 递归求贝塞尔曲线上的点, point | t = 0.5
void recursive_bezier(float x0, float y0,
                      float x1, float y1,
                      float x2, float y2,
                      float x3, float y3,
                      int depth)
{
    if (depth >= 20)
    {
        return;
    }
    float x01 = (x0 + x1) / 2,       y01 = (y0 + y1) / 2;
    float x12 = (x1 + x2) / 2,       y12 = (y1 + y2) / 2;
    float x23 = (x2 + x3) / 2,       y23 = (y2 + y3) / 2;
    float x012 = (x01 + x12) / 2,    y012 = (y01 + y12) / 2;
    float x123 = (x12 + x23) / 2,    y123 = (y12 + y23) / 2;
    float x0123 = (x012 + x123) / 2, y0123 = (y012 + y123) / 2; // point | t = 0.5
    float dx = x3 - x0,              dy = y3 - y0;
    float d1 = fabs((x1 - x3) * dy - (y1 - y3) * dx);
    float d2 = fabs((x2 - x3) * dy - (y2 - y3) * dx);
    
    float m_distance = 1;
    if ((d1 + d2) * (d1 + d2) < m_distance * (dx * dx + dy * dy))
    {
        addPoint(x0123, y0123);
        return;
    }
    recursive_bezier(x0, y0, x01, y01, x012, y012, x0123, y0123, depth + 1);
    recursive_bezier(x0123, y0123, x123, y123, x23, y23, x3, y3, depth + 1);
}

/// 将符合条件的点加入vertex
void addPoint(float x, float y)
{
    polygon[pointCount][0] = x;
    polygon[pointCount][1] = y;
    pointCount++;
}

#pragma mark - delegate

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
{
    self.viewportSize = (vector_float2){size.width, size.height};
}

- (void)drawInMTKView:(MTKView *)view
{
    self.viewportSizeBuffer =
    [self.mtkView.device newBufferWithBytes:&_viewportSize
                                     length:sizeof(_viewportSize)
                                    options:MTLResourceStorageModeShared];
    
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    commandBuffer.label = @"MyCommandBuffer";
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;

    if (renderPassDescriptor != nil)
    {
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1.0f); // 设置默认颜色
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor]; //编码绘制指令的Encoder
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, self.viewportSize.x, self.viewportSize.y, -1.0, 1.0 }]; // 设置显示区域
        [renderEncoder setRenderPipelineState:self.pipelineState]; // 设置渲染管道，以保证顶点和片元两个shader会被调用
        
        [renderEncoder setVertexBuffer:self.viewportSizeBuffer
                                offset:0
                               atIndex:0]; // 尺寸
        [renderEncoder setVertexBuffer:self.vertexBuffer
                                offset:0
                               atIndex:1]; // 设置顶点缓存
        
        [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                                  indexCount:self.indexCount
                                   indexType:MTLIndexTypeUInt32
                                 indexBuffer:self.indexBuffer
                           indexBufferOffset:0];
        
        [renderEncoder endEncoding]; // 结束
        
        [commandBuffer presentDrawable:view.currentDrawable]; // 显示
    }
    [commandBuffer commit];
}

@end
