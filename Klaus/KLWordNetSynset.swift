/**********************************************************
* Klaus, A state-of-the-art Classifier on iOS
* Liu Liu, 2014-08-06
**********************************************************/

import Foundation

@objc
class KLWordNetSynset: NSObject {
  let hypernym: KLWordNetSynset?
  let words: String
  init(hypernym: KLWordNetSynset?, words: String) {
    self.hypernym = hypernym
    self.words = words
  }
}