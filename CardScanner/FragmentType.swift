//
//  FragmentType.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/03/01.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

enum FieldType: Int {
    
    static let all: [FieldType] = [.person, .role, .organization, .department, .phoneNumber, .email, .url, .note, .unknown]

    case unknown = 0
    case person = 1
    case organization = 2
    case phoneNumber = 3
    case email = 4
    case url = 5
    case note = 6
    case role = 8
    case department = 9
}

extension FieldType: CustomStringConvertible {
    var description: String {
        switch self {
        case .unknown:
            return "Untagged"
            
        case .person:
            return "Name"
            
        case .organization:
            return "Organization"
            
        case .phoneNumber:
            return "Phone number"
            
        case .email:
            return "Email"
            
        case .url:
            return "URL"
            
        case .note:
            return "Note"
            
        case .role:
            return "Role"
            
        case .department:
            return "Department"
        }
    }
}
