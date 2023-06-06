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
    [self setupVertexes];
}

- (void)setupVertexes
{
    size_t bezierPoints0Size = sizeof(vector_float2) * 100;
    vector_float2 * bezierPoints1 = malloc(bezierPoints0Size);
    vector_float2 * velocity1 = malloc(bezierPoints0Size);
    int bezierPoints1Count = 0;
    {
        vector_float2 P0 = { -300,  300 };
        vector_float2 P1 = {  300,  300 };
        vector_float2 P2 = {  300,    0 };
        vector_float2 P3 = { -300,    0 };
        bezier(P0.x,P0.y, P1.x,P1.y, P2.x,P2.y, P3.x,P3.y, bezierPoints1, velocity1, &bezierPoints1Count);
    }
    // 接下来求法线
    int normalPoints1Count = bezierPoints1Count * 2; // 每个顶点求法线的正反方向, 未做闭合处理的判断
    int normalPoints1Size = bezierPoints1Count * sizeof(vector_float4); // 每个顶点求法线的正反方向
    vector_float4 * normalPoints1 = malloc(normalPoints1Size);
    float lineWidth = 30.0;
    normalLines(normalPoints1, normalPoints1Count, bezierPoints1, velocity1, bezierPoints1Count, lineWidth);
//    for (int i = 0; i < bezierPoints1Count; i++) {
//        printf("(%f, %f) ", bezierPoints1[i].x, bezierPoints1[i].y);
//        printf("(%f, %f) ", velocity1[i].x, velocity1[i].y);
//        printf("(%f, %f, %f, %f)\n", normalPoints1[i].x, normalPoints1[i].y, normalPoints1[i].z, normalPoints1[i].w);
//    }

    vector_float2 * bezierPoints2 = malloc(bezierPoints0Size);
    vector_float2 * velocity2 = malloc(bezierPoints0Size);
    int bezierPoints2Count = 0;
    {
        vector_float2 P0 = { -300,    0 };
        vector_float2 P1 = {    0, -150 };
        vector_float2 P2 = {  300, -300 };
        vector_float2 P3 = {    0, -300 };
        bezier(P0.x,P0.y, P1.x,P1.y, P2.x,P2.y, P3.x,P3.y, bezierPoints2, velocity2, &bezierPoints2Count);
    }
    // 接下来求法线
    int normalPoints2Count = bezierPoints2Count; // 每个顶点求法线的正反方向, 未做闭合处理的判断
    int normalPoints2Size = bezierPoints2Count * sizeof(vector_float4); // 每个顶点求法线的正反方向
    vector_float4 * normalPoints2 = malloc(normalPoints2Size);
    normalLines(normalPoints2, normalPoints2Count, bezierPoints2, velocity2, bezierPoints2Count, lineWidth);
//    for (int i = 0; i < bezierPoints2Count; i++) {
//        printf("(%f, %f) ", bezierPoints2[i].x, bezierPoints2[i].y);
//        printf("(%f, %f) ", velocity2[i].x, velocity2[i].y);
//        printf("(%f, %f, %f, %f)\n", normalPoints2[i].x, normalPoints2[i].y, normalPoints2[i].z, normalPoints2[i].w);
//    }
    
    
    float v1_x = velocity1[bezierPoints1Count-1].x, v1_y = velocity1[bezierPoints1Count-1].y;
    float v2_x = velocity2[0].x, v2_y = velocity2[0].y;
    float cos_angle = (v1_x * v2_x + v1_y * v2_y) / (sqrt(v1_x * v1_x + v1_y * v1_y) * sqrt(v2_x * v2_x + v2_y * v2_y));
    if (cos_angle != 1 && cos_angle != -1)
    {
        // 存在夹角
        float cos_t_angle = (-cos_angle); // 对角余弦
        float sin_t_angle_2 = sqrt((1 - cos_t_angle) / 2);
        float d = lineWidth / sin_t_angle_2;
        
        vector_float2 u0 = bezierPoints2[0];
        vector_float2 u1 = normalPoints1[bezierPoints1Count - 1].xy - u0.xy; // 90
        vector_float2 u2 = normalPoints1[bezierPoints1Count - 1].zw - u0.xy; // 270
        vector_float2 u3 = normalPoints2[0].xy - u0.xy; // 90
        vector_float2 u4 = normalPoints2[0].zw - u0.xy; // 270
        vector_float2 u5 = u1 + u3;
        vector_float2 u6 = u2 + u4;
        float length = sqrt(u5.x * u5.x + u5.y * u5.y);
        u5 = u5 * d / length;
        normalPoints1[bezierPoints1Count].xy = u5 + u0;
        length = sqrt(u6.x * u6.x + u6.y * u6.y);
        u6 = u6 * d / length;
        normalPoints1[bezierPoints1Count].zw = u6 + u0;
        bezierPoints1Count++;
    }
    
    self.vertexCount = (bezierPoints1Count + bezierPoints2Count) * 2;
    self.vertexBufferLength = sizeof(DMVertex) * self.vertexCount;
    self.vertexBuffer =
    [self.mtkView.device newBufferWithLength:self.vertexBufferLength
                                     options:MTLResourceStorageModeShared];
    void* vertexBufferPointer = [self.vertexBuffer contents];
    DMVertex *ver = vertexBufferPointer;
    for (int i = 0; i < bezierPoints1Count; i++)
    {
        ver[i * 2] = (DMVertex){
            { normalPoints1[i].x, normalPoints1[i].y, 0.0, 1.0 }
        };
        ver[i * 2 + 1] = (DMVertex){
            { normalPoints1[i].z, normalPoints1[i].w, 0.0, 1.0 }
        };
    }
    for (int i = 0; i < bezierPoints2Count; i++)
    {
        ver[(i + bezierPoints1Count) * 2] = (DMVertex){
            { normalPoints2[i].x, normalPoints2[i].y, 0.0, 1.0 }
        };
        ver[(i + bezierPoints1Count) * 2 + 1] = (DMVertex){
            { normalPoints2[i].z, normalPoints2[i].w, 0.0, 1.0 }
        };
    }
    
    self.indexCount = (bezierPoints1Count + bezierPoints2Count - 1) * 2 * 3;
    self.indexBufferLength = sizeof(int) * self.indexCount;
    int * indexes = malloc(self.indexBufferLength);
    for (int i = 0; i < (bezierPoints1Count + bezierPoints2Count - 1) * 2; i++) {
        indexes[i * 3]     = i;
        indexes[i * 3 + 1] = i + 1;
        indexes[i * 3 + 2] = i + 2;
//        printf("%d, %d, %d\n", i, i + 1, i + 2);
    }
    self.indexBuffer =
    [self.mtkView.device newBufferWithLength:self.indexBufferLength
                                    options:MTLResourceStorageModeShared];
    void* indexBufferPointer = [self.indexBuffer contents];
    memcpy(indexBufferPointer, indexes, self.indexBufferLength);
    
    return;
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

void normalLines(vector_float4 * normalPoints,
                 int normalPointsCount,
                 vector_float2 * bezierPoints,
                 vector_float2 * velocity,
                 int bezierPointsCount,
                 float lineWidth)
{

    for (int i = 0; i < bezierPointsCount; i++)
    {
        float x0 = bezierPoints[i].x,     y0 = bezierPoints[i].y;
        float dx = velocity[i].x,         dy = velocity[i].y;
        printf("%f, %f\n", dx, dy);
        float normal1_x = - dy * lineWidth + x0;
        float normal1_y =   dx * lineWidth + y0; // PI * (1 / 2)
        float normal2_x =   dy * lineWidth + x0;
        float normal2_y = - dx * lineWidth + y0; // PI * (3 / 2)
        // width
        normalPoints[i] = vector4(normal1_x, normal1_y,
                                  normal2_x, normal2_y);
    }
}

void bezier(float x0, float y0,
            float x1, float y1,
            float x2, float y2,
            float x3, float y3,
            vector_float2 * bezierPoints,
            vector_float2 * velocity,
            int * bezierPoints1Count)
{
    addPoint(x0, y0, bezierPoints, bezierPoints1Count);
    float x = 3 * (x1 - x0), y = 3 * (y1 - y0);
    float length = sqrt(x * x + y * y);
    x /= length;
    y /= length;
    velocity[0] = vector2(x, y);
    recursive_bezier(x0, y0, x1, y1, x2, y2, x3, y3, 0, bezierPoints, velocity, bezierPoints1Count);
    addPoint(x3, y3, bezierPoints, bezierPoints1Count);
    x = 3 * (x3 - x2);
    y = 3 * (y3 - y2);
    length = sqrt(x * x + y * y);
    x /= length;
    y /= length;
    velocity[*bezierPoints1Count - 1] = vector2(x, y);
    return;
}

/// 递归求贝塞尔曲线上的点, point | t = 0.5
void recursive_bezier(float x0, float y0,
                      float x1, float y1,
                      float x2, float y2,
                      float x3, float y3,
                      int depth,
                      vector_float2 * bezierPoints,
                      vector_float2 * velocity,
                      int * bezierPoints1Count)
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
        float v_x = -0.75 * x0 - 0.75 * x1 + 0.75 * x2 + 0.75 * x3;
        float v_y = -0.75 * y0 - 0.75 * y1 + 0.75 * y2 + 0.75 * y3;
        float length = sqrt(v_x * v_x + v_y * v_y);
        v_x /= length;
        v_y /= length;
        velocity[*bezierPoints1Count] = vector2(v_x, v_y);
        addPoint(x0123, y0123, bezierPoints, bezierPoints1Count);
        return;
    }
    recursive_bezier(x0, y0, x01, y01, x012, y012, x0123, y0123, depth + 1, bezierPoints, velocity, bezierPoints1Count);
    recursive_bezier(x0123, y0123, x123, y123, x23, y23, x3, y3, depth + 1, bezierPoints, velocity, bezierPoints1Count);
}

/// 将符合条件的点加入vertex
void addPoint(float x, float y,
              vector_float2 * bezierPoints,
              int * bezierPoints1Count)
{
    bezierPoints[*bezierPoints1Count] = vector2(x, y);
    (*bezierPoints1Count)++;
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
