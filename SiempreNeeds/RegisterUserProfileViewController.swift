//
//  RegisterUserProfileViewController.swift
//  SiempreNeeds
//


import UIKit
import Firebase
import FirebaseStorage

class RegisterUserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var profilePicture: UIImageView!
    
    let picker = UIImagePickerController()
    var jpeg: Data?

    override func viewDidLoad() {
        picker.delegate = self
    }
    
    @IBAction func tappedOutside(_ sender: Any) {
        nameInput.resignFirstResponder()
        emailInput.resignFirstResponder()
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
        // TODO fix !s
        profilePicture.image = info[.originalImage] as! UIImage
        picker.dismiss(animated: true) {}
        jpeg = profilePicture.image!.jpegData(compressionQuality: 1.0)!
    }

    @IBAction func profileSubmitted(_ sender: Any) {
        func displayError(_ message: String) {
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true)
        }
        // TODO alert on error
        guard let jpeg = jpeg else {
            displayError("Please choose an image.")
            return
        }
        guard jpeg.count < UserProfile.kImageMaxSize else {
            displayError("Please choose a smaller image.")
            return
        }
        guard nameInput.text! != "" else {
            displayError("Enter a name.")
            return
        }
        guard emailInput.text! != "" else {
            displayError("Enter a username.")
            return
        }

        // TODO !s
        let uid = Auth.auth().currentUser!.uid
        let fireStoragePath = "\(uid)/photo"
        let storageRef = Storage.storage().reference().child(fireStoragePath)
        storageRef.putData(jpeg)
        Firestore.firestore().collection("users").document(uid).setData([
            "photo": fireStoragePath,
            "name": nameInput.text!,
            "email": emailInput.text!,
            "phone": Auth.auth().currentUser!.phoneNumber!,
            "friends": [:],
            "expressions": [:]
        ])
    }
}
