/**********************************************************
 * Klaus, A state-of-the-art Classifier on iOS
 * Liu Liu, 2014-08-06
 **********************************************************/

#import "KLHierarchicalClassifier.h"

#import <ccv/ccv.h>
#import <ccv/ccv_extra.h>

#import <UIKit/UIKit.h>

#import "Klaus-Swift.h"

@implementation KLHierarchicalClassifier
{
  ccv_convnet_t *_convnet;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    NSURL *imageNet = [[NSBundle mainBundle] URLForResource:@"image-net-2012-mobile" withExtension:@"sqlite3" subdirectory:@"ccvResources"];
    UIImage *layer10Image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"layer-10-4bit" ofType:@"png" inDirectory:@"ccvResources"]];
    UIImage *layer11Image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"layer-11" ofType:@"png" inDirectory:@"ccvResources"]];
    UIImage *layer12Image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"layer-12" ofType:@"png" inDirectory:@"ccvResources"]];
    _convnet = ccv_convnet_read(0, imageNet.fileSystemRepresentation);
    ccv_convnet_read_extra(_convnet, imageNet.fileSystemRepresentation, @{@(10): layer10Image, @(11): layer11Image, @(12): layer12Image});
  }
  return self;
}

- (void)dealloc
{
  ccv_convnet_free(_convnet);
}

- (NSArray *)classify:(CGImageRef)image
{
  int width = CGImageGetWidth(image);
  int height = CGImageGetHeight(image);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(0, width, height, 8, width * 4, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast);
  CGColorSpaceRelease(colorSpace);
  CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
  uint8_t *data = (uint8_t *)CGBitmapContextGetData(context);
  ccv_dense_matrix_t *a = 0;
  ccv_read(data, &a, CCV_IO_RGBA_RAW | CCV_IO_RGB_COLOR, height, width, width * 4);
  CGContextRelease(context);
  ccv_dense_matrix_t *classiable = 0;
  ccv_convnet_input_formation(_convnet, a, &classiable);
  ccv_array_t *ranks = 0;
  ccv_convnet_classify(_convnet, &classiable, 1, &ranks, 5, 1);
  ccv_matrix_free(classiable);
  // collect classification result
  NSMutableArray *classifications = [NSMutableArray array];
  int i;
  for (i = 0; i < ranks->rnum; i++) {
    ccv_classification_t *classification = (ccv_classification_t *)ccv_array_get(ranks, i);
    KLClassificationResult *result = [[KLClassificationResult alloc] initWithId:classification->id confidence:classification->confidence];
    [classifications addObject:result];
  }
  ccv_array_free(ranks);
  return [classifications copy];
}

@end
