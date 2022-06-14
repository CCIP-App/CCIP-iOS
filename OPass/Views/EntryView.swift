//
//  EntryView.swift
//  OPass
//
//  Created by secminhr on 2022/5/15.
//  2022 OPass.
//

import SwiftUI

struct EntryView: View {
    
    @State var urlProcessed = false
    @State var showInvalidURL = false
    @EnvironmentObject var OPassAPI: OPassAPIViewModel
    let url: URL?
    
    var body: some View {
        let processingURL = Binding(get: {
            return self.url != nil && !self.urlProcessed
        }, set: { _ in
            //nothing to set
        })
        
        ContentView()
            .sheet(isPresented: processingURL) {
                ProgressView("Logging in...")
                    .task {
                        await parseUniversalLinkAndURL(url!)
                    }
                    .interactiveDismissDisabled()
                    .alert("Invalid URL", isPresented: $showInvalidURL) {
                        Button("OK", role: .cancel) {
                            showInvalidURL = false
                            urlProcessed = true
                        }
                    } message: {
                        Text("You have an invalid URL or the token is incorrect.")
                    }
            }
    }
    
    func parseUniversalLinkAndURL(_ url: URL) async {
        let params = URLComponents(string: "?" + (url.query ?? ""))?.queryItems
        guard let token = params?.first(where: { $0.name == "token" })?.value else {
            showInvalidURL = true
            return
        }
        var success = false
        if let eventId = params?.first(where: { $0.name == "event_id" })?.value {
            success = await OPassAPI.loginEvent(eventId, withToken: token)
        } else if OPassAPI.currentEventID != nil {
            success = await OPassAPI.loginCurrentEvent(token: token)
        }
        if success {
            urlProcessed = true
        } else {
            showInvalidURL = true
        }
    }
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        EntryView(url: nil)
    }
}
