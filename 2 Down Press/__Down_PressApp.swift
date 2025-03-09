//
//  __Down_PressApp.swift
//  2 Down Press
//
//  Created by Erik Hsu on 1/11/25.
//

import SwiftUI

@main
struct TwoDownPressApp: App {
    @StateObject private var playerManager = PlayerManager()
    @StateObject private var groupManager = GroupManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(playerManager)
                .environmentObject(groupManager)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PlayerManager())
        .environmentObject(GroupManager())
}
