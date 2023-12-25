//
//  Respring.swift
//  Picasso
//
//  Created by sourcelocation on 04/08/2023.
//

import Dynamic
import SwiftUI
import UIKit

enum RespringType: String {
    case frontboard, backboard
}

func preferenceToRespringType() -> RespringType {
    if UserDefaults.standard.string(forKey: "RespringType") ?? "Frontboard" == "Backboard" {
        return .backboard
    } else {
        return .frontboard
    }
}

fileprivate func doWithFadeOut(_ action: @escaping () -> Void) {
    let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1) {
        let windows: [UIWindow] = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)

        for window in windows {
            window.alpha = 0
            window.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }

    // create new window
    let respringWindow = UIWindow(frame: UIScreen.main.bounds)
    respringWindow.rootViewController = UIHostingController(rootView: RespringView())
    respringWindow.rootViewController?.view.frame = UIScreen.main.bounds
    respringWindow.windowLevel = .alert + 1
    respringWindow.makeKeyAndVisible()

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
        action()
    }

    animator.startAnimation()
    respringWindow.makeKeyAndVisible()
}

func respring(type: RespringType = preferenceToRespringType()) {
    Haptic.shared.play(.soft)

    doWithFadeOut {
        if type == .backboard {
            restartBackboard()
        } else {
            restartFrontboard()
        }

//        if UserDefaults.standard.bool(forKey: "aggressiveApplying") {
//            var n = 0
//            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
//                n += 1
//
//                try? TweakApplier.shared.applyTweaks()
//
//                if n > 10 {
//                    ExploitKit.shared.CleanUp()
//                    exit(0)
//                }
//            }
//        } else {
//            ExploitKit.shared.CleanUp()
//            exit(0)
//        }
        exit(0)
    }
}

func reboot() {
    Haptic.shared.play(.soft)
    
    doWithFadeOut {
//        ExploitKit.shared.CleanUp()
        userspaceReboot()
    }
}

var iconservicesConnection: NSXPCConnection?
func removeIconCache() {
    if iconservicesConnection == nil {
        let myCookieInterface = NSXPCInterface(with: ISIconCacheServiceProtocol.self)
        iconservicesConnection = Dynamic.NSXPCConnection(machServiceName: "com.apple.iconservices", options: [])
        iconservicesConnection!.remoteObjectInterface = myCookieInterface
        iconservicesConnection!.resume()
    }

    (iconservicesConnection!.remoteObjectProxy as AnyObject).clearCachedItems(forBundeID: nil) { _, _ in
    }
}

// wtf is this :nfr:
private struct RespringView: View {
    var body: some View {
        VStack {
            Image("picasso-glyph")
                .resizable()
                .frame(width: 48, height: 48)

            ProgressView()

            Image("picasso-glyph")
                .resizable()
                .frame(width: 48, height: 48)
                .hidden()
        }
    }
}
