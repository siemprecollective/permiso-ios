//
//  User.swift
//  SiempreNeeds
//


import Foundation
import Firebase
import FirebaseStorage
import FirebaseMessaging
import libPhoneNumber_iOS

protocol UserAuthDelegate {
    func didStartLogIn()
    func didLogIn()
    func didFailToLogIn()
}

class UserAuth : NSObject {
    static let shared = UserAuth()
    var delegate: UserAuthDelegate?
    var verificationId: String? // TODO save this

    override private init() {}
    
    func configure() {
        if (Auth.auth().currentUser != nil) {
            didLogIn()
        } else {
            delegate?.didFailToLogIn()
        }
    }
    
    func didLogIn() {
        self.delegate?.didLogIn()
        Messaging.messaging().delegate = UIApplication.shared.delegate as! MessagingDelegate
        UIApplication.shared.registerForRemoteNotifications() // TODO this is the wrong place for this probably
        InstanceID.instanceID().instanceID() { (res, err) in
            if let err = err {
                Log(err.localizedDescription)
                return
            }
            Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).updateData([
                "fcmToken": res!.token
            ])
        }
    }
    
    func startLogin(phoneNumber: String) {
        let phoneUtil = NBPhoneNumberUtil()
       
        var normalized: String?
        do {
            let nbnumber = try phoneUtil.parse(phoneNumber, defaultRegion: "US")
            normalized = try phoneUtil.format(nbnumber, numberFormat: .E164)
        } catch {
            Log("error in phone number")
            delegate?.didFailToLogIn()
            return
        }

        PhoneAuthProvider.provider().verifyPhoneNumber(normalized!, uiDelegate: nil) { (verificationId, err) in
            if let err = err {
                Log(err.localizedDescription) // TODO show to user
                self.delegate?.didFailToLogIn()
                return
            }
            self.verificationId = verificationId
            self.delegate?.didStartLogIn()
        }
    }
    
    func finishLogin(code: String) {
        guard let verificationId = verificationId else {
            Log("Error: verification ID is nil")
            return
        }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: code)
        Auth.auth().signIn(with: credential) {(res, err) in
            if let err = err {
                Log(err.localizedDescription)
                self.delegate?.didFailToLogIn()
                return
            }
            self.didLogIn()
        }
    }
    
    func logout() {
        try? Auth.auth().signOut()
    }
}

protocol UserProfileDelegate {
    func userNeedsProfile()
    func userDidLoad()
}

extension UserProfileDelegate {
    func userNeedsProfile() {}
    func userDidLoad() {}
}

class UserProfile : NSObject {
    static let kImageMaxSize : Int64 = 10 * 1024 * 1024 // bytes
    
    class Info {
        var uid = ""
        var name = ""
        var email = ""
        var phone = ""
        var photo: UIImage? = nil
        var expressions : [String] = []
        
        func setPhoto(_ firebasePath: String, completion: @escaping () -> Void) {
            let ref = Storage.storage().reference(withPath: firebasePath)
            ref.getData(maxSize: UserProfile.kImageMaxSize) { (data, err) in
                if (err != nil) {
                    Log(err!.localizedDescription)
                    return
                }
                self.photo = UIImage(data: data!)
                completion()
            }
        }
        
        var firstName : String {
            get {
                return String(self.name.split(separator: " ")[0])
            }
        }
    }

    static let shared = UserProfile()
    var delegates: [UserProfileDelegate] = []
    
    var info = Info()
    var friends: [String : Info] = [:]

    var listener: ListenerRegistration?
    var friendListeners : [ListenerRegistration] = [] // TODO map?
    
    override private init() {}
   
    func setDelegate(_ delegate: UserProfileDelegate) {
       delegates.append(delegate)
    }
    
    func userNeedsProfile() {
        for delegate in delegates {
            delegate.userNeedsProfile()
        }
    }
    
    func userDidLoad() {
        print("user did load")
        for delegate in delegates {
            delegate.userDidLoad()
        }
    }
    
    func configure() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return // TODO throw
        }
        self.info.uid = uid
        listener = Firestore.firestore().collection("users").document(uid).addSnapshotListener() {(doc, err) in
            guard let doc = doc else {
                Log(err!.localizedDescription)
                return
            }
            if !doc.exists {
                Log("user needs profile")
                self.userNeedsProfile()
                return
            }
            Log("user did load")
            // TODO !s
            let data = doc.data()!
            self.info.name = data["name"] as! String
            self.info.email = data["email"] as! String
            self.info.phone = data["phone"] as! String
            self.info.expressions = Array((data["expressions"] as! [String: Bool]).keys)
            self.info.setPhoto(data["photo"] as! String) {
                self.userDidLoad()
            }
            
            let friends = data["friends"] as! [String: [String : Bool]]
            for listener in self.friendListeners {
                listener.remove()
            }
            self.friendListeners.removeAll()
            for (fid, expressions) in friends {
                self.friendListeners.append(Firestore.firestore().collection("users").document(fid).addSnapshotListener() {(doc, err) in
                    guard let doc = doc, doc.exists else {
                        if err != nil {
                            Log(err!.localizedDescription)
                        }
                        return
                    }
                    if (self.friends[fid] == nil) {
                        self.friends[fid] = Info()
                    }
                    let data = doc.data()!
                    self.friends[fid]!.uid = fid
                    self.friends[fid]!.name = data["name"] as! String
                    self.friends[fid]!.email = data["email"] as! String
                    self.friends[fid]!.phone = data["phone"] as! String
                    self.friends[fid]!.setPhoto(data["photo"] as! String) {
                        self.userDidLoad()
                    }
                    self.friends[fid]!.expressions = Array(expressions.keys)
                    print(self.friends)
                    self.userDidLoad()
                })
            }
            self.userDidLoad()
        }
    }
}
