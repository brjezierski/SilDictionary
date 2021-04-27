//
//  AppDelegate.swift
//  SilDictionary
//
//  Created by Bartek Jezierski on 11/13/18.
//  Copyright © 2018 Bartek Jezierski. All rights reserved.
//

import UIKit

enum URLError: Error {
    case BadURL
    case NotImplementedYet
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    var dictionary: SLPLDictionary!
    var dictionaryLibraryFileName = "SLPLDictionaryFile"

    lazy var fileURL: URL = {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDir.appendingPathComponent(dictionaryLibraryFileName, isDirectory: false)
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if UserDefaults.standard.integer(forKey: dNumLaunches) == 0 {
            UserDefaults.standard.set(1, forKey: dNumLaunches)
        }
        loadData()
        
        let splitViewController = window!.rootViewController as! UISplitViewController
        
        // master
        let masterNavController = splitViewController.viewControllers.first as! UINavigationController
        if let masterViewController = masterNavController.topViewController as? MasterViewController {
            masterViewController.dictionary = dictionary
        }
        
        let detailNavController = splitViewController.viewControllers.last as! UINavigationController
        detailNavController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        
        splitViewController.delegate = self
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        let numLaunches = UserDefaults.standard.integer(forKey: dNumLaunches) + 1
        UserDefaults.standard.set(numLaunches, forKey: dNumLaunches)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.current
        
        let accessDate = dateFormatter.string(from: Date())
        
        UserDefaults.standard.set(accessDate, forKey: dAccessDate)
        saveData()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveData()
    }

    // MARK: - Split view
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.entryItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
    
    // MARK - Persistence Methods
    
    func saveData() {
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        
        if let encodedData = try? JSONEncoder().encode(dictionary) {
            FileManager.default.createFile(atPath: fileURL.path, contents: encodedData, attributes: nil)
        } else {
            fatalError("Couldn't write data!")
        }
    }
    
    func loadData() {
        
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            dictionary = SLPLDictionary()
            if let corpora = loadFromFile(with: "SLPLcorpus", of: "txt") {
                convertToDictionary(data: corpora)
            }
            return
        }
        
        if let jsondata = FileManager.default.contents(atPath: fileURL.path) {
            let decoder = JSONDecoder()
            do {
                dictionary = try decoder.decode(SLPLDictionary.self, from: jsondata)
            } catch {
                fatalError(error.localizedDescription)
            }
        } else {
            fatalError("No data at \(fileURL.path)!")
        }
    }
    func loadFromFile(with name: String, of type: String) -> String? {
        if let filepath = Bundle.main.path(forResource: name, ofType: type) {
            do {
                let contents = try String(contentsOfFile: filepath)
                return contents
            } catch {
                print(error)
                return nil
            }
        } else {
            print("\(name).\(type) not found.")
            return nil
        }
    }
    
    func convertToDictionary(data: String) {
        let dataLines = data.components(separatedBy: .newlines)
        for line in dataLines {
            let entryPair = line.split(separator: "-")
            if (entryPair.count == 2) {
                let key = String(entryPair[0])
                var translation = String(entryPair[1])
                var example = ""
                let translationComponents = translation.components(separatedBy: "np.")
                if (translationComponents.count >= 2) {
                    for entry in translation.components(separatedBy: "np."){
                        print(entry)
                    }

                    translation = String(translationComponents[0])
                    example = String(translationComponents[1].dropFirst())

                }
                dictionary.addEntry(silesianWord: String(key.dropLast()), polishWord: String(translation.dropFirst()), exampleSentence: example)
            }
            }
        }
    }

