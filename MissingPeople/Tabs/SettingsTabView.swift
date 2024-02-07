//
//  SettingsTabView.swift
//  MissingPeople
//
//  Created by Mantas Simanauskas on 2024-01-28.
//

import SwiftUI

struct SettingsTabView: View {
    @State var enableNotifications = false

    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").edgesIgnoringSafeArea(.all)
                List {
                    Section(header: Text("")) {
                        HStack(spacing: 15) {
                            Image(systemName: "bell\(enableNotifications ? "" : ".slash").fill")
                                .frame(width: 20, height: 20)
                                .padding(10)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .opacity(0.03)
                                }
                            Text("Tillåt aviseringar")
                                .font(.system(size: 14, weight: .regular))
                                .bold()
                            Spacer()
                            Toggle("", isOn: $enableNotifications)
                                .frame(width: 60)
                        }
                        .frame(height: 40)
                        .opacity(0.8)
                    }
                    .listRowBackground(Color("SemiBackground"))

                    Section {
                        HStack(spacing: 15) {
                            Image(systemName: "lock.fill")
                                .frame(width: 20, height: 20)
                                .padding(10)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .opacity(0.03)
                                }
                            Text("Integritetspolicy")
                                .font(.system(size: 14, weight: .regular))
                                .bold()
                        }
                        .frame(height: 40)
                        .opacity(0.8)

                        HStack(spacing: 15) {
                            Image(systemName: "book.fill")
                                .frame(width: 20, height: 20)
                                .padding(10)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .opacity(0.03)
                                }
                            Text("Användarvillkor")
                                .font(.system(size: 14, weight: .regular))
                                .bold()
                        }
                        .frame(height: 40)
                        .opacity(0.8)
                    }
                    .listRowBackground(Color("SemiBackground"))
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsTabView()
        .preferredColorScheme(.dark)
}
