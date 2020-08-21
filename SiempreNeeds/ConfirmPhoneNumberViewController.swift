//
//  ConfirmPhoneNumberViewController.swift
//  SiempreNeeds
//


import UIKit

class ConfirmPhoneNumberViewController: UIViewController, UserAuthDelegate {
    @IBOutlet weak var codeInput: UITextField!
    override func viewDidAppear(_ animated: Bool) {
        UserAuth.shared.delegate = self
    }
    
    @IBAction func tappedOutside(_ sender: Any) {
        codeInput.resignFirstResponder()
    }
    
    @IBAction func codeEntered(_ sender: Any) {
        UserAuth.shared.finishLogin(code: codeInput.text!)
    }
    
    func didStartLogIn() {
        // unused
    }
    
    func didFailToLogIn() {
        // todo send error
    }
    
    func didLogIn() {
        performSegue(withIdentifier: "confirmed", sender: nil)
    }
}
