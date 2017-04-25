import UIKit

extension UILabel {
  public var tigo: (text: Observer<String>, isHidden: Observer<Bool>) {
    return (
      text: Observer { [weak self] value in
        self?.text = value
      },
      isHidden: Observer { [weak self] value in
        self?.isHidden = value
      }
    )
  }
}
