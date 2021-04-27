//
//  SLPLDictionary.swift
//  SilDictionary
//
//  Created by Bartek Jezierski on 11/16/18.
//  Copyright © 2018 Bartek Jezierski. All rights reserved.
//

let dNumLaunches        = "num_launches"
let dAccessDate         = "access_date"

class SLPLDictionary: Codable {
    
    var alphabet = "abcćdefghijklłmnńoqprsśtuwxyzźż"
    var sectionedEntries: [Character: [SLPLEntry]]
    var directionIsSilesianToPolish = true {
        didSet{
            updateAfterDirectionChanged()
        }
    }

    init() {
        sectionedEntries = [Character: [SLPLEntry]]()
    }
    
    func addEntry(silesianWord: String, polishWord: String) {
        let entry: SLPLEntry
        if (directionIsSilesianToPolish) {
            entry = SLPLEntry(key: silesianWord, translation: polishWord, addedByUser: true)
        }
        else {
            entry = SLPLEntry(key: polishWord, translation: silesianWord, addedByUser: true)
        }
        updateSectionedEntries(entry: entry)
    }
    
    func addEntry(silesianWord: String, polishWord: String, exampleSentence: String) {
        let entry = SLPLEntry(key: silesianWord, translation: polishWord, exampleSentence: exampleSentence)
        if (entry.letterIndex == nil) {
            return
        }
        updateSectionedEntries(entry: entry)
    }
    
    func updateSectionedEntries(entry: SLPLEntry) {
        var entries = sectionedEntries[entry.letterIndex!]
        if (entries == nil) {
            entries = [SLPLEntry]()
        }
        entries?.append(entry)
        entries = entries?.sorted {$0.key.lowercased() < $1.key.lowercased()}
        sectionedEntries[entry.letterIndex!] = entries
    }
    
    func updateAfterDirectionChanged() {
        var copySectionedEntries = sectionedEntries
        sectionedEntries = [Character: [SLPLEntry]]()

        for section in copySectionedEntries.keys {
            for entry in copySectionedEntries[section]! {
                let inverseEntry = SLPLEntry(key: entry.translation, translation: entry.key, exampleSentence: entry.exampleSentence, addedByUser: entry.addedByUser)
                updateSectionedEntries(entry: inverseEntry)
            }
        }
    }
    
    func removeEntry(from section: Int, at index: Int) {
        var temp = sectionedEntries[alphabet.charAt(section)]
        temp?.remove(at: index)
        sectionedEntries[alphabet.charAt(section)] = temp
    }
    
    func sortEntries(_ entries: [SLPLEntry?]) -> [Character: [SLPLEntry?]] {
        var sectioned = [Character: [SLPLEntry?]]()
        for char in alphabet {
            sectioned[char] = entries.filter({ ($0?.letterIndex)! == char})
        }
        return sectioned
    }
    
    // MARK: - Making codable
    
    enum CodingKeys: String, CodingKey {
        case alphabet, sectionedEntries, directionIsSilesianToPolish
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sectionedEntries = [Character: [SLPLEntry]]()

        alphabet = try container.decode(String.self, forKey: .alphabet)
        let String_sectionedEntries = try container.decode([String: [SLPLEntry]].self, forKey: .sectionedEntries)
        for el in String_sectionedEntries.keys {
            sectionedEntries[el.first!] = String_sectionedEntries[el]
        }
        directionIsSilesianToPolish = try container.decode(Bool.self, forKey: .directionIsSilesianToPolish)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var String_sectionedEntries = [String: [SLPLEntry]]()
        for el in sectionedEntries.keys {
            String_sectionedEntries[String(el)] = sectionedEntries[el]
        }
        try container.encode(alphabet, forKey: .alphabet)
        try container.encode(String_sectionedEntries, forKey: .sectionedEntries)
        try container.encode(directionIsSilesianToPolish, forKey: .directionIsSilesianToPolish)
    }
}
