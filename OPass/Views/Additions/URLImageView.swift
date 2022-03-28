//
//  URLImageView.swift
//  Opass
//
//  Created by 張智堯 on 2022/2/7.
//

import SwiftUI

struct URLImage: View {
    
    let urlString: String
    
    @State var data: Data?
    
    var body: some View {
        if let data = data, let uiimage = UIImage(data: data) {
            Image(uiImage: uiimage)
                .renderingMode(.template)
                .resizable()
        } else {
            Image(systemName: "exclamationmark.icloud")
                .onAppear {
                    fetchData()
                }
        }
    }
    
    private func fetchData() {
        guard let url = URL(string: urlString) else {
            print("Invalid Sessions PNG URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            self.data = data
        }
        task.resume()
    }
}
