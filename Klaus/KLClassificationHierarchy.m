/**********************************************************
 * Klaus, A state-of-the-art Classifier on iOS
 * Liu Liu, 2014-08-06
 **********************************************************/

#import "KLClassificationHierarchy.h"

#import "Klaus-Swift.h"

@interface KLClassificationHierarchy () <NSXMLParserDelegate>

@end

@implementation KLClassificationHierarchy
{
  NSArray *_wnids;
  NSMutableDictionary *_wnidSynsets;
  NSMutableArray *_parsingStack;
}

- (instancetype)initWithWNID:(NSURL *)WNIDURL synsets:(NSURL *)synsets
{
  self = [super init];
  if (self) {
    NSString *wnidList = [NSString stringWithContentsOfURL:WNIDURL encoding:NSUTF8StringEncoding error:nil];
    _wnids = [wnidList componentsSeparatedByString:@"\n"];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:synsets];
    xmlParser.delegate = self;
    _parsingStack = [NSMutableArray array];
    _wnidSynsets = [NSMutableDictionary dictionary];
    [xmlParser parse];
  }
  return self;
}

- (KLWordNetSynset *)synset:(NSUInteger)cid
{
  return _wnidSynsets[_wnids[cid]];
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
  if ([elementName isEqualToString:@"synset"]) {
    NSString *words = attributeDict[@"words"];
    NSString *wnid = attributeDict[@"wnid"];
    KLWordNetSynset *wordNetSynset = [[KLWordNetSynset alloc] initWithHypernym:[_parsingStack lastObject] words:words];
    _wnidSynsets[wnid] = wordNetSynset;
    [_parsingStack addObject:wordNetSynset];
  }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
  if ([elementName isEqualToString:@"synset"]) {
    [_parsingStack removeLastObject];
  }
}

@end
