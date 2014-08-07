/**********************************************************
 * Klaus, A state-of-the-art Classifier on iOS
 * Liu Liu, 2014-08-06
 **********************************************************/

import Foundation

@objc
class KLClassificationResult: NSObject {
  let id: UInt
  let confidence: Float
  init(id: UInt, confidence: Float) {
    self.id = id
    self.confidence = confidence
  }
}
