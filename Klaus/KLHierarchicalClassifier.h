/**********************************************************
 * Klaus, A state-of-the-art Classifier on iOS
 * Liu Liu, 2014-08-06
 **********************************************************/

#import <Foundation/Foundation.h>

#import <CoreGraphics/CoreGraphics.h>

@interface KLHierarchicalClassifier : NSObject

- (NSArray *)classify:(CGImageRef)image;

@end