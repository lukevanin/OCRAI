//
//  MonkeyLearnEntitiesAPI.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/26.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

public struct MonkeyLearnEntitiesAPI {
    
    public enum Error: Swift.Error {
        case parse
    }
    
    public enum Tag: String {
        case person = "PERSON"
        case organization = "ORGANIZATION"
        case location = "LOCATION"
    }
    
    public struct Entity {
        public let count: Int
        public let tag: Tag
        public let value: String
        init(json: Any) throws {
            guard
                let content = json as? [String: Any],
                let count = content["count"] as? Int,
                let tagValue = content["tag"] as? String,
                let tag = Tag(rawValue: tagValue),
                let value = content["entity"] as? String
            else {
                throw Error.parse
            }
            self.count = count
            self.tag = tag
            self.value = value
        }
    }
    
    public struct Response {
        public let entities: [Entity]
        init(json: Any) throws {
            guard
                let container = json as? [String: Any],
                let results = container["result"] as? [Any],
                let entities = results.first as? [Any]
            else {
                throw Error.parse
            }
            self.entities = try entities.map { try Entity(json: $0) }
        }
    }
    
    public typealias Completion = (Response?, Swift.Error?) -> Void
    
    private let account: String
    private let authorizationToken: String
    private let session: URLSession
    
    public init(account: String, authorizationToken: String, session: URLSession? = nil) {
        self.account = account
        self.authorizationToken = authorizationToken
        self.session = session ?? URLSession.shared
    }
    
    public func fetchEntities(text: String, completion: @escaping Completion) -> URLSessionTask {
        let json = [
            "text_list": [
                text
            ]
        ]
        let request = makeRequest(json)
        let task = session.dataTask(with: request) { (data, _, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let response = try self.parseResponse(json)
                completion(response, nil)
            }
            catch {
                print("Error in response: \(error)")
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
    
    private func makeRequest(_ json: Any) -> URLRequest {
        let url = URL(string: "https://api.monkeylearn.com/v2/extractors/\(account)/extract/")!
        var output = URLRequest(url: url)
        output.addValue("Token \(authorizationToken)", forHTTPHeaderField: "Authorization")
        output.addValue("application/json", forHTTPHeaderField: "Content-Type")
        output.httpMethod = "POST"
        output.httpBody = try! JSONSerialization.data(withJSONObject: json, options: [])
        return output as URLRequest
    }
    
    private func parseResponse(_ json: Any) throws -> Response {
        return try Response(json: json)
    }
}
