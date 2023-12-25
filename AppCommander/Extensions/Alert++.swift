//
//  Alert++.swift
//  PsychicPaper
//
//  Created by Hariz Shirazi on 2023-02-04.
//

import UIKit

// Thanks suslocation!
var currentUIAlertController: UIAlertController?

fileprivate let errorString = NSLocalizedString("Error", comment: "")
fileprivate let okString = NSLocalizedString("OK", comment: "")
fileprivate let cancelString = NSLocalizedString("Cancel", comment: "")

extension UIApplication {
    func dismissAlert(animated: Bool) {
        DispatchQueue.main.async {
            currentUIAlertController?.dismiss(animated: animated)
        }
    }

    func alert(title: String = errorString, body: String, animated: Bool = true, withButton: Bool = true) {
        // ==== do not uncomment ====
//        DispatchQueue.main.async {
            var body = body
            
//            if title == errorString {
//                // append debug info
//                let device = UIDevice.current
//                let systemVersion = device.systemVersion
//                let methods: [String] = ["PhysPuppet", "Smith"]
//                let appVersion = "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""))"
//                body += "\n\n\(device.systemName) \(systemVersion), v\(appVersion), \(ExploitKit.shared.selectedExploit == .kfd ? methods[UserDefaults.standard.integer(forKey: "puafMethod")] : ExploitKit.shared.selectedExploit.rawValue)"
//            }
//            
            currentUIAlertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
            if withButton { currentUIAlertController?.addAction(.init(title: okString, style: .cancel)) }
            currentUIAlertController?.view.tintColor = UIColor(named: "AccentColor")
            self.present(alert: currentUIAlertController!)
//        }
    }
    
    func progressAlert(title: String, body: String = "", animated: Bool = true, noCancel: Bool = true) {
        DispatchQueue.main.async {
            currentUIAlertController = UIAlertController(title: title, message: body + "\n\n\n\n", preferredStyle: .alert)
            
            let indicator = UIActivityIndicatorView(frame: (currentUIAlertController?.view.bounds)!)
            indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            currentUIAlertController?.view.addSubview(indicator)
            indicator.isUserInteractionEnabled = false
            indicator.startAnimating()
            
            if !noCancel { currentUIAlertController?.addAction(.init(title: "Cancel", style: .cancel)) }
            currentUIAlertController?.view.tintColor = UIColor(named: "AccentColor")
            self.present(alert: currentUIAlertController!)
        }
    }
    
    func confirmAlert(title: String = "Confirm", body: String, confirmTitle: String = okString, cancelTitle: String = cancelString, onOK: @escaping () -> (), noCancel: Bool) {
        DispatchQueue.main.async {
            currentUIAlertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
            if !noCancel {
                currentUIAlertController?.addAction(.init(title: cancelTitle, style: .cancel))
            }
            currentUIAlertController?.addAction(.init(title: confirmTitle, style: noCancel ? .cancel : .default, handler: { _ in
                onOK()
            }))
            currentUIAlertController?.view.tintColor = UIColor(named: "AccentColor")
            self.present(alert: currentUIAlertController!)
        }
    }
    
    func choiceAlert(title: String = "Error", body: String, confirmTitle: String = okString, cancelTitle: String = cancelString, yesAction: @escaping () -> (), noAction: @escaping () -> ()) {
        var body = body
        
//        if title == errorString {
//            // append debug info
//            let device = UIDevice.current
//            let systemVersion = device.systemVersion
//            let methods: [String] = ["PhysPuppet", "Smith"]
//            let appVersion = "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""))"
//            body += "\n\n\(device.systemName) \(systemVersion), v\(appVersion), \(ExploitKit.shared.selectedExploit == .kfd ? methods[UserDefaults.standard.integer(forKey: "puafMethod")] : ExploitKit.shared.selectedExploit.rawValue)"
//        }
        DispatchQueue.main.async {
            currentUIAlertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
            currentUIAlertController?.addAction(.init(title: cancelTitle, style: .cancel, handler: { _ in
                noAction()
            }))
            currentUIAlertController?.addAction(.init(title: confirmTitle, style: .default, handler: { _ in
                yesAction()
            }))
            currentUIAlertController?.view.tintColor = UIColor(named: "AccentColor")
            self.present(alert: currentUIAlertController!)
        }
    }
    
    func confirmAlertDestructive(title: String = "Confirm", body: String, onOK: @escaping () -> (), onCancel: @escaping () -> () = {}, destructActionText: String) {
        var body = body
        
//        if title == errorString {
//            // append debug info
//            let device = UIDevice.current
//            let systemVersion = device.systemVersion
//            let methods: [String] = ["PhysPuppet", "Smith"]
//            let appVersion = "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""))"
//            body += "\n\n\(device.systemName) \(systemVersion), v\(appVersion), \(ExploitKit.shared.selectedExploit == .kfd ? methods[UserDefaults.standard.integer(forKey: "puafMethod")] : ExploitKit.shared.selectedExploit.rawValue)"
//        }
        DispatchQueue.main.async {
            currentUIAlertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
            currentUIAlertController?.addAction(.init(title: destructActionText, style: .destructive, handler: { _ in
                onOK()
            }))
            currentUIAlertController?.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in
                onCancel()
            }))
            currentUIAlertController?.view.tintColor = UIColor(named: "AccentColor")
            self.present(alert: currentUIAlertController!)
        }
    }
    
    func change(title: String = "Error", body: String, addCancelWithTitle: String? = nil, onCancel: @escaping () -> () = {}) {
        var body = body
        
//        if title == errorString {
//            // append debug info
//            let device = UIDevice.current
//            let systemVersion = device.systemVersion
//            let methods: [String] = ["PhysPuppet", "Smith"]
//            let appVersion = "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""))"
//            body += "\n\n\(device.systemName) \(systemVersion), v\(appVersion), \(ExploitKit.shared.selectedExploit == .kfd ? methods[UserDefaults.standard.integer(forKey: "puafMethod")] : ExploitKit.shared.selectedExploit.rawValue)"
//        }
        DispatchQueue.main.async {
            currentUIAlertController?.title = title
            currentUIAlertController?.message = body
            if let addCancelWithTitle {
                currentUIAlertController?.addAction(.init(title: addCancelWithTitle, style: .cancel, handler: { _ in
                    onCancel()
                }))
            }
        }
    }

    func changeBody(_ body: String) {
        DispatchQueue.main.async {
            currentUIAlertController?.message = body
        }
    }
    
    func changeTitle(_ title: String) {
//        if title == errorString {
//            // append debug info
//            let device = UIDevice.current
//            let systemVersion = device.systemVersion
//            let methods: [String] = ["PhysPuppet", "Smith"]
//            let appVersion = "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""))"
//            if currentUIAlertController?.message != nil {
//                currentUIAlertController?.message! += "\n\n\(device.systemName) \(systemVersion), v\(appVersion), \(ExploitKit.shared.selectedExploit == .kfd ? methods[UserDefaults.standard.integer(forKey: "puafMethod")] : ExploitKit.shared.selectedExploit.rawValue)"
//            }
//        }
        DispatchQueue.main.async {
            currentUIAlertController?.title = title
        }
    }
    
    func present(alert: UIAlertController) {
        if var topController = windows[0].rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.present(alert, animated: true)
            // topController should now be your topmost view controller
        }
    }
}
