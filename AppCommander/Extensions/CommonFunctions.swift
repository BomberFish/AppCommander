//
//  CommonFunctions.swift
//  Picasso
//
//  Created by Hariz Shirazi on 2023-08-07.
//

import UIKit

/// Exit app gracefully while doing exploit cleanup.
public func exitApp() {
//    ExploitKit.shared.CleanUp()
    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
        exit(0)
    }
}

public func URLtoTS(_ url: URL?) -> URL {
    return URL(string: "apple-magnifier://install?url=" + (url?.absoluteString ?? "")) ?? .init(string: "apple-magnifier://ballstoreos")!
}

/// Share item with a share sheet.
//public func shareURL(_ url: URL) {
//    let vc = UIActivityViewController(activityItems: [url as Any], applicationActivities: nil)
//    Haptic.shared.notify(.success)
//    vc.isModalInPresentation = true
//    UIApplication.shared.dismissAlert(animated: true)
//    UIApplication.shared.windows[0].rootViewController?.present(vc, animated: true)
//    UIApplication.shared.dismissAlert(animated: true)
//    vc.isModalInPresentation = true
//}

func convertToCCharPointer(_ swiftString: String) -> UnsafeMutablePointer<Int8>? {
    // Convert Swift String to a null-terminated C string (UTF-8 encoded)
    if let cString = swiftString.cString(using: .utf8) {
        // Create a mutable pointer to the C string
        let cCharPointer = UnsafeMutablePointer<Int8>(mutating: cString)
        return cCharPointer
    }
    return nil
}

/// Share items with a share sheet.
func share(_ items: [Any]) {
    let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
    activityViewController.isModalInPresentation = true
    UIApplication.shared.dismissAlert(animated: true) // dismiss any alerts before presenting
    let viewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController // get around the deprecation notice
    viewController?.present(activityViewController, animated: true)
    UIApplication.shared.dismissAlert(animated: true) // just in case
    activityViewController.isModalInPresentation = true // present
}
