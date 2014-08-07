/**********************************************************
 * Klaus, A state-of-the-art Classifier on iOS
 * Liu Liu, 2014-08-06
 **********************************************************/

#import "KLTickCount.h"

#import <QuartzCore/QuartzCore.h>

@implementation KLTickCount
{
  double _elapsedTime;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _elapsedTime = CACurrentMediaTime();
  }
  return self;
}

- (double)toc
{
  return CACurrentMediaTime() - _elapsedTime;
}

@end
