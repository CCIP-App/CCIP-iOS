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
    let defaultSymbolName: String
    
    init(urlString: String, isRenderOriginal: Bool = false, defaultSymbolName: String = "") {
        self.urlString = urlString
        self.isRenderOriginal = isRenderOriginal
        self.defaultSymbolName = defaultSymbolName
    }
    
    @State var data: Data?
    
    var body: some View {
        if let data = data, let uiimage = UIImage(data: data) {
            Image(uiImage: uiimage)
                .renderingMode((isRenderOriginal ? .original : .template))
                .resizable()
        } else {
            Image(systemName: defaultSymbolName)
                .resizable()
                .foregroundColor(.gray)
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
