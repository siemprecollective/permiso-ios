//
//  ExpressionsFriendSelectViewController.swift
//  SiempreNeeds
//


import UIKit
import Firebase

class ExpressionsFriendSelectViewController: UIViewController, UserProfileDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var friendsCollectionView: UICollectionView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var kindLabel: UILabel!
    
    var friendOrder : [String] = []
    var toSend = Set<String>()
    var type: Expression.Kind? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendsCollectionView.dataSource = self
        friendsCollectionView.delegate = self
        UserProfile.shared.setDelegate(self)
        switch(type!) {
        case .Thinking:
           kindLabel.text = "I am thinking of..."
        case .Stressed:
           kindLabel.text = "I am stressed :/"
        case .DogPics:
           kindLabel.text = "I need a dog pic!"
        }
        render()
    }
   
    func render() {
        self.sendButton.isHidden = true
        if self.toSend.count > 0 {
           self.sendButton.isHidden = false
        }
        self.friendOrder = Array(UserProfile.shared.friends.keys)
        self.friendsCollectionView.reloadData()
    }
    
    func userDidLoad() {
        // Todo consistent order
        render()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (section == 0) {
            return UserProfile.shared.friends.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.friendsCollectionView.dequeueReusableCell(withReuseIdentifier: "FriendCollectionViewCell", for: indexPath) as! FriendCollectionViewCell
        
        let fid = self.friendOrder[indexPath.row]
        cell.imageView.image = UserProfile.shared.friends[fid]?.photo
        cell.nameLabel.text = UserProfile.shared.friends[fid]?.firstName
        
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.borderColor = Colors.darkGray.cgColor
        if self.toSend.contains(fid) {
            cell.imageView.layer.borderColor = Colors.green.cgColor
            cell.imageView.layer.borderWidth = 5
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fid = self.friendOrder[indexPath.row]
        if !self.toSend.contains(fid) {
            self.toSend.insert(fid)
        } else {
            self.toSend.remove(fid)
        }
        render()
    }
    
    @IBAction func expressionSent(_ sender: Any) {
        if self.toSend.count == 0 {
            return
        }
        let fid = self.toSend.randomElement()!
        self.toSend.removeAll()
        Firestore.firestore().collection("expression-requests").addDocument(data: [
            "from": UserProfile.shared.info.uid,
            "to": [fid: true],
            "type": self.type!.rawValue,
            "satisfied": false
        ])
        self.dismiss(animated: true) {}
    }
    
    @IBAction func xPressed(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
}
