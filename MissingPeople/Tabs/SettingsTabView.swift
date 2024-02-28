//
//  SettingsTabView.swift
//  MissingPeople
//
//  Created by Mantas Simanauskas on 2024-01-28.
//

import SwiftUI
import StoreKit

struct SettingsTabView: View {
    @State var enableNotifications = false
    @Environment(\.requestReview) var requestReview
    @Environment(\.openURL) var openURL

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
                        Button(action: { requestReview() }) {
                            HStack(spacing: 15) {
                                Image(systemName: "star.fill")
                                    .frame(width: 20, height: 20)
                                    .padding(10)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .opacity(0.03)
                                    }
                                Text("Ge en recension")
                                    .font(.system(size: 14, weight: .regular))
                                    .bold()
                            }
                            .frame(height: 40)
                            .opacity(0.8)
                        }
                        .buttonStyle(.plain)

                        HStack(spacing: 15) {
                            Image(systemName: "ant.fill")
                                .frame(width: 20, height: 20)
                                .padding(10)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .opacity(0.03)
                                }
                            Text("Rapportera ett problem")
                                .font(.system(size: 14, weight: .regular))
                                .bold()
                        }
                        .frame(height: 40)
                        .opacity(0.8)
                    }
                    .listRowBackground(Color("SemiBackground"))

                    Section {
                        SettingListRowView(
                            iconSystemName: "lock.fill",
                            text: "Integritetspolicy",
                            action: { UIApplication.shared.open(URL(string: "https://www.google.se")!) }
                        )

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
            .onChange(of: enableNotifications) {
                updateNotificationStatus(enabled: enableNotifications)
            }
        }
    }

    func updateNotificationStatus(enabled: Bool) {
        let center = UNUserNotificationCenter.current()

        if enabled {
            // Request permission to display notifications
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    print("Notifications permission granted")
                } else {
                    print("Notifications permission denied")
                }
            }
        } else {
            // Disable notifications by removing the permissions
            center.getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized {
                    print("Notifications disabled")
                    center.removeAllPendingNotificationRequests()
                    center.removeAllDeliveredNotifications()
                }
            }
        }
    }
}

struct SettingListRowView: View {
    let iconSystemName: String
    let text: String
    let action: () -> Void
    @State private var isHoldingButton = false

    var body: some View {
        Button(action: {
            self.isHoldingButton = false
            //action()
        }) {
            HStack(spacing: 15) {
                Image(systemName: iconSystemName)
                    .frame(width: 20, height: 20)
                    .padding(10)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .opacity(0.03)
                    }
                Text(text)
                    .font(.system(size: 14, weight: .regular))
                    .bold()
            }
            .frame(height: 40)
            .opacity(0.8)
        }
        .simultaneousGesture(LongPressGesture(minimumDuration: 0.1).onEnded({ _ in
            self.isHoldingButton = true
            print("isHolding")

        }))
        .listRowBackground(Color("SemiBackground"))
    }
}

#Preview {
    SettingsTabView()
        .preferredColorScheme(.dark)
}
