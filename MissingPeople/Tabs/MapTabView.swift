//
//  MapTabView.swift
//  MissingPeople
//
//  Created by Mantas Simanauskas on 2024-01-28.
//

import SwiftUI

struct MapTabView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").edgesIgnoringSafeArea(.all)
            }
            .navigationTitle("Map")
        }
    }
}

#Preview {
    MapTabView()
}
