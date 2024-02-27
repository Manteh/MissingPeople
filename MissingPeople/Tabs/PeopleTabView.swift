//
//  PeopleTabView.swift
//  MissingPeople
//
//  Created by Mantas Simanauskas on 2024-01-28.
//

import SwiftUI
import Combine

class PeopleTabViewModel: ObservableObject {
    @Published var text: String = ""
}

struct PeopleTabView: View {
    @StateObject private var vm = PeopleTabViewModel()
    @State var filteredMissingPeople: [MissingPerson] = []
    @Binding var missingPeople: [MissingPerson] {
        didSet { filteredMissingPeople = missingPeople }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background").edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        if !missingPeople.isEmpty {
                            Image(systemName: "magnifyingglass")
                            TextField(text: $vm.text) {
                                Text("Sök bland \(missingPeople.count) försvunna personer")
                            }
                        }
                        Button(action: { $vm.text.wrappedValue = "" }, label: {
                            Image(systemName: "xmark")
                                .frame(width: 14, height: 14)
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 10).opacity(0.05))
                        })
                        .opacity(vm.text.isEmpty ? 0 : 0.8)
                        .scaleEffect(vm.text.isEmpty ? 0 : 1)
                        .animation(.spring, value: vm.text.isEmpty)
                    }
                    .padding()
                    List(filteredMissingPeople, id: \.id) { missingPerson in
                        PeopleCardView(missingPerson: missingPerson)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .refreshable { updateMissingPeopleList() }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Missing People")
            .onReceive(vm.$text.debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)) { newSearchText in
                if newSearchText.isEmpty {
                    filteredMissingPeople = missingPeople
                } else {
                    filteredMissingPeople = missingPeople.filter({
                        let name = $0.name.lowercased()
                        let searchKey = newSearchText.lowercased()
                        if let lastSeenAt = $0.lastSeenAt?.lowercased() {
                            return name.contains(searchKey) || lastSeenAt.contains(searchKey)
                        } else {
                            return name.contains(searchKey)
                        }
                    })
                }
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
