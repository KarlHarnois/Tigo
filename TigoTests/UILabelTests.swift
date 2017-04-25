import Tigo
import XCTest

final class UILabelTests: XCTestCase {
  var label: UILabel!

  override func setUp() {
    label = UILabel()
  }

  func test_text() {
    let cuteDogName = Signal<String>()

    label.tigo.text <- cuteDogName

    cuteDogName.send("Tigo")

    XCTAssertEqual(label.text, "Tigo")
  }


  func test_isHidden() {
    let tigoIsHidden = Signal<Bool>()

    label.tigo.isHidden <- tigoIsHidden

    tigoIsHidden.send(true)
    XCTAssertTrue(label.isHidden)

    tigoIsHidden.send(false)
    XCTAssertFalse(label.isHidden)
  }
}
