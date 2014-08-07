/**********************************************************
 * Klaus, A state-of-the-art Classifier on iOS
 * Liu Liu, 2014-08-06
 **********************************************************/

#import "KLAssetsLibraryIndexer.h"

#import <AssetsLibrary/AssetsLibrary.h>

@implementation KLAssetsLibraryIndexer
{
  dispatch_queue_t _indexQueue;
  NSArray *_assetURLsAndDates;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _indexQueue = dispatch_queue_create("com.klaus.indexer", DISPATCH_QUEUE_SERIAL);
  }
  return self;
}

- (NSURL *)nextAvailableAssetsURL
{
  if (_assetURLsAndDates) {
    NSUInteger cursor = _cursor;
    ++_cursor;
    if (_cursor >= _assetURLsAndDates.count) {
      _cursor = 0;
    }
    if (cursor < _assetURLsAndDates.count) {
      return _assetURLsAndDates[cursor][ALAssetPropertyAssetURL];
    }
  }
  return nil;
}

- (void)startWithCompletionHandler:(dispatch_block_t)completionHandler
{
  dispatch_async(_indexQueue, ^{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSMutableArray *assetURLsAndDates = [NSMutableArray array];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                             if (group) {
                               [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                               if (group.numberOfAssets > 0) {
                                 [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop2) {
                                   if (asset) {
                                     [assetURLsAndDates addObject:@{ALAssetPropertyDate:[asset valueForProperty:ALAssetPropertyDate], ALAssetPropertyAssetURL:[asset valueForProperty:ALAssetPropertyAssetURL]}];
                                   } else {
                                     // dispatch processing to another thread (this is on main thread)
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                       _assetURLsAndDates = [assetURLsAndDates copy];
                                       completionHandler();
                                     });
                                   }
                                 }];
                               }
                               *stop = YES;
                             }
                           }
                         failureBlock:^(NSError *error) {
                           // need to handle error properly
                         }];
  });
}

- (void)stop
{
  
}

@end
