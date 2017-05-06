import Foundation

protocol Disposable: class {
  var isReadyForDisposal: Bool { get }
}

final class DisposableManager: NSObject {
  static let shared = DisposableManager()

  private var timer: Timer?
  private var disposables: [Disposable] = []

  override init() {
    super.init()

    timer = Timer.scheduledTimer(timeInterval: 0.4,
                                 target: self,
                                 selector: #selector(DisposableManager.performReleases),
                                 userInfo: nil,
                                 repeats: true)
  }

  func retain(_ disposable: Disposable) {
    disposables.append(disposable)
  }

  func performReleases() {
    DispatchQueue.global(qos: .background).async {
      self.disposables = self.disposables.filter { !$0.isReadyForDisposal }
    }
  }
}
