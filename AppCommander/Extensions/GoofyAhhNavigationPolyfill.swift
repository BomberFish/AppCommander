// bomberfish
// GoofyAhhNavigationPolyfill.swift – Picasso
// created on 2023-12-10
//
//import SwiftUI
//import NavigationTransitions
//
//public struct Navigator<Content:View>: View {
//    let content: Content
//        
//        init(@ViewBuilder content: () -> Content) {
//            self.content = content()
//        }
//    public var body: some View {
//        if #available(iOS 16.0, *) {
//            if UIAccessibility.isReduceMotionEnabled {
//                NavigationStack {
//                    content
//                }
//            } else {
//                NavigationStack {
//                    content
//                }
//                .navigationTransition(
//                    .slide(axis: .horizontal)
//                    .animation(
//                        .interpolatingSpring(
//                            mass: 1,
//                            stiffness: 250,
//                            damping: 27,
//                            initialVelocity: 1.25
//                        )
//                    )
//                )
//            }
//        } else {
//            if UIAccessibility.isReduceMotionEnabled {
//                NavigationView {
//                    content
//                }
//                .navigationViewStyle(.stack)
//            } else {
//                NavigationView {
//                    content
//                }
//                .navigationViewStyle(.stack)
//                .navigationTransition(
//                    .slide(axis: .horizontal)
//                    .animation(
//                        .interpolatingSpring(
//                            mass: 1,
//                            stiffness: 250,
//                            damping: 27,
//                            initialVelocity: 1.25
//                        )
//                    )
//                )
//            }
//        }
//    }
//}
