//
//  UseScenarioView.swift
//  OPass
//
//  Created by 張智堯 on 2022/4/11.
//  2025 OPass.
//

import SwiftUI

struct UseScenarioView: View {

    let scenario: Scenario
    @EnvironmentObject var EventStore: EventStore
    @State private var viewState: Int
    @State private var isHttp403AlertPresented = false
    @State private var usedTime: TimeInterval
    @Environment(\.dismiss) var dismiss

    init(scenario: Scenario, used: Bool) {
        self.scenario = scenario
        self._viewState = .init(wrappedValue: used ? 2 : 0)
        self._usedTime = .init(wrappedValue: used ? scenario.used!.timeIntervalSince1970 : 0)
    }

    var body: some View {
        NavigationStack {
            VStack {
                switch viewState {
                case 0:
                    ConfirmUseScenarioView()
                case 1:
                    ActivityIndicator()
                        .frame(
                            width: UIScreen.main.bounds.width * 0.25,
                            height: UIScreen.main.bounds.width * 0.25)
                case 2:
                    ScuessScenarioView(scenario: scenario, usedTime: $usedTime)
                default:
                    ContentUnavailableView(
                        "Faild to confirm \(scenario.title.localized())",
                        systemImage: "exclamationmark.triangle.fill",
                        description: Text("Check your network status or try again"))
                }
            }
            .navigationTitle(scenario.title.localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .http403Alert(isPresented: $isHttp403AlertPresented, action: { dismiss() })
        }
    }

    @ViewBuilder
    func ConfirmUseScenarioView() -> some View {
        VStack {
            Spacer()

            VStack(spacing: 10) {
                Image(systemName: scenario.symbol)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .padding()
                    .frame(
                        width: UIScreen.main.bounds.width * 0.2,
                        height: UIScreen.main.bounds.width * 0.2
                    )
                    .background(.blue)
                    .cornerRadius(UIScreen.main.bounds.width * 0.05)
                Text(scenario.title.localized())
                    .font(.largeTitle.bold())

                Text("ConfirmUseScenarioMessage")
                    .multilineTextAlignment(.center)
            }

            Group {
                Spacer()
                Spacer()
                Spacer()
            }

            Button {
                useScenario()
            } label: {
                Text("ConfirmUse")
                    .foregroundColor(.white)
                    .padding(.vertical, 11)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .cornerRadius(10)
            }

            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .foregroundColor(.blue)
                    .padding(.vertical, 10)
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.85)
        .onAppear { if scenario.countdown == 0 { self.useScenario() } }
    }

    private func useScenario() {
        self.viewState = 1
        Task {
            do {
                if try await EventStore.use(scenario: scenario.id) {
                    self.usedTime = Date().timeIntervalSince1970
                    self.viewState = 2
                } else {
                    self.viewState = 3
                }
            } catch APIManager.LoadError.forbidden {
                self.isHttp403AlertPresented = true
            } catch { self.viewState = 3 }
        }
    }
}

private struct ScuessScenarioView: View {

    @Environment(\.dismiss) var dismiss
    let scenario: Scenario
    @State var time = 0
    @Binding var usedTime: TimeInterval

    var body: some View {
        VStack {
            if scenario.countdown != 0 {
                TimerView(
                    scenario: scenario, countTime: Double(scenario.countdown),
                    symbolName: scenario.symbol, dismiss: _dismiss, usedTime: $usedTime
                )
                .padding()
            } else {
                VStack {
                    Spacer()
                    Image(systemName: "checkmark.square.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.2)
                        .foregroundColor(.green)
                    Text(scenario.title.localized() + " " + String(localized: "Complete"))
                        .font(.title.bold())
                    Group {
                        Spacer()
                        Spacer()
                    }
                }
            }

            Spacer()

            Button(action: { dismiss() }) {
                Text("Complete")
                    .foregroundColor(.white)
                    .padding(.vertical, 11)
                    .frame(width: UIScreen.main.bounds.width * 0.85)
                    .background(.blue)
                    .cornerRadius(10)
            }
            .padding(.bottom)
        }
    }
}

private struct TimerView: View {

    let scenario: Scenario
    let countTime: Double
    let symbolName: String
    @Environment(\.dismiss) var dismiss

    @State var time: Double = 0
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @Binding var usedTime: TimeInterval

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(String(format: "%d:%02d", Int(time) / 60, Int(time) % 60))
                        .font(.system(size: 70, weight: .light))  //TODO: Dynamic size
                }
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.horizontal)

            ForEach(scenario.attributes.keys.sorted(), id: \.self) { key in
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(key.capitalizingFirstLetter())
                            .foregroundColor(.white.opacity(0.5))
                        Text(scenario.attributes[key]?.capitalizingFirstLetter() ?? "")
                            .foregroundColor(.white)
                            .fontWeight(.light)
                            .font(.largeTitle)
                            .multilineTextAlignment(.leading)
                            .offset(x: 0, y: -10)
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.width * 0.5)
        .background(content: {
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    Spacer()
                    if symbolName != "" {
                        Image(systemName: symbolName)
                            .font(
                                .system(
                                    size: UIScreen.main.bounds.width * 0.18, weight: .bold,
                                    design: .rounded)
                            )
                            .foregroundColor(Color.white.opacity(0.2))
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .offset(x: 0, y: 30)
        })
        .background(BackgroundColor(diet: scenario.attributes["diet"]))
        .cornerRadius(10)
        .onReceive(timer) { _ in
            let tmpTime = countTime - (Date().timeIntervalSince1970 - usedTime)
            if tmpTime <= 0 {
                dismiss()
            } else {
                time = tmpTime
            }
        }
    }

    private func BackgroundColor(diet: String?) -> Color {
        switch diet {
        case "meat": return Color(red: 1, green: 160 / 255, blue: 0)
        case "vegetarian": return Color(red: 41 / 255, green: 138 / 255, blue: 8 / 255)
        default: return Color.blue
        }
    }
}
