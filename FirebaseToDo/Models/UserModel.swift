import Foundation
import Firebase
import FirebaseAuth

class UserModel {
    
    let uid: String
    let email: String
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email!
    }
    
}
