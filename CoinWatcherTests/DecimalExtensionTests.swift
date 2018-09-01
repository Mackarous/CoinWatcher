import XCTest
@testable import CoinWatcher

class DecimalExtensionTests: XCTestCase {
    func testNumberFormatter() {
        var decimal = Decimal(123.5)
        XCTAssertEqual(decimal.currencyString, "$123.50")
        decimal = 9920.44900239284
        XCTAssertEqual(decimal.currencyString, "$9,920.45")
    }
}
