//
//  ContentView.swift
//  ClassicSnakeGameByCodex
//
//  Created by sahin raj on 2/7/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        SnakeGameView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
