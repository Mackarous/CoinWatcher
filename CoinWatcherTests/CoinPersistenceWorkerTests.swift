import XCTest
@testable import CoinWatcher

class CoinPersistenceWorkerTests: XCTestCase {
    
    func testCoinPersistenceWorker() {
        let coinPersistenceWorker = CoinPersistenceWorker()
        let testId = "test_coin"
       
        let nilCoin = coinPersistenceWorker.coin(id: testId)
        XCTAssertNil(nilCoin)
        
        coinPersistenceWorker.insertNewFavoriteCoin(id: testId)
        let existingCoin = coinPersistenceWorker.coin(id: testId)
        XCTAssertNotNil(existingCoin)
        XCTAssertEqual(existingCoin?.coinId, testId)
        XCTAssertEqual(existingCoin?.isFavorited, true)
        
        coinPersistenceWorker.removeFavoriteCoin(id: testId)
        let finalNilCoin = coinPersistenceWorker.coin(id: testId)
        XCTAssertNil(finalNilCoin)
    }
}
