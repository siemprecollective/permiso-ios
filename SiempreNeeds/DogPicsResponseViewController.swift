//
//  DogPicsResponseViewController.swift
//  SiempreNeeds
//


import UIKit
import MessageUI
import Firebase

class DogPicsResponseViewController: ResponseTypeViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    let kResponseMessage = "I heard you needed a doggo"
    var picker = UIImagePickerController()
    var pictures : [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        self.nameLabel.text = UserProfile.shared.friends[self.expression!.from]!.firstName
        self.imagesCollectionView.delegate = self
        self.imagesCollectionView.dataSource = self
        loadPicturesFromReddit()
    }
    
    func loadPicturesFromReddit() {
        Reddit.shared.getAww { image in
            self.pictures.append(image)
            DispatchQueue.main.async {
                self.imagesCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func xPressed(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
    
    @IBAction func takePhotoPressed(_ sender: Any) {
        picker.allowsEditing = false
        picker.sourceType = .camera
        self.present(picker, animated: true)
    }
    @IBAction func choosePhotoPressed(_ sender: Any) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true)
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
        if section == 0 {return pictures.count}
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerCollectionViewCell", for: indexPath) as! StickerCollectionViewCell
        cell.imageView.image = self.pictures[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let stickerImage = self.pictures[indexPath.row]
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
