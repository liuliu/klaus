/**********************************************************
* Klaus, A state-of-the-art Classifier on iOS
* Liu Liu, 2014-08-06
**********************************************************/

import UIKit

class KLViewController: UIViewController {

  var _classifier: KLHierarchicalClassifier! = nil
  var _classificationHierarchy: KLClassificationHierarchy! = nil
  var _imageView: UIImageView! = nil
  var _moreButton: UIButton! = nil
  var _indexer: KLAssetsLibraryIndexer! = nil
  var _textView: UITextView! = nil
  var _busy = false

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.whiteColor()
    _imageView = UIImageView(frame: CGRectMake(0, 22, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds)))
    _imageView.backgroundColor = UIColor.lightGrayColor()
    
    _moreButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
    _moreButton.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - 100) / 2, CGRectGetMaxY(_imageView.frame) + 20, 100, 40)
    _moreButton.setTitle("More", forState: UIControlState.Normal)
    _moreButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    _moreButton.backgroundColor = UIColor(red: 42.0/255, green: 161.0/255, blue: 152.0/255, alpha: 1)
    _moreButton.addTarget(self, action: "didTapMore:", forControlEvents: UIControlEvents.TouchUpInside)
    
    _textView = UITextView(frame: CGRectMake(5, CGRectGetMaxY(_moreButton.frame) + 10, CGRectGetWidth(self.view.bounds) - 10, CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(_moreButton.frame) - 10))
    _textView.font = UIFont.systemFontOfSize(14)
    _textView.textColor = UIColor(red: 0, green: 43.0/255, blue: 54.0/255, alpha: 1)
    _textView.text = "waiting"
    _textView.textAlignment = NSTextAlignment.Center
    
    self.view.addSubview(_imageView)
    self.view.addSubview(_moreButton)
    self.view.addSubview(_textView)

    // start classifier
    _classifier = KLHierarchicalClassifier()
    let wnid = NSBundle.mainBundle().URLForResource("image-net-2012", withExtension: "wnid", subdirectory: "ccvResources")
    let synsets = NSBundle.mainBundle().URLForResource("image-net-2012", withExtension: "xml", subdirectory: "ccvResources")
    _classificationHierarchy = KLClassificationHierarchy(WNID: wnid, synsets: synsets)
    _indexer = KLAssetsLibraryIndexer()
    _indexer.startWithCompletionHandler({
      dispatch_async(dispatch_get_main_queue(), {
        self._textView.text = "analyzing of \(self._indexer.cursor + 1)"
        self.runClassificationWithURL(self._indexer.nextAvailableAssetsURL())
      })
    })
  }
  
  func runClassificationWithAsset(asset: ALAsset) {
    let fullScreenImage = asset.defaultRepresentation().fullScreenImage().takeUnretainedValue()
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      let width = CGImageGetWidth(fullScreenImage)
      let height = CGImageGetHeight(fullScreenImage)
      let minDim = min(width, height)
      let center = CGImageCreateWithImageInRect(fullScreenImage, CGRectMake(CGFloat(width - minDim) / 2, CGFloat(height - minDim) / 2, CGFloat(minDim), CGFloat(minDim)))
      // crop and then display
      let image = UIImage(CGImage: center)
      let tick = KLTickCount()
      let classificationResult = self._classifier.classify(fullScreenImage) as [KLClassificationResult]
      let elapsedTime = UInt(tick.toc() * 1000 + 0.5)
      dispatch_async(dispatch_get_main_queue(), {
        self._imageView.image = image
        var text: String = "analyzed of \(self._indexer.cursor): \(elapsedTime)ms\n"
        for result: KLClassificationResult in classificationResult {
          var synset = self._classificationHierarchy.synset(result.id)
          var line = "\(synset.words)"
          synset = synset.hypernym
          while synset.hypernym != nil {
            line = "\(synset.words)/\(line)"
            synset = synset.hypernym
          }
          text += "//\(line)\n"
        }
        self._textView.text = text
        self._busy = false
      })
    })
  }

  func runClassificationWithURL(assetURL: NSURL) {
    _busy = true
    let library = ALAssetsLibrary()
    library.assetForURL(assetURL, resultBlock: {
      asset in
      self.runClassificationWithAsset(asset)
    }, failureBlock: {
      error in
    })
  }
  
  func didTapMore(sender: UIButton!) {
    if _busy {
      return
    }
    let assetURL = _indexer.nextAvailableAssetsURL()
    if assetURL != nil {
      _textView.text = "analyzing of \(_indexer.cursor)"
      runClassificationWithURL(assetURL!)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

}

