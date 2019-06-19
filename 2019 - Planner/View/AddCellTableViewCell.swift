import UIKit

class AddCellTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    weak var delegate: EventosPaiTableViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameTextField.delegate = self
    }
    // retorno do teclado
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        addName((Any).self)
        
        return false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func addName(_ sender: Any) {
        if !nameTextField.hasText { return }
        delegate?.addEvent(nome: nameTextField.text!)
        delegate?.updateDataSource()
        delegate?.tableView.reloadData()
        nameTextField.text = ""
    }
    
}
