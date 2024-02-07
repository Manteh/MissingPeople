//
//  SearchTabView.swift
//  MissingPeople
//
//  Created by Mantas Simanauskas on 2024-01-28.
//

import SwiftUI

struct SearchTabView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").edgesIgnoringSafeArea(.all)
            }
            .navigationTitle("Search")
        }
    }
}

#Preview {
    SearchTabView()
}
