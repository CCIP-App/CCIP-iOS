//
//  URLImageView.swift
//  Opass
//
//  Created by 張智堯 on 2022/2/7.
//  2022 OPass.
//

import SwiftUI

struct URLImage: View {
    
    let urlString: String
    let isRenderOriginal: Bool
    
    init(urlString: String, isRenderOriginal: Bool? = nil) {
        self.urlString = urlString
        if let bool = isRenderOriginal {
            self.isRenderOriginal = bool
        } else {
            self.isRenderOriginal = false
        }
    }
    
    @State var data: Data?
    
    var body: some View {
        if let data = data, let uiimage = UIImage(data: data) {
            Image(uiImage: uiimage)
                .renderingMode((isRenderOriginal ? .original : .template))
                .resizable()
        } else {
            Image(systemName: "")
                .onAppear {
                    fetchData()
                }
        }
    }
    
    private func fetchData() {
        guard let url = URL(string: urlString) else {
            print("Invalid PNG URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            self.data = data
        }
        task.resume()
    }
}
