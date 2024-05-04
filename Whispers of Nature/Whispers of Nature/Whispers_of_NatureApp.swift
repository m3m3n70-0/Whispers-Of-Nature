//
//  Whispers_of_NatureApp.swift
//  Whispers of Nature
//
//  Created by fsociety on 26/02/2024.
//

import SwiftUI

@main
struct Whispers_of_NatureApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AudioViewModel.shared)
        }
    }
}



