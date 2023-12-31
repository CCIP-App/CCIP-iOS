//
//  DevelopersView.swift
//  OPass
//
//  Created by 張智堯 on 2022/8/28.
//  2023 OPass.
//

import SwiftUI

struct DevelopersView: View {
    @State private var contributors: [ContributorsModel]?
    @State private var error = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            if !error {
                if let contributors = contributors {
                    Form {
                        ForEach(contributors, id: \.id) { contributor in
                            Button {
                                if let url = URL(string: contributor.html_url) {
                                    Constants.openInAppSafari(forURL: url, style: colorScheme)
                                }
                            } label: {
                                HStack {
                                    AsyncImage(url: URL(string: contributor.avatar_url), transaction: Transaction(animation: .spring())) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable().scaledToFit()
                                        default:
                                            Image(systemName: "person.crop.circle.fill")
                                                .resizable().scaledToFit()
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .clipShape(Circle())
                                    .frame(width: 35)

                                    VStack(alignment: .leading) {
                                        HStack {
                                            if let name = contributor.name {
                                                Text(name)
                                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                            }
                                            Text(contributor.id)
                                                .foregroundColor(.gray)
                                        }

                                        Text("\(contributor.contributions) contribution\(contributor.contributions > 1 ? "s" : "")")
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(.externalLink)
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.gray)
                                        .frame(width: UIScreen.main.bounds.width * 0.045)
                                }
                            }
                        }
                    }
                } else {
                    ProgressView("LOADING")
                        .task {
                            do {
                                self.contributors = try await getContributorsData()
                            } catch { self.error = true }
                        }
                }
            } else {
                ContentUnavailableView {
                    Label("Something went wrong", systemImage: "exclamationmark.triangle.fill")
                } description: {
                    Text("Check your network status or try again later.")
                } actions: {
                    Button("Try Again") {
                        self.error = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle("Developers")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Constants.openInAppSafari(forURL: URL(string: "https://github.com/CCIP-App/CCIP-iOS/graphs/contributors")!, style: colorScheme)
                } label: { Image(systemName: "chart.bar.xaxis") }
            }
        }
    }
}

#if DEBUG
struct DevelopersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DevelopersView()
                .navigationTitle("Developers")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
#endif

// MARK: GitHub REST API
private extension DevelopersView {
    func getContributorsData() async throws -> [ContributorsModel] {
        var result: [ContributorsModel] = []
        let decoder = JSONDecoder()
        let (contributorsData, _) = try await URLSession.shared.data(from: URL(string: "https://api.github.com/repos/CCIP-App/CCIP-iOS/contributors")!)
        let contributors = try decoder.decode([RawContributorsModel].self, from: contributorsData)
        for contributor in contributors {
            let userData = try? await URLSession.shared.data(from: URL(string: "https://api.github.com/users/\(contributor.login)")!)
            let user = try? decoder.decode(UserModel.self, from: userData?.0 ?? Data())
            result.append(.init(
                id: contributor.login,
                name: user?.name,
                avatar_url: contributor.avatar_url,
                html_url: contributor.html_url,
                contributions: contributor.contributions
            ))
        }
        return result
    }

    struct ContributorsModel: Hashable, Codable {
        var id: String
        var name: String?
        var avatar_url: String
        var html_url: String
        var contributions: Int
    }

    struct RawContributorsModel: Hashable, Codable {
        var login: String
        var avatar_url: String
        var html_url: String
        var contributions: Int
    }

    struct UserModel: Hashable, Codable {
        var name: String?
    }
}
