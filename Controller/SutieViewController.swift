//
//  SutieViewController.swift
//  InstaImagePicker
//
//  Created by sutie on 2018. 3. 4..
//  Copyright © 2018년 sutie. All rights reserved.
//

import Foundation
import UIKit


class SutieViewController: UIViewController {
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func imagePickerButtonTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "STMain", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "imagePicker") as! STInstagramPickerViewController
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
}


extension SutieViewController: ImagePickerDelegate {
    func imagePickerDidCancel(_ imagePicker: STInstagramPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerDidDone(_ imagePicker: STInstagramPickerViewController, image: UIImage?) {
        previewImageView.image = image
        dismiss(animated: true, completion: nil)
    }
}



