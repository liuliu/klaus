/**********************************************************
 * Klaus, A state-of-the-art Classifier on iOS
 * Liu Liu, 2014-08-06
 **********************************************************/

#import <Foundation/Foundation.h>

@interface KLAssetsLibraryIndexer : NSObject

@property (nonatomic, readonly, assign) NSUInteger cursor;

- (NSURL *)nextAvailableAssetsURL;

- (void)startWithCompletionHandler:(dispatch_block_t)completionHandler;

- (void)stop;

@end
