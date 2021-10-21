import Foundation
import Firebase
import FirebaseDatabase

class TaskModel {
    
    let title: String
    let userId: String
    let ref: DatabaseReference?
    let completed: Bool
    
    init(title: String, userId: String) {
        self.title = title
        self.userId = userId
        self.ref = nil
        self.completed = false
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.title = snapshotValue["title"] as! String
        self.userId = snapshotValue["userId"] as! String
        self.ref = snapshot.ref
        self.completed = snapshotValue["completed"] as! Bool
    }
    
    func convertToDictionary() -> Any {
        return ["title" : title, "userId" : userId, "completed" : completed]
    }
    
}
