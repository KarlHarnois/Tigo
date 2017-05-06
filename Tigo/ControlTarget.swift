import UIKit

public final class ControlTarget: NSObject {
  public let signal = Signal<Void>()
  public let events: UIControlEvents

  private weak var control: UIControl?
  private var retainSelf: ControlTarget?

  // MARK: - Init

  init(control: UIControl?, events: UIControlEvents) {
    self.control = control
    self.events = events

    super.init()

    retainSelf = self
    bindTarget()
  }

  // MARK: - Helpers

  private func bindTarget() {
    control?.addTarget(self, action: #selector(ControlTarget.action), for: events)
  }

  public func action() {
    signal.send()
  }
}
