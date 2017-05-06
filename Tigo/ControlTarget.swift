import UIKit

public final class ControlTarget: NSObject, Disposable {
  public let signal = Signal<Void>()
  public let events: UIControlEvents

  private weak var control: UIControl?

  // MARK: - Disposable

  var isReadyForDisposal: Bool {
    return control == nil
  }

  // MARK: - Init

  init(control: UIControl?, events: UIControlEvents) {
    self.control = control
    self.events = events

    super.init()

    DisposableManager.shared.retain(self)

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
