import Tigo
import XCTest

final class UILabelTests: XCTestCase {
  var label: UILabel!
  var retainCycleTester: Container?

  override func setUp() {
    label = UILabel()
    retainCycleTester = Container()
  }

  // MARK: - text Test

  func test_text() {
    let cuteDogName = Signal<String>()

    label.reactive.text <- cuteDogName

    cuteDogName.send("Tigo")

    XCTAssertEqual(label.text, "Tigo")
  }

  func test_binding_to_text_does_not_create_retain_cycle() {
    let signal = Signal<String>()
    let exp = expectation(description: "exp")

    retainCycleTester?.deinitCallback = {
      exp.fulfill()
    }

    weak var label = retainCycleTester?.label

    retainCycleTester!.label.reactive.text <- signal

    removeReferenceToContainer()

    waitForExpectations(timeout: 5) { _ in
      XCTAssertNil(self.retainCycleTester)
      XCTAssertNil(label)
    }
  }

  // MARK: - isHidden Tests

  func test_isHidden() {
    let tigoIsHidden = Signal<Bool>()

    label.reactive.isHidden <- tigoIsHidden

    tigoIsHidden.send(true)
    XCTAssertTrue(label.isHidden)

    tigoIsHidden.send(false)
    XCTAssertFalse(label.isHidden)
  }

  func test_binding_to_isHidden_does_not_retain_label() {
    let signal = Signal<Bool>()
    let exp = expectation(description: "exp")

    retainCycleTester?.deinitCallback = {
      exp.fulfill()
    }

    weak var label = retainCycleTester?.label

    retainCycleTester!.label.reactive.isHidden <- signal

    removeReferenceToContainer()

    waitForExpectations(timeout: 5) { _ in
      XCTAssertNil(self.retainCycleTester)
      XCTAssertNil(label)
    }
  }

  // MARK: - Helpers

  private func removeReferenceToContainer() {
    DispatchQueue.global(qos: .background).async {
      self.retainCycleTester = nil
    }
  }

  final class Container {
    let label = UILabel()
    var deinitCallback: (() -> Void)?

    deinit {
      deinitCallback?()
    }
  }
}
