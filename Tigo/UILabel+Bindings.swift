import UIKit

extension UILabel {
  public var reactive: UILabelBindings {
    return UILabelBindings(label: self)
  }
}

public struct UILabelBindings {
  private weak var label: UILabel?

  init(label: UILabel?) {
    self.label = label
  }

  // MARK: - Observers

  public var text: Observer<String> {
    return Observer { value in
      self.label?.text = value
    }
  }

  public var isHidden: Observer<Bool> {
    return Observer { value in
      self.label?.isHidden = value
    }
  }

  public var alpha: Observer<CGFloat> {
    return Observer { value in
      self.label?.alpha = value
    }
  }
}
