//
//  DetailViewController.swift
//  SilDictionary
//
//  Created by Bartek Jezierski on 11/13/18.
//  Copyright © 2018 Bartek Jezierski. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var keyLabel: UILabel!
    @IBOutlet var translationLabel: UILabel!
    @IBOutlet var exampleTitleLabel: UILabel!
    @IBOutlet var exampleSentenceLabel: UILabel!

    func configureView() {
        // Update the user interface for the detail item.
        
        if let entry = entryItem {
            if let firstLabel = keyLabel, let secondLabel = translationLabel, let thirdLabel = exampleTitleLabel, let forthLabel = exampleSentenceLabel {
                firstLabel.text = entry.key
                secondLabel.text = entry.translation
                thirdLabel.text = entry.exampleSentence == "" ? "" : NSLocalizedString("str_exampleTitle", comment: "")
                forthLabel.text = entry.exampleSentence
            }
        }
        else {
            if let firstLabel = keyLabel, let secondLabel = translationLabel, let thirdLabel = exampleTitleLabel, let forthLabel = exampleSentenceLabel {
                firstLabel.text = ""
                secondLabel.text = ""
                thirdLabel.text = ""
                forthLabel.text = ""
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var entryItem: SLPLEntry? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    // MARK: - Gestures
    @IBAction func onSwipe(recognizer: UISwipeGestureRecognizer) {
        switch recognizer.direction {
            case .left:
                print("left")
                //performSegue(withIdentifier: "backSegue", sender: self)
            default: break
        }
    }
}

