//
//  FeatureGrid.swift
//  OPass
//
//  Created by Brian Chang on 2023/8/8.
//

import SwiftUI

struct FeatureGrid: View {
    @EnvironmentObject var event: EventStore

    var body: some View {
        ScrollView {
            LazyVGrid(columns: .init(
                repeating: .init(spacing: 30, alignment: .top),
                count: 4
            )) {
                ForEach(event.avaliableFeatures, id: \.self) {
                    FeatureGridItem(feature: $0)
                        .padding(.bottom, 5)
                }
            }
        }
        .padding(.horizontal)
    }
}
//.init(spacing: UIScreen.main.bounds.width / 16.56, alignment: .top)
