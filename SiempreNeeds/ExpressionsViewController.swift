//
//  ExpressionsViewController.swift
//  SiempreNeeds
//


import UIKit
import ContactsUI
import Firebase
import libPhoneNumber_iOS

class ExpressionButton: UIButton {
    var type: Expression.Kind? {
        get {
            return nil
        }
    }
}
class ThinkingButton: ExpressionButton {
    override var type : Expression.Kind? {
        get {
            return .Thinking
        }
    }
}
class StressedButton: ExpressionButton {
    override var type : Expression.Kind? {
        get {
            return .Stressed
        }
    }
}
class DogPicButton: ExpressionButton {
    override var type : Expression.Kind? {
        get {
            return .DogPics
        }
    }
}

class ExpressionsViewController: UIViewController, UserProfileDelegate, ExpressionManagerDelegate, UITableViewDelegate, UITableViewDataSource, CNContactPickerDelegate {
    @IBOutlet weak var tableView: UITableView!
    var friendOrder : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        UserProfile.shared.setDelegate(self)
        ExpressionManager.shared.setDelegate(self)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        render()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        render()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    func userDidLoad() {
        render()
    }
    func expressionsDidLoad() {
        render()
    }

    func render() {
        self.friendOrder = Array(UserProfile.shared.friends.keys)
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sender = sender as? ExpressionButton else {
            Log("sender not expression button")
            return
        }
        let dest = segue.destination as! ExpressionsFriendSelectViewController
        dest.type = sender.type
    }
    
    @IBAction func signoutPressed(_ sender: Any) {
        UserAuth.shared.logout()
        performSegue(withIdentifier: "logout", sender: nil)
    }

    func getExpressions(_ fid: String) -> [Expression] {
        let expressions = UserProfile.shared.friends[fid]!.expressions.filter() {(eid) in
            return ExpressionManager.shared.expressions.keys.contains(eid)
            }.map() {(eid) in
                return ExpressionManager.shared.expressions[eid]!
        }
        return expressions
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {return self.friendOrder.count}
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell", for: indexPath) as! FriendTableViewCell
        let fid = self.friendOrder[indexPath.row]

        let expressions = getExpressions(fid)
        var currentExpression: Expression? = nil
        var nExpressions = 0
        cell.pendingNumberLabel.isHidden = true
        cell.pendingTextLabel.text = "👌"
        cell.selectionStyle = .none
        if expressions.count != 0 {
            nExpressions = expressions.count
            currentExpression = expressions.first!
            cell.pendingNumberLabel.isHidden = false
            if nExpressions <= 999 {
                cell.pendingNumberLabel.text = String(nExpressions)
            } else {
                cell.pendingNumberLabel.text = "∞"
            }
            cell.selectionStyle = .blue
            switch (currentExpression!.kind) {
            case .Thinking:
                cell.pendingTextLabel.text = "is thinking of you :)"
            case .Stressed:
                cell.pendingTextLabel.text = "is stressed :/"
            case .DogPics:
                cell.pendingTextLabel.text = "needs a dog pic!"
            }
        }
        cell.profilePicture.image = UserProfile.shared.friends[fid]!.photo
        cell.nameLabel.text = UserProfile.shared.friends[fid]!.firstName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let expressions = getExpressions(self.friendOrder[indexPath.row])
        if (expressions.count > 0) {
            let expression = expressions.first!
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            var vc: UIViewController
            switch (expression.kind) {
            case .Thinking:
                vc = storyboard.instantiateViewController(withIdentifier: "ThinkingOfYouResponseViewController")
            case .Stressed:
                vc = storyboard.instantiateViewController(withIdentifier: "StressedResponseViewController")
            case .DogPics:
                vc = storyboard.instantiateViewController(withIdentifier: "DogPicsResponseViewController")
            }
            let rtvc = vc as! ResponseTypeViewController
            rtvc.expression = expression
            self.present(rtvc, animated: true) {}
        }
    }
    
    @IBAction func addFriendPressed(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Add Friend", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Choose contact", style: .default, handler: raiseContactPicker))
        actionSheet.addAction(UIAlertAction(title: "Enter Phone Number", style: .default, handler: raiseEnterPhone))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel) {(_) in })
        self.present(actionSheet, animated: true)
    }
    
    func raiseContactPicker(_ : UIAlertAction) {
        let contactPicker = CNContactPickerViewController()
        contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        contactPicker.delegate = self
        self.present(contactPicker, animated: true)
    }
    
    func raiseEnterPhone(_ : UIAlertAction) {
        let phoneEntry = UIAlertController(title: "Add Friend", message: "What's your friend's phone number?", preferredStyle: .alert)
        phoneEntry.addTextField() {(_) in }
        phoneEntry.addAction(UIAlertAction(title: "Add", style: .default) {(_) in
            self.phoneNumberEntered(phoneEntry.textFields![0].text!)
        })
        phoneEntry.addAction(UIAlertAction(title: "Cancel", style: .cancel) {(_) in })
        self.present(phoneEntry, animated: true)
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        picker.dismiss(animated: true) {}
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        phoneNumberEntered((contactProperty.value as! CNPhoneNumber).stringValue)
    }
    
    func phoneNumberEntered(_ phoneNumber : String) {
        let phoneUtil = NBPhoneNumberUtil()
        var normalized: String?
        do {
            let nbnumber = try phoneUtil.parse(phoneNumber, defaultRegion: "US")
            normalized = try phoneUtil.format(nbnumber, numberFormat: .E164)
        } catch {
            let alertControllerDone = UIAlertController(title: "Failed", message: "That phone number seems wrong. Check it and try again.", preferredStyle: .alert)
            alertControllerDone.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertControllerDone, animated: true)
            return
        }
        Firestore.firestore().collection("friend-requests").addDocument(data: [
            "from": UserProfile.shared.info.uid,
            "to": normalized! // TODO !
        ]) {(err) in
            if err == nil {
                let alertControllerDone = UIAlertController(title: "Added", message: "Made a request to connect. Your friend also needs to add you in order to get connected.", preferredStyle: .alert)
                alertControllerDone.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertControllerDone, animated: true, completion: nil)
            } else {
                let alertControllerDone = UIAlertController(title: "Failed", message: "An error occurred, try again.", preferredStyle: .alert)
                alertControllerDone.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertControllerDone, animated: true, completion: nil)
            }
        }
    }
}
