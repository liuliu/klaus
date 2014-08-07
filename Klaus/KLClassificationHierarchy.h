/**********************************************************
 * Klaus, A state-of-the-art Classifier on iOS
 * Liu Liu, 2014-08-06
 **********************************************************/

#import <Foundation/Foundation.h>

@class KLWordNetSynset;

@interface KLClassificationHierarchy : NSObject

- (instancetype)initWithWNID:(NSURL *)WNIDURL synsets:(NSURL *)synsets;

- (KLWordNetSynset *)synset:(NSUInteger)cid;

@end
