import UIKit

extension UIButton {
  public var reactive: UIButtonBindings {
    return UIButtonBindings(button: self)
  }
}

public final class UIButtonBindings {
  private weak var button: UIButton?

  init(button: UIButton) {
    self.button = button
  }

  // MARK: - Signal

  public var tap: Signal<Void> {
    let target = ControlTarget(control: button, events: .touchUpInside)

    return target.signal
  }
}
