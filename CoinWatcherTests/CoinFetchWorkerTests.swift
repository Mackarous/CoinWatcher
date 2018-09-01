import XCTest
@testable import CoinWatcher

struct MockNetwork: Network {
    func fetchData(from url: URL, completion: @escaping (Result<Data>) -> Void) {
        let jsonData = """
        [{
            "id": "bitcoin",
            "name": "Bitcoin",
            "symbol": "BTC",
            "rank": "1",
            "price_usd": "7201.00953586",
            "price_btc": "1.0",
            "24h_volume_usd": "4299612386.34",
            "market_cap_usd": "124174834924",
            "available_supply": "17244087.0",
            "total_supply": "17244087.0",
            "max_supply": "21000000.0",
            "percent_change_1h": "0.23",
            "percent_change_24h": "2.44",
            "percent_change_7d": "6.95",
            "last_updated": "1535827225",
            "price_cad": "9395.51719191",
            "24h_volume_cad": "5609919261.08",
            "market_cap_cad": "162017115867"
        }]
        """.data(using: .utf8)!
        completion(.success(jsonData))
    }
}

class CoinFetchWorkerTests: XCTestCase {
    private let network: Network = MockNetwork()
    
    func testCoinFetchWorker() {
        let coinFetchWorker = CoinFetchWorker(network: network)
        coinFetchWorker.fetchCoins { result in
            switch result {
            case .error(let error):
                XCTFail("Expected success but received error: \(error)")
            case .success(let coins):
                XCTAssertEqual(coins.count, 1)
                XCTAssertEqual(coins.first?.id, "bitcoin")
                XCTAssertEqual(coins.first?.name, "Bitcoin")
            }
        }
    }
}
