//
//  my_traffic3App.swift
//  my_traffic3
//
//  Created by yhl on 5/19/24.
//

import SwiftUI

@main
struct my_traffic3App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
