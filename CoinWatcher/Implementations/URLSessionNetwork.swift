//
//  URLSessionNetwork.swift
//  CoinWatcher
//
//  Created by Andrew Mackarous on 2018-09-01.
//  Copyright © 2018 Brave. All rights reserved.
//

import Foundation

final class URLSessionNetwork: Network {
    func fetchData(from url: URL, completion: @escaping (Result<Data>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                completion(.success(data))
            } else if let error = error {
                completion(.error(error))
            } else {
                completion(.error(NetworkError.unknown))
            }
        }
        task.resume()
    }
}
