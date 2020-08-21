//
//  StressedResponseViewController.swift
//  SiempreNeeds
//


import UIKit
import MessageUI

class StressedResponseViewController: ResponseTypeViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stickerCollectionView: UICollectionView!
    // TODO different stickers

    var stickers = ["Sorry", "CallMe", "Love", "Hello"]
    let kResponseMessage = "I heard you were stressed"
   
    override func viewDidLoad() {
        self.stickerCollectionView.delegate = self
        self.stickerCollectionView.dataSource = self
        self.nameLabel.text = UserProfile.shared.friends[self.expression!.from]!.firstName
    }
    
    @IBAction func xPressed(_ sender: Any) {
        self.dismiss(animated: true) {}
    }

    @IBAction func textMePressed(_ sender: Any) {
        let friend = UserProfile.shared.friends[self.expression!.from]!
        let phone = friend.phone
        let messageComposer = MFMessageComposeViewController()
        messageComposer.messageComposeDelegate = self
        messageComposer.recipients = [phone]
        messageComposer.body = "How are you, \(friend.firstName)?"
        self.present(messageComposer, animated: true) {}
    }
    
    @IBAction func callMePressed(_ sender: Any) {
        callAction()
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
