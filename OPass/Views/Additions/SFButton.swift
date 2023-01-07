//
//  SFButton.swift
//  OPass
//
//  Created by secminhr on 2022/3/24.
//  2023 OPass.
//

import SwiftUI

struct SFButton: View {
    let systemName: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
        }
    }
}

#if DEBUG
struct SFButton_Previews: PreviewProvider {
    static var previews: some View {
        SFButton(systemName: "gearshape") {}
    }
}
#endif
