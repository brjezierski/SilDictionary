//
//  SLPLEntry.swift
//  SilDictionary
//
//  Created by Bartek Jezierski on 11/16/18.
//  Copyright © 2018 Bartek Jezierski. All rights reserved.
//

class SLPLEntry: Codable {

    var key: String
    var translation: String
    var exampleSentence: String
    
    var letterIndex: Character?
    var addedByUser = false
    
    init(key: String, translation: String, exampleSentence: String) {
        self.key = key
        self.translation = translation
        self.exampleSentence = exampleSentence
        self.letterIndex = key.lowercased().first
    }
    
    convenience init(key: String, translation: String) {
        self.init(key: key, translation: translation, exampleSentence: "")
    }
    
    convenience init(key: String, translation: String, addedByUser: Bool) {
        self.init(key: key, translation: translation)
        self.addedByUser = addedByUser
    }
    
    convenience init(key: String, translation: String, exampleSentence: String, addedByUser: Bool) {
        self.init(key: key, translation: translation, exampleSentence: exampleSentence)
        self.addedByUser = addedByUser
    }
    
    // MARK: - Making codable

    enum CodingKeys: String, CodingKey {
        case letterIndex, key, translation, exampleSentence, addedByUser
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        letterIndex = try container.decodeIfPresent(String.self, forKey: .letterIndex)?.first
        self.key = try container.decode(String.self, forKey: .key)
        translation = try container.decode(String.self, forKey: .translation)
        exampleSentence = try container.decode(String.self, forKey: .exampleSentence)
        addedByUser = try container.decode(Bool.self, forKey: .addedByUser)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let String_letterIndex = letterIndex != nil ? String(letterIndex!) : nil
        try container.encode(String_letterIndex, forKey: .letterIndex)
        try container.encode(self.key, forKey: .key)
        try container.encode(translation, forKey: .translation)
        try container.encode(exampleSentence, forKey: .exampleSentence)
        try container.encode(addedByUser, forKey: .addedByUser)
    }

}
