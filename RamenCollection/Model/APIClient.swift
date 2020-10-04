//
//  APIClient.swift
//  RamenCollection
//
//  Created by tomoya tanaka on 2020/10/04.
//  Copyright © 2020 Tomoya Tanaka. All rights reserved.
//

import Foundation
class APIClient {
    func request<T: Requestable>(_ requestable: T, completion: @escaping(T.Model?) -> T.Model) {
        guard let request = requestable.urlRequest else { return }
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in

            if let error = error {
                print("クライアントエラー: \(error.localizedDescription) \n")
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse else {
                print("no data or no response")
                return
            }

            if response.statusCode == 200 {
                let model = try? requestable.decode(from: data)
                completion(model)
            } else {
                // レスポンスのステータスコードが200でない場合などはサーバサイドエラー
                print("サーバエラー ステータスコード: \(response.statusCode)\n")
            }
        })
        task.resume()
    }
    
}


protocol Requestable {
    associatedtype Model
    var url: String { get }
    var httpMethod: String { get }
    func decode(from data: Data) throws -> Model
}

extension Requestable {
    
    var urlRequest: URLRequest? {
        guard let url = URL(string: url) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        return request
    }
    
}

struct Test: Codable {
    var test: String
}

struct TestRequest: Requestable {
    typealias Model = Test
    
    var url: String {
        return "https://ramen-collection-api.herokuapp.com/api/v1/test"
    }
    
    var httpMethod: String {
        return "GET"
    }
    
    func decode(from data: Data) throws -> Test {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Test.self, from: data)
    }
}





