//
//  MicrosoftVisionOCR.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/04/23.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

extension MicrosoftVisionOCR.Orientation {
    init(string: String) throws {
        let value = string.lowercased()
        switch value {
        case "up":
            self = .up
        case "down":
            self = .down
        case "left":
            self = .left
        case "right":
            self = .right
        default:
            throw MicrosoftVisionOCR.Error.parse
        }
    }
}

extension MicrosoftVisionOCR.BoundingBox {
    init(string: String) throws {
        let components = string.components(separatedBy: ",").map({ Int($0)! })
        self.x = components[0]
        self.y = components[1]
        self.width = components[2]
        self.height = components[3]
    }
}

extension MicrosoftVisionOCR.Word {
    init(json: Any) throws {
        guard
            let entities = json as? [String : Any],
            let boundingBox = entities["boundingBox"] as? String,
            let text = entities["text"] as? String
        else {
            throw MicrosoftVisionOCR.Error.parse
        }
        
        self.boundingBox = try MicrosoftVisionOCR.BoundingBox(string: boundingBox)
        self.text = text
    }
}

extension MicrosoftVisionOCR.Line {
    init(json: Any) throws {
        guard
            let entities = json as? [String : Any],
            let boundingBox = entities["boundingBox"] as? String,
            let words = entities["words"] as? [Any]
        else {
            throw MicrosoftVisionOCR.Error.parse
        }
        
        self.boundingBox = try MicrosoftVisionOCR.BoundingBox(string: boundingBox)
        self.words = try words.map({ try MicrosoftVisionOCR.Word(json: $0) })
    }
}

extension MicrosoftVisionOCR.Region {
    init(json: Any) throws {
        guard
            let entities = json as? [String : Any],
            let boundingBox = entities["boundingBox"] as? String,
            let lines = entities["lines"] as? [Any]
        else {
            throw MicrosoftVisionOCR.Error.parse
        }
        
        self.boundingBox = try MicrosoftVisionOCR.BoundingBox(string: boundingBox)
        self.lines = try lines.map({ try MicrosoftVisionOCR.Line(json: $0) })
    }
}

extension MicrosoftVisionOCR.Response {
    init(json: Any) throws {
        guard
            let entities = json as? [String : Any],
            let language = entities["language"] as? String,
            let textAngle = entities["textAngle"] as? Float,
            let orientation = entities["orientation"] as? String,
            let regionsValue = entities["regions"] as? [Any]
        else {
            throw MicrosoftVisionOCR.Error.parse
        }
        
        self.language = language
        self.textAngle = textAngle
        self.orientation = try MicrosoftVisionOCR.Orientation(string: orientation)
        self.regions = try regionsValue.map({ try MicrosoftVisionOCR.Region(json: $0) })
    }
}

public struct MicrosoftVisionOCR {
    
    public enum Error: Swift.Error {
        case parse
        case file(String)
        case field(String)
    }
    
    public enum Orientation {
        case up
        case left
        case down
        case right
    }

    public struct BoundingBox {
        public let x: Int
        public let y: Int
        public let width: Int
        public let height: Int
    }
    
    public struct Word {
        public let boundingBox: BoundingBox
        public let text: String
    }
    
    public struct Line {
        public let boundingBox: BoundingBox
        public let words: [Word]
    }
    
    public struct Region {
        public let boundingBox: BoundingBox
        public let lines: [Line]
    }
    
    public struct Response {
        public let language: String
        public let textAngle: Float
        public let orientation: Orientation
        public let regions: [Region]
    }
    
    //                                     https://eastus2.api.cognitive.microsoft.com/vision/v1.0/ocr[?language][&detectOrientation ]
    private let endpointURL = URL(string: "https://eastus2.api.cognitive.microsoft.com/vision/v1.0/ocr?language=en&detectOrientation=true")!
    
    public typealias Completion = (Response?, Swift.Error?) -> Void
    
    private var key: String
    
    public init() throws {
        try self.init(configFileName: "microsoft-api-config.plist")
    }
    
    public init(configFileName: String) throws {
        let url = Bundle.main.bundleURL.appendingPathComponent(configFileName)
        try self.init(configFile: url)
    }
    
    public init(configFile: URL) throws {
        guard let file = NSDictionary(contentsOf: configFile) else {
            throw Error.file(configFile.absoluteString)
        }
        
        guard let key = file["subscriptionID"] as? String else {
            throw Error.field("subscriptionID")
        }
        
        self.init(key: key)
    }

    public init(key: String) {
        self.key = key
    }
    
    public func annotate(image data: Data, completion: @escaping Completion) {
        let request = makeRequest(data: data)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let response = try Response(json: json)
                completion(response, nil)
            }
            catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    private func makeRequest(data: Data) -> URLRequest {
        var request = URLRequest(url: endpointURL)
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue(key, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.httpMethod = "POST"
        request.httpBody = data
        return request
    }
}
