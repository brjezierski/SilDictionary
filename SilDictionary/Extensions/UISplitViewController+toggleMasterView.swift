//
//  UISplitViewController+toggleMasterView.swift
//  SilDictionary
//
//  Created by Bartek Jezierski on 12/2/18.
//  Copyright © 2018 Bartek Jezierski. All rights reserved.
//

import UIKit

extension UISplitViewController {
    func toggleMasterView() {
        let barButtonItem = self.displayModeButtonItem
        UIApplication.shared.sendAction(barButtonItem.action!, to: barButtonItem.target, from: nil, for: nil)
    }
}
