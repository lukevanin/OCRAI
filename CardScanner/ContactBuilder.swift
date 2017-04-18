//
//  ContactBuilder.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/03/20.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import Contacts

class ContactBuilder {
    
    private var contact = CNMutableContact()
    
    func build() -> CNContact {
        return contact.copy() as! CNContact
    }
    
    func addOrganization(_ organization: String) {
        contact.organizationName = organization
        contact.contactType = .organization
    }
    
    func addPerson(_ name: String) {
        contact.givenName = name
        contact.contactType = .person
    }
    
    func addPhoneNumbers(_ values: [String]) {
        contact.phoneNumbers = values.map {
            CNLabeledValue(
                label: nil,
                value: CNPhoneNumber(stringValue: $0)
            )
        }
    }
    
    func addURLAddresses(_ values: [String]) {
        contact.urlAddresses = values.map {
            CNLabeledValue(
                label: nil,
                value: $0 as NSString
            )
        }
    }
    
    func addEmailAddresses(_ values: [String]) {
        contact.emailAddresses = values.map {
            CNLabeledValue(
                label: nil,
                value: $0 as NSString
            )
        }
    }
    
    func addPostalAddresses(_ values: [String]) {
        contact.postalAddresses = values.flatMap {
            guard let address = self.parseAddress($0).first else {
                return nil
            }
            
            return CNLabeledValue(
                label: nil,
                value: address
            )
        }
    }
    
    private func parseAddress(_ input: String) -> [CNPostalAddress] {
        let types: NSTextCheckingResult.CheckingType = [.address]
        guard let detector = try? NSDataDetector(types: types.rawValue) else {
            return []
        }
        let range = NSRange(
            location: 0,
            length: input.characters.count
        )
        let matches = detector.matches(in: input, options: [], range: range)
        let addresses = matches.flatMap() { $0.addressComponents }
        return addresses.flatMap {
            return CNMutablePostalAddress(addressDictionary: $0)
        }
    }
}

extension ContactBuilder {
    
    func addOrganization(fields: [Field]) {
        if let organization = fields.first?.value {
            addOrganization(organization)
        }
    }
    
    func addPerson(fields: [Field]) {
        if let name = fields.first?.value {
            addPerson(name)
        }
    }
    
    func addPhoneNumbers(fields: [Field]) {
        let values = fields.flatMap({ $0.value })
        addPhoneNumbers(values)
    }
    
    func addURLAddresses(fields: [Field]) {
        let values = fields.flatMap({ $0.value })
        addURLAddresses(values)
    }
    
    func addEmailAddresses(fields: [Field]) {
        let values = fields.flatMap({ $0.value })
        addEmailAddresses(values)
    }
    
    func addPostalAddresses(fields: [Field]) {
        let values = fields.flatMap({ $0.value })
        addPostalAddresses(values)
    }

}
