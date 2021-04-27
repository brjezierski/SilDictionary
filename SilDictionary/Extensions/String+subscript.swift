//
//  String+subscript.swift
//  SilDictionary
//
//  Created by Bartek Jezierski on 11/16/18.
//  Copyright © 2018 Bartek Jezierski. All rights reserved.
//

import Foundation

extension String {
    public func charAt (_ i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}
