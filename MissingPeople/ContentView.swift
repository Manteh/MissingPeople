//
//  ContentView.swift
//  MissingPeople
//
//  Created by Mantas Simanauskas on 2024-01-16.
//

import SwiftUI

struct ContentView: View {
    @State var missingPeople: [MissingPerson] = []

    var body: some View {
        TabView {
            PeopleTabView(missingPeople: $missingPeople)
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("People")
                        .font(.system(size: 10, weight: .medium))
                }

            MapTabView(missingPeople: $missingPeople)
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                        .font(.system(size: 10, weight: .medium))
                }

//            SearchTabView()
//                .tabItem {
//                    Image(systemName: "magnifyingglass")
//                    Text("Search")
//                        .font(.system(size: 10, weight: .medium))
//                }

            SettingsTabView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                        .font(.system(size: 10, weight: .medium))
                }
        }
    }
}

#Preview {
    ContentView()
}
