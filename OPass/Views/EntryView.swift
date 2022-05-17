//
//  EntryView.swift
//  OPass
//
//  Created by secminhr on 2022/5/15.
//

import SwiftUI

struct EntryView: View {
    
    @State var urlProcessed = false
    let url: URL?
    
    var body: some View {
        //WIP, push first to reduce conflict
        if (url == nil || urlProcessed) {
            ContentView()
                .environmentObject(OPassAPIViewModel())
        } else {
            ProgressView()
                .onAppear {
                    parseUniversalLinkAndURL(url!)
                }
        }
    }
    
    func parseUniversalLinkAndURL(_ url: URL) -> Bool {
//        let params = URLComponents(string: "?" + (url.query ?? ""))?.queryItems
//        let event_id = params?.first(where: { $0.name == "event_id" })?.value
//        let token = params?.first(where: { $0.name == "token" })?.value
//        let ac = UIAlertController.alertOfTitle(NSLocalizedString("GuideViewTokenErrorTitle", comment: ""), withMessage: NSLocalizedString("GuideViewTokenErrorDesc", comment: ""), cancelButtonText: NSLocalizedString("GotIt", comment: ""), cancelStyle: .cancel, cancelAction: nil)
//        if let event_id = event_id, let token = token {
//            OPassAPI.DoLogin(event_id, token) { success, data, _ in
//                if !success && data != nil {
//                    ac.showAlert {
//                        UIImpactFeedback.triggerFeedback(.notificationFeedbackError)
//                    }
//                }
//            }
//            return true
//        }
//        if let token = token {
//            if event_id == nil && Constants.HasSetEvent {
//                OPassAPI.RedeemCode("", token) { success, data, _ in
//                    if !success && data != nil {
//                        ac.showAlert {
//                            UIImpactFeedback.triggerFeedback(.notificationFeedbackError)
//                        }
//                    }
//                }
//            }
//        }
//        return true
//        Constants.OpenInAppSafari(forURL: url)
        return true
    }
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        EntryView(url: nil)
    }
}
