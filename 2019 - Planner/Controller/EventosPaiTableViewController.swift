import UIKit

extension EventosPaiTableViewController {
    func hideKeyboard() {
        let Tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(Tap)
    }
    @objc func DismissKeyboard() {
        view.endEditing(true)
    }
}

class EventosPaiTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameTextField: UITextField!
    var model = Model.shared
    var eventoPai: Evento?
    var listaEventos: [Evento]! //{
//        get {
//            if let evento = eventoPai {
//                return evento.subeventos
//            } else {
//                return model.list
//            }
//        }
    //}
    var keyboardOnOff: Bool = false
    
    var entrou = false
    let sections = ["To do","Done"]
    
    var notification = UINotificationFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        nameTextField.delegate = self
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        entrou = false
        updateDataSource()
        tableView.reloadData()
        if let evento = eventoPai{
            self.title = evento.nome
        }
        else{
            self.title = "Projetos"
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    // funcoes do teclado
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        addName((Any).self)
        return false
    }
    @IBAction func addName(_ sender: Any) {
        if !nameTextField.hasText { return }
        addEvent(nome: nameTextField.text!)
        updateDataSource()
        tableView.reloadData()
        nameTextField.text = ""
    }
    
    @objc func keyboardWillAppear() {
        keyboardOnOff = true
        hideKeyboard()
    }
    
    @objc func keyboardWillDisappear() {
        keyboardOnOff = false
        view.gestureRecognizers?.forEach(view.removeGestureRecognizer)
    }
    // fim teclado
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return listaEventos.filter({$0.done == false}).count
        }
        else{
            return listaEventos.filter({$0.done == true}).count
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EventosTableViewCell
        
        if indexPath.section == 0 {
            
            let evento = listaEventos.filter({$0.done == false})[indexPath.row]
            cell.eventNameLbl.text = evento.nome
            model.idAtual = listaEventos[indexPath.row].id
            cell.progress.text = String(evento.calcProgresso()) + " %"
            cell.evento = evento
        }
        else{
            let evento = listaEventos.filter({$0.done == true})[indexPath.row]
            cell.eventNameLbl.text = evento.nome
            model.idAtual = listaEventos[indexPath.row].id
            cell.evento = evento
        }
        
        let incremento: CGFloat = 0.1
        let newRed = incremento * CGFloat(indexPath.row) + CGFloat(0.4)
        let newBlue = incremento * CGFloat(indexPath.row) + CGFloat(0.5)
        let newGreen = incremento * CGFloat(indexPath.row) + CGFloat(0.1)
        cell.view.backgroundColor = UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
        
        return cell
    }
    
    //esquerda
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let check = UIContextualAction(style: .normal, title: "Check") { (action, _, complete) in
            complete(true)
            if let evento = self.eventoPai{
                let id = self.idByIndexPath(indexPath: indexPath)
                let teOuEfe = self.findEventoById(id: id)!
                
                if teOuEfe.done == false {
                    evento.subeventos[indexPath.row].autoDone(status: true)
                }
                else{
                    evento.subeventos[indexPath.row].autoDone(status: false)
                }
                self.tableView.reloadData()
            }
            else{
                if self.listaEventos[indexPath.row].done == false {
                    self.listaEventos[indexPath.row].autoDone(status: true)
                }
                else{
                    self.listaEventos[indexPath.row].autoDone(status: false)
                }
                self.tableView.reloadData()
            }
        }
        
        let status = listaEventos[indexPath.row].done
        check.image = status ? UIImage(named: "close") : UIImage(named: "check")
        check.backgroundColor = status ? .red : .green
        
        return UISwipeActionsConfiguration(actions: [check])
    }
    //    // para proibir de editar uma celula da tableView
    //    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    //        return indexPath.row != 0
    //    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            // criando alerta antes de deletar
            let alertController = UIAlertController(title: "Excluir etapa do projeto", message: "Tem certeza que deseja excluir?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (UIAlertAction) in
                self.delete(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .bottom)
                self.tableView.reloadData()
            }))
            alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
            self.present(alertController, animated: true, completion: nil)
            self.notification.notificationOccurred(.warning)
        }
        else if editingStyle == .insert{
        }
    }
    
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "projectTableView") as? EventosPaiTableViewController {

            let itemID = idByIndexPath(indexPath: indexPath)
            vc.eventoPai = findEventoById(id: itemID)
            self.navigationController?.pushViewController(vc, animated: true)

        }
    }
    
    func delete(at: Int) {
        if let evento = eventoPai{
            evento.subeventos.remove(at: at)
            listaEventos = evento.subeventos
        }
        else{
            model.list.remove(at: at)
            listaEventos = model.list
        }
    }
    
    func updateDataSource() {
        if let evento = eventoPai{
            listaEventos = evento.subeventos
        }
        else{
            listaEventos = model.list
        }
    }
    
    func addEvent(nome: String) {
        let newEvento = Evento(nome: nome, eventoPai: eventoPai)
        
        if eventoPai == nil {
            model.list.append(newEvento)
        }
    }
    
    func idByIndexPath(indexPath: IndexPath) -> Int{
        let cell = tableView.cellForRow(at: indexPath) as! EventosTableViewCell
        let id = cell.evento.id
        return id
    }
    
    func findEventoById(id: Int) -> Evento? {
        return listaEventos.filter({$0.id == id}).first
    }
    
}
