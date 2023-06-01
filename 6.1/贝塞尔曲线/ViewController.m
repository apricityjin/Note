//
//  ViewController.m
//  贝塞尔曲线
//
//  Created by apricity on 2023/5/31.
//

#import "ViewController.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import "DMShaderTypes.h"
#import "tesselator.h"

@interface ViewController ()
<MTKViewDelegate>

// view
@property (nonatomic, strong) MTKView *mtkView;

// data
@property (nonatomic, assign) vector_float2 viewportSize;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;
@property (nonatomic, assign) NSUInteger numVertices;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mtkView = [[MTKView alloc] initWithFrame:self.view.bounds];
    self.mtkView.device = MTLCreateSystemDefaultDevice(); // 获取默认的device
    self.view = self.mtkView;
    self.mtkView.delegate = self;
    self.viewportSize = (vector_float2){self.mtkView.drawableSize.width, self.mtkView.drawableSize.height};
    
    [self setupPipeline];
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

#pragma mark - delegate

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
{
    self.viewportSize = (vector_float2){size.width, size.height};
}

- (void)drawInMTKView:(MTKView *)view
{
    pointCount = 0;
    float center_x = 0, center_y = 0;
    {
        vector_float2 P0 = { 79.549, 9.2548 };
        vector_float2 P1 = { 85.0512, -1.89389 };
        vector_float2 P2 = { 100.949, -1.8939};
        vector_float2 P3 = { 106.451, 9.25478 };
        center_x += P0.x;
        center_y += P0.y;
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
        center_x += P0.x;
        center_y += P0.y;
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
        center_x += P0.x;
        center_y += P0.y;
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
        center_x += P0.x;
        center_y += P0.y;
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
        center_x += P0.x;
        center_y += P0.y;
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
    center_x *= 0.2;
    center_y *= 0.2;
    points[pointCount++] = (DMVertex){
        { center_x, center_y ,0 ,1 }
    };
    DMVertex vertexes[pointCount];
    memcpy(vertexes, points, sizeof(DMVertex) * pointCount);
    uint16_t indexes[pointCount * 3 - 6];
    for (int i = 0; i < pointCount - 2; i++) {
        indexes[i * 3 + 0] = pointCount - 1;
        indexes[i * 3 + 1] = i;
        indexes[i * 3 + 2] = i + 1;
    }
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    commandBuffer.label = @"MyCommandBuffer";
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    
    if (renderPassDescriptor != nil)
    {
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1.0f); // 设置默认颜色
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor]; //编码绘制指令的Encoder
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, self.viewportSize.x, self.viewportSize.y, -1.0, 1.0 }]; // 设置显示区域
        [renderEncoder setRenderPipelineState:self.pipelineState]; // 设置渲染管道，以保证顶点和片元两个shader会被调用
        
        
        self.vertexBuffer =
        [self.mtkView.device newBufferWithLength:sizeof(vertexes) + 256
                                        options:MTLResourceStorageModeShared];
        self.numVertices = sizeof(vertexes) / sizeof(DMVertex);
        NSUInteger viewportSize = sizeof(_viewportSize);
        NSUInteger vertexesSize = sizeof(vertexes);
        void* vertexBufferPointer = [self.vertexBuffer contents];
        memcpy(vertexBufferPointer, &_viewportSize, viewportSize);
        memcpy(vertexBufferPointer + 256, vertexes, vertexesSize);
        
        [renderEncoder setVertexBuffer:self.vertexBuffer
                                offset:0
                               atIndex:0]; // 尺寸
        [renderEncoder setVertexBuffer:self.vertexBuffer
                                offset:256
                               atIndex:1]; // 设置顶点缓存
        
        NSUInteger indexesSize = sizeof(indexes);
        id<MTLBuffer> indexBuffer =
        [self.mtkView.device newBufferWithLength:indexesSize
                                         options:MTLResourceStorageModeShared];
        void* indexBufferPointer = [indexBuffer contents];
        memcpy(indexBufferPointer, indexes, indexesSize);
        
//        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip
//                          vertexStart:0
//                          vertexCount:self.numVertices]; // 绘制
        NSUInteger indexCount = indexesSize / sizeof(uint16_t);
        [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangleStrip
                                  indexCount:indexCount
                                   indexType:MTLIndexTypeUInt16
                                 indexBuffer:indexBuffer
                           indexBufferOffset:0];
        
        [renderEncoder endEncoding]; // 结束
        
        [commandBuffer presentDrawable:view.currentDrawable]; // 显示
    }
    [commandBuffer commit];
}

static DMVertex points[500];
static int pointCount = 0;

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
//    NSLog(@"%f\t%f", x, y);
    points[pointCount++] = (DMVertex)
    {
        { x, y, 0, 1 }
    };
}

@end
