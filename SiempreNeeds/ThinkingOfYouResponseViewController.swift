//
//  ThinkingOfYouResponseViewController.swift
//  SiempreNeeds
//


import UIKit
import MessageUI

class ThinkingOfYouResponseViewController: ResponseTypeViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var stickerCollectionView: UICollectionView!
    @IBOutlet weak var nameLabel: UILabel!
    
    let kResponseMessage = "Thinking of you too!"
    var picker = UIImagePickerController()
    let stickers = ["Hello", "Love", "CallMe"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        stickerCollectionView.delegate = self
        stickerCollectionView.dataSource = self
        self.nameLabel.text = UserProfile.shared.friends[self.expression!.from]!.firstName
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func xPressed(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
    
    @IBAction func takePhotoPressed(_ sender: Any) {
        picker.allowsEditing = false
        picker.sourceType = .camera
        picker.cameraDevice = .front
        self.present(picker, animated: true)
    }
    
    @IBAction func callMePressed(_ sender: Any) {
        callAction()
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {}
        // TODO fix !s
        let image = info[.originalImage] as! UIImage
        let jpeg = image.jpegData(compressionQuality: 1.0)!
        let phone = UserProfile.shared.friends[self.expression!.from]!.phone
        let messageComposer = MFMessageComposeViewController()
        messageComposer.messageComposeDelegate = self
        messageComposer.recipients = [phone]
        messageComposer.body = kResponseMessage
        messageComposer.addAttachmentData(jpeg, typeIdentifier: "public.jpeg", filename: "image.jpg")
        self.present(messageComposer, animated: true) {}
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {return stickers.count}
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerCollectionViewCell", for: indexPath) as! StickerCollectionViewCell
        cell.imageView.image = UIImage(named: self.stickers[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let stickerImage = UIImage(named: self.stickers[indexPath.row])!
        let jpeg = stickerImage.jpegData(compressionQuality: 1.0)!
        let phone = UserProfile.shared.friends[self.expression!.from]!.phone
        let messageComposer = MFMessageComposeViewController()
        messageComposer.messageComposeDelegate = self
        messageComposer.recipients = [phone]
        messageComposer.body = kResponseMessage
        messageComposer.addAttachmentData(jpeg, typeIdentifier: "public.jpeg", filename: "image.jpg")
        self.present(messageComposer, animated: true) {}
    }
}
