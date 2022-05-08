//
//  ImagePicker.swift
//  OPass
//
//  Created by secminhr on 2022/4/24.
//  2022 OPass.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    private var imagePickerDelegate: ImagePickerDelegate
    
    init(onImageSelected: @escaping (UIImage) -> Void) {
        imagePickerDelegate = ImagePickerDelegate(onImageSelected: onImageSelected)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = imagePickerDelegate
        return imagePickerController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        //intentionally left empty
    }
}

class ImagePickerDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let onImageSelected: (UIImage) -> Void
    init(onImageSelected: @escaping (UIImage) -> Void) {
        self.onImageSelected = onImageSelected
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        onImageSelected(image)
    }
}

struct ImagePicker_Previews: PreviewProvider {
    static var previews: some View {
        ImagePicker {_ in
            //left empty
        }
    }
}
