//
//  Examples.swift
//  LoafExamples
//
//  Created by Mat Schmid on 2019-02-24.
//  Copyright © 2019 Mat Schmid. All rights reserved.
//

import UIKit
import Loaf

class Examples: UITableViewController {
    
    private enum Example: String, CaseIterable {
        case success  = "An action was successfully completed"
        case error    = "An error has occured"
        case warning  = "A warning has occured"
        case info     = "This is some information"
        
        case bottom   = "This will be shown at the bottom of the view"
        case top      = "This will be shown at the top of the view"
        
        case vertical = "The loaf will be presented and dismissed vertically"
        case left     = "The loaf will be presented and dismissed from the left"
        case right    = "The loaf will be presented and dismissed from the right"
        case mix      = "The loaf will be presented from the left and dismissed vertically"
        
        case custom1  = "This will showcase using custom colors and font"
        case custom2  = "This will showcase using right icon alignment"
        case custom3  = "This will showcase using no icon and 80% screen size width"
        case custom4  = "This will showcase fitting max text width 180pt width"
        case custom5  = "This will showcase background using UIVisualEffect"
        case custom6  = "Shape & border"
        
        static let grouped: [[Example]] = [[.success, .error, .warning, .info],
                                           [.bottom, .top],
                                           [.vertical, .left, .right, .mix],
                                           [.custom1, .custom2, .custom3, custom4, custom5, custom6]]
    }
    
    private var isDarkMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "moon"), style: .done, target: self, action: #selector(toggleDarkMode)),
            UIBarButtonItem(title: "Push", style: .plain, target: self, action: #selector(pushNext))
        ]
        self.navigationItem.leftBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(dismissLoaf)),
            UIBarButtonItem(title: "Pop", style: .plain, target: self, action: #selector(pop))
        ]
    }
    
    @objc private func toggleDarkMode() {
        navigationController?.navigationBar.tintColor    = isDarkMode ? .black : .white
        navigationController?.navigationBar.barTintColor = isDarkMode ? .white : .black
        navigationController?.navigationBar.barStyle     = isDarkMode ? .default : .black
        tableView.backgroundColor                        = isDarkMode ? .groupTableViewBackground : .black
        
        if isDarkMode {
            Loaf("Switched to light mode", state: .custom(.init(background: .color(.black), icon: UIImage(named: "moon"))), sender: self).show(.short)
        } else {
            Loaf("Switched to dark mode", state: .custom(.init(background: .color(.white), textColor: .black, tintColor: .black, icon: UIImage(named: "moon"))), sender: self).show(.short)
        }
        
        tableView.reloadData()
        isDarkMode = !isDarkMode
    }
	
	@objc private func dismissLoaf() {
		// Manually dismisses the currently presented Loaf
		Loaf.dismiss(sender: self)
	}
    
    @objc private func pushNext() {
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "Examples")
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func pop() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Example.grouped.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Example.grouped[section].count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let example = Example.grouped[indexPath.section][indexPath.row]
        switch example {
        case .success:
            Loaf(example.rawValue, state: .success, sender: self).show()
        case .error:
            Loaf(example.rawValue, state: .error, sender: self).show()
        case .warning:
            Loaf(example.rawValue, state: .warning, sender: self).show()
        case .info:
            Loaf(example.rawValue, state: .info, sender: self).show()
            
        case .bottom:
            Loaf(example.rawValue, sender: self).show { dismissalType in
                switch dismissalType {
                case .tapped: print("Tapped!")
                case .timedOut: print("Timmed out!")
                case .programmatically: print("Programmatically!")
                case .dropped(let message): print("Dropped: \(message)")
                }
            }
        case .top:
            Loaf(example.rawValue, location: .top, sender: self).show()
            
        case .vertical:
            Loaf(example.rawValue, sender: self).show(.short)
        case .left:
            Loaf(example.rawValue, presentingDirection: .left, dismissingDirection: .left, sender: self).show(.short)
        case .right:
            Loaf(example.rawValue, presentingDirection: .right, dismissingDirection: .right, sender: self).show(.short)
        case .mix:
            Loaf(example.rawValue, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.short)
            
        case .custom1:
            Loaf(example.rawValue, state: .custom(.init(background: .color(.purple), textColor: .yellow, tintColor: .green, font: .systemFont(ofSize: 18, weight: .bold), icon: Loaf.Icon.success)), sender: self).show()
        case .custom2:
            Loaf(example.rawValue, state: .custom(.init(background: .color(.purple), iconAlignment: .trailing)), sender: self).show()
        case .custom3:
            Loaf(example.rawValue, state: .custom(.init(background: .color(.black), icon: nil, textAlignment: .center, width: .screenPercentage(0.8))), sender: self).show()
        case .custom4:
            Loaf(example.rawValue, state: .custom(.init(background: .color(.black), icon: nil, textAlignment: .center, width: .fittingText(maxTextWidth: 180))), sender: self).show()
        case .custom5:
            Loaf(example.rawValue, state: .custom(.init(background: .visualEffect(UIBlurEffect(style: .regular)), shadow: .init(), textColor: .black, tintColor: .black, textAlignment: .center, width: .fittingText(maxTextWidth: 300))), sender: self).show()
        case .custom6:
            let backgroundView = UIView()
            backgroundView.backgroundColor = .systemBlue
            Loaf(example.rawValue, state: .custom(.init(background: .view(backgroundView), shape: .capsule, stroke: .init(thickness: 1, color: .white), shadow: .init(), textAlignment: .center, width: .fittingText(maxTextWidth: 200))), location: .top, layoutReference: .sender, sender: self).show()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = isDarkMode ? .black : .white
        cell.textLabel?.textColor = isDarkMode ? .white : .darkGray
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = isDarkMode ? .white : .darkGray
    }
}
