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
                .refreshable { updateMissingPeopleList() }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Missing People")
            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button(action: {}) {
//                        Text("SORTERA")
//                            .font(.system(size: 10, weight: .semibold))
//                            .padding(10)
//                            .opacity(0.5)
//                            .background {
//                                RoundedRectangle(cornerRadius: 5)
//                                    .fill(Color("SemiBackground"))
//                            }
//                    }
//                }
            }
            .onAppear {
                if missingPeople.isEmpty { updateMissingPeopleList() }
            }
        }
        .preferredColorScheme(.dark)
        .tint(.primary)
    }

    func updateMissingPeopleList() {
        MPService.shared.fetchMissingPeople { missingPeople in
            guard let missingPeople = missingPeople else { return }
            self.missingPeople = missingPeople.sorted(by: { p1, p2 in
                guard let _date1 = p1.missingSince, let _date2 = p2.missingSince else { return false }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-mm-dd"
                guard let date1 = formatter.date(from: _date1), let date2 = formatter.date(from: _date2) else { return false }
                return date1 > date2
            })
        }
    }
}

#Preview {
    PeopleTabView(missingPeople: .constant([.mock]))
}
