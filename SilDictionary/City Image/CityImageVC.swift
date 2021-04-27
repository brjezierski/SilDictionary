//
//  CityImageVC.swift
//  SilDictionary
//
//  Created by Bartek Jezierski on 12/1/18.
//  Copyright © 2018 Bartek Jezierski. All rights reserved.
//

import UIKit

class CityImageVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var descriptionLabel: UILabel!
    
    var pickerData: [String] = [String]()
    var urlInputString: String?
    @IBOutlet weak var imageView: UIImageView!
    let defaultURLInputString = "https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/CoA_of_Upper_Silesia_Province.svg/2000px-CoA_of_Upper_Silesia_Province.svg.png"
    
    let imageHelper = ImageHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.setTitle(NSLocalizedString("str_done", comment: ""), for: .normal)
        descriptionLabel.text = NSLocalizedString("str_cityImageVCDescription", comment: "")
        self.picker.delegate = self
        self.picker.dataSource = self
        pickerData = ["", "Cieszyn","Gliwice","Katowice","Rybnik"]
        urlInputString = defaultURLInputString
        loadRequest()
    }
    
    //MARK: - Picker delegate methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        changURL(for: row)
        loadRequest()
    }

    func changURL(for row: Int) {
        switch row {
            case 1:
            urlInputString = "https://www.mywanderlust.pl/wp-content/uploads/2018/02/cieszyn-poland-duchy-of-cieszyn-42.jpg"
            case 2:
            urlInputString = "https://gliwice.eu/sites/default/files/styles/gliwice_1140x200/public/business_card/images/radiostacja_0.jpg?itok=LNgBrOci"
            case 3:
            urlInputString = "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Katowice.jpg/1200px-Katowice.jpg"
            case 4:
            urlInputString = "https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/Rynek_w_Rybniku_8.JPG/1200px-Rynek_w_Rybniku_8.JPG"
            default:
                break;
        }
    }
    
    func loadRequest() {
        
        if let urlString = urlInputString {
            
            imageHelper.fetchImage(url: urlString) { fetchResult in
                switch fetchResult {
                case let .Success(image):
                    OperationQueue.main.addOperation() {
                        self.imageView.image = image
                    }
                case let .Failure(error):
                    OperationQueue.main.addOperation {
                        self.imageView.image = nil
                    }
                    print("error: \(error)")
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onDone(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSwipe(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left:
            if (picker.selectedRow(inComponent: 0) > 0) {
                picker.selectRow(picker.selectedRow(inComponent: 0)-1, inComponent: 0, animated: true)
                changURL(for: picker.selectedRow(inComponent: 0))
                loadRequest()
            }
        case .right:
            if (picker.selectedRow(inComponent: 0) < picker.numberOfRows(inComponent: 0)) {
                picker.selectRow(picker.selectedRow(inComponent: 0)+1, inComponent: 0, animated: true)
                changURL(for: picker.selectedRow(inComponent: 0))
                loadRequest()
            }
        default:
            break;
        }
    }
    @IBAction func onGo(_ sender: UIButton) {
        loadRequest()
    }
}
