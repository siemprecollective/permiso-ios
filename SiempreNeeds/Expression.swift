//
//  Expression.swift
//  SiempreNeeds
//


import Foundation
import Firebase

class Expression {
    enum Kind : String {
    case Thinking = "THINKING"
    case Stressed = "STRESSED"
    case DogPics   = "DOGPIC"
    }
   
    var id: String
    var kind : Kind
    var from: String
    var to: [String]
    var satisfied: Bool
    
    init(id: String, kind: Kind, from: String, to: [String], satisfied: Bool) {
        self.id = id
        self.kind = kind
        self.from = from
        self.to = to
        self.satisfied = satisfied
    }
}

protocol ExpressionManagerDelegate {
    func expressionsDidLoad()
}

class ExpressionManager : UserProfileDelegate {
    static var shared = ExpressionManager()
    var delegates : [ExpressionManagerDelegate] = []
   
    var notification : Expression? = nil
    var notificationExpressionId : String? = nil
    func set(notificationExpressionId: String) {
        self.notificationExpressionId = notificationExpressionId
        if self.expressions[notificationExpressionId] != nil {
            self.notification = self.expressions[notificationExpressionId]
            self.expressionsDidLoad()
        }
    }
    func reset(notificationExpressionId : Void) {
        self.notificationExpressionId = nil
        notification = nil
    }

    var expressions: [String : Expression] = [:]

    var expressionListeners : [ListenerRegistration] = [] // TODO map?
   
    func configure() {
        UserProfile.shared.setDelegate(self)
        reload()
    }
    
    func setDelegate(_ delegate: ExpressionManagerDelegate) {
        self.delegates.append(delegate)
    }
    
    func userDidLoad() {
        reload()
    }
    
    func expressionsDidLoad() {
        for delegate in self.delegates {
            delegate.expressionsDidLoad()
        }
    }
    
    func reload() {
        self.expressionListeners.removeAll() // TODO necessary?
        for (_, info) in UserProfile.shared.friends {
            for expressionId in info.expressions {
                self.expressionListeners.append(Firestore.firestore().collection("expressions").document(expressionId).addSnapshotListener() {(doc, err) in
                    guard let doc = doc, doc.exists else {
                        return
                    }
                    let kind = Expression.Kind(rawValue: doc.data()!["type"] as! String)!
                    let from = doc.data()!["from"] as! String
                    let to = Array((doc.data()!["to"] as! [String : Bool]).keys)
                    let satisfied = doc.data()!["satisfied"] as! Bool
                    self.expressions[expressionId] = Expression(id: expressionId, kind: kind, from: from, to: to, satisfied: satisfied)
                    if expressionId == self.notificationExpressionId {
                        print("expression set in listener")
                        self.notification = self.expressions[expressionId]
                    }
                    self.expressionsDidLoad()
                })
            }
        }
    }
}
