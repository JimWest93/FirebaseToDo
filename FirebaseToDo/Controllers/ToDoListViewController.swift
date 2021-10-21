import UIKit
import Firebase
import SkyFloatingLabelTextField

class ToDoListViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var toDoTableView: UITableView!
    var newTaskAlert = UIAlertController()
    
    var user: UserModel!
    var ref: DatabaseReference!
    var completedTasks: [TaskModel] = []
    var incompletedTasks: [TaskModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toDoTableView.delegate = self
        toDoTableView.dataSource = self
        user = UserModel(user: getCurrentUser())
        ref = Database.database().reference(withPath: "users").child(String(user.uid))
        configureNewTaskAlert()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserName()
        getTasks()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ref.removeAllObservers()
    }
    
    @IBAction func addTask(_ sender: Any) {
        self.present(newTaskAlert, animated: true, completion: nil)
    }
    
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {}
        dismiss(animated: true, completion: nil)
    }
    
    func getCurrentUser() -> User {
        var user: User?
        if let currentUser = Auth.auth().currentUser {
            user = currentUser
        }
        return user!
    }
    
    func getTasks() {
        ref.child("tasks").observe(.value) { [weak self] snapshot in
            
            var _completedTasks: [TaskModel] = []
            var _incompletedTasks: [TaskModel] = []
            
            for item in snapshot.children {
                let task = TaskModel(snapshot: item as! DataSnapshot)
                
                if task.completed {
                    _completedTasks.append(task)
                } else { _incompletedTasks.append(task)}
                
            }
            
            self?.completedTasks = _completedTasks
            self?.incompletedTasks = _incompletedTasks
            self?.toDoTableView.reloadData()
        }
    }
    
    func getUserName() {
        
        ref.observe(.value) { [weak self] snapshot in
            let snapshotValue = snapshot.value as! [String: AnyObject]
            let name = snapshotValue["name"] as! String
            self?.nameLabel.text = name + "'s" + " tasks"
        }
        
    }
    
    func configureNewTaskAlert() {
        
        newTaskAlert = UIAlertController(title: "New task", message: "Add new task", preferredStyle: .alert)
        newTaskAlert.addTextField()
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            guard let textField = self?.newTaskAlert.textFields?.first, !textField.text!.isEmpty else {return }
            
            let task = TaskModel(title: textField.text!, userId: (self?.user.uid)!)
            let taskRef = self?.ref.child("tasks").child(task.title.lowercased())
            taskRef?.setValue(task.convertToDictionary())
            textField.text = ""
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        newTaskAlert.addAction(saveAction)
        newTaskAlert.addAction(cancelAction)
        
    }
    
}

extension ToDoListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Incomplete tasks"
        }
        return "Complete tasks"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.incompletedTasks.count
        } else { return self.completedTasks.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell") as! TaskTableViewCell
        
        if indexPath.section == 0 {
            cell.cellInit(task: incompletedTasks[indexPath.row])
        } else { cell.cellInit(task: completedTasks[indexPath.row])}
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (contextualAction, view, boolValue) in
            
            let task: TaskModel = {
                var task: TaskModel
                if indexPath.section == 0 {
                    task =  (self?.incompletedTasks[indexPath.row])!
                } else {
                    task =  (self?.completedTasks[indexPath.row])!
                }
                return task
            }()
            
            task.ref?.removeValue()
            
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeActions
        
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { [weak self] (contextualAction, view, boolValue) in
            
            let task: TaskModel = {
                var task: TaskModel
                if indexPath.section == 0 {
                    task = (self?.incompletedTasks[indexPath.row])!
                } else {
                    task = (self?.completedTasks[indexPath.row])!
                }
                return task
            }()
            
            task.ref?.updateChildValues(["completed" : true])
        }
        
        doneAction.backgroundColor = UIColor.systemYellow
        
        if indexPath.section == 0 {
            let swipeAction = UISwipeActionsConfiguration(actions: [doneAction])
            return swipeAction
        }
        
        return nil
        
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
