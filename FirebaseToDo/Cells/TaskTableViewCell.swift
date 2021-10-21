import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    
    func cellInit(task: TaskModel) {
        taskLabel.text = task.title
        indicatorView.backgroundColor = {
            task.completed ? UIColor.systemGreen : UIColor.systemCyan
        }()
    }
}
