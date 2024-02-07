//
//  PeopleTabView.swift
//  MissingPeople
//
//  Created by Mantas Simanauskas on 2024-01-28.
//

import SwiftUI

struct PeopleTabView: View {
    @Binding var missingPeople: [MissingPerson]

    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background").edgesIgnoringSafeArea(.all)
                List(missingPeople, id: \.id) { missingPerson in
                    PeopleCardView(missingPerson: missingPerson)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .refreshable {
                    MPService.shared.fetchMissingPeople { missingPeople in
                        guard let missingPeople = missingPeople else { return }
                        self.missingPeople = missingPeople
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Missing People")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}) {
                        Text("SORTERA")
                            .font(.system(size: 10, weight: .semibold))
                            .padding(10)
                            .opacity(0.5)
                            .background {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color("SemiBackground"))
                            }
                    }
                }
            }
            .onAppear {
                if missingPeople.isEmpty {
                    MPService.shared.fetchMissingPeople { missingPeople in
                        guard let missingPeople = missingPeople else { return }
                        self.missingPeople = missingPeople
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .tint(.primary)
    }
}

#Preview {
    PeopleTabView(missingPeople: .constant([.mock]))
}
