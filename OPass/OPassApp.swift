//
//  OPassApp.swift
//  OPass
//
//  Created by 張智堯 on 2022/2/28.
//

import SwiftUI
import Firebase

@main
struct OPassApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(OPassAPIViewModel())
        }
    }
}
