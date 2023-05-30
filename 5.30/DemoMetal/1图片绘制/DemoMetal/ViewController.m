//
//  ViewController.m
//  DemoMetal
//
//  Created by apricity on 2023/5/30.
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
@property (nonatomic, assign) vector_uint2 viewportSize;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLTexture> texture;
@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;
@property (nonatomic, strong) id<MTLBuffer> indexBuffer;
@property (nonatomic, assign) NSUInteger numVertices;
@property (nonatomic, assign) NSUInteger numIndexes;

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
    self.viewportSize = (vector_uint2){self.mtkView.drawableSize.width, self.mtkView.drawableSize.height};
    [self setupPipeline];
    [self setupVertex];
    [self setupTexture];
}

- (void)setupPipeline
{
    id<MTLLibrary> defaultLibrary = [self.mtkView.device newDefaultLibrary]; // .metal
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"]; // 顶点shader，vertexShader是函数名
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"samplingShader"]; // 片元shader，samplingShader是函数名
    
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = self.mtkView.colorPixelFormat;
    self.pipelineState =
    [self.mtkView.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                        error:NULL]; // 创建图形渲染管道，耗性能操作不宜频繁调用
    self.commandQueue = [self.mtkView.device newCommandQueue]; // CommandQueue是渲染指令队列，保证渲染指令有序地提交到GPU
}

- (void)setupVertex
{
    const static DMVertext vertices[] =
    {
        { { -0.5,  0.5, 0.0, 1.0 },  { 0.f, 1.f } },
        { {  0.5, -0.5, 0.0, 1.0 },  { 1.f, 0.f } },
        { { -0.5, -0.5, 0.0, 1.0 },  { 0.f, 0.f } },
        { {  0.5,  0.5, 0.0, 1.0 },  { 1.f, 1.f } },
    
    };
    const static uint16_t indexes[] =
    {
        0, 1, 2,
        0, 3, 1,
    };
    self.vertexBuffer =
    [self.mtkView.device newBufferWithBytes:vertices
                                     length:sizeof(vertices)
                                    options:MTLResourceStorageModeShared];
    self.numVertices = sizeof(vertices) / sizeof(DMVertext);
    
    self.indexBuffer =
    [self.mtkView.device newBufferWithBytes:indexes
                                     length:sizeof(indexes)
                                    options:MTLResourceStorageModeShared];
    self.numIndexes = sizeof(indexes) / sizeof(uint16_t);
}

- (void)setupTexture {
    UIImage * image = [UIImage imageNamed:@"map"];
    CGImageRef cgImage = image.CGImage;
    
    NSUInteger width = CGImageGetWidth(cgImage);
    NSUInteger height = CGImageGetHeight(cgImage);
    MTLPixelFormat pixelFormat = MTLPixelFormatRGBA8Unorm;

    MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
    textureDescriptor.pixelFormat = pixelFormat;
    textureDescriptor.width = width;
    textureDescriptor.height = height;
    textureDescriptor.usage = MTLTextureUsageShaderRead; // 根据实际需要设置.
    self.texture = [self.mtkView.device newTextureWithDescriptor:textureDescriptor];
    
    size_t bytesPerRow = width * sizeof(uint32_t);
    NSUInteger byteSize = bytesPerRow * height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    UInt8 *imageData = (UInt8 *)malloc(byteSize);
    CGContextRef context =
    CGBitmapContextCreate(imageData,
                          width,
                          height,
                          8, // 每个分量的位数.
                          bytesPerRow,
                          colorSpace,
                          kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);

    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1, -1);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
    
    MTLRegion region = MTLRegionMake2D(0, 0, width, height);
    [self.texture replaceRegion:region
                    mipmapLevel:0
                      withBytes:imageData
                    bytesPerRow:bytesPerRow];

    CGContextRelease(context);
    free(imageData);
}

#pragma mark - delegate

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
{
    self.viewportSize = (vector_uint2){size.width, size.height};
}

- (void)drawInMTKView:(MTKView *)view
{
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    commandBuffer.label = @"MyCommandBuffer";
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    
    if (renderPassDescriptor != nil)
    {
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.5, 0.5, 1.0f); // 设置默认颜色
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor]; //编码绘制指令的Encoder
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, self.viewportSize.x, self.viewportSize.y, -1.0, 1.0 }]; // 设置显示区域
        [renderEncoder setRenderPipelineState:self.pipelineState]; // 设置渲染管道，以保证顶点和片元两个shader会被调用
        
        [renderEncoder setVertexBuffer:self.vertexBuffer
                                offset:0
                               atIndex:0]; // 设置顶点缓存

        [renderEncoder setFragmentTexture:self.texture
                                  atIndex:0]; // 设置纹理
        
//        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
//                          vertexStart:0
//                          vertexCount:self.numVertices]; // 绘制
        [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                                  indexCount:self.numIndexes
                                   indexType:MTLIndexTypeUInt16
                                 indexBuffer:self.indexBuffer
                           indexBufferOffset:0];
        
        [renderEncoder endEncoding]; // 结束
        
        [commandBuffer presentDrawable:view.currentDrawable]; // 显示
    }
    [commandBuffer commit];
}

@end
