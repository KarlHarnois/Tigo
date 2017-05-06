import Tigo
import XCTest

final class UIButtonTests: XCTestCase {
  var button: MockButton!

  override func setUp() {
    super.setUp()

    button = MockButton()
  }

  func test_reactive_tap() {
    var wasTapped = false

    button.reactive.tap.onNext {
      wasTapped = true
    }

    button.sendActions(for: .touchUpInside)

    XCTAssert(wasTapped)
  }

  func test_signal_is_retained() {
    weak var signal = button.reactive.tap

    XCTAssertNotNil(signal)
  }

  func test_signal_is_deallocated_when_button_is_nil() {
    let expect = expectation(description: "")
    weak var signal = button.reactive.tap

    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
      expect.fulfill()
    }

    button = nil

    waitForExpectations(timeout: 5) { _ in
      XCTAssertNil(signal)
    }
  }
}

final class MockButton: UIButton {
  /// All actions are normally dispatched through the UIApplication object.
  /// Since we don't have a host application we need to fake the action dispatch.
  override func sendActions(for controlEvents: UIControlEvents) {
    allTargets.forEach { t in
      guard let t = t as? ControlTarget else { return }
      guard controlEvents == t.events else { return }

      t.action()
    }
  }
}
