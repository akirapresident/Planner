import UIKit


class EventosPaiTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate  {
    
    
    @IBOutlet weak var addButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameTextField: UITextField!
    
    
    
    lazy var pulseView: UIView! = self.addButtonOutlet.customView
    var tutorialStage: TutorialStage = .add
    var model = Model.shared
    var eventoPai: Evento?
    
    var listaEventos: [Evento]! {
        get {
            if let evento = eventoPai {
                return evento.subeventos
            } else {
                return model.list
            }
        }
    }
    
    var tamanhoView: CGFloat! = 1
    var keyboardOnOff: Bool = false
    var akira: CGFloat!
    var color: UIColor?
    let sections = ["To do","Done"]
    var notification = UINotificationFeedbackGenerator()
    let colors: [UIColor] = [UIColor(rgba: (255, 107, 129,1.0)), UIColor(rgba: (255, 127, 80,1.0)), UIColor(rgba: (164, 176, 190,1.0)), UIColor(rgba: (255, 71, 87,1.0)), UIColor(rgba: (255, 165, 2,1.0)), UIColor(rgba: (236, 204, 104,1.0)), UIColor(rgba: (123, 237, 159,1.0)), UIColor(rgba: (112, 161, 255,1.0)), UIColor(rgba: (112, 161, 255,1.0)), UIColor(rgba: (83, 82, 237,1.0)), UIColor(rgba: (30, 144, 255,1.0)), UIColor(rgba:(30, 144, 255,1.0)), UIColor(rgba: (55, 66, 250,1.0))]
    
    // MARK: - ViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        nameTextField.delegate = self
        addToolBarDoneTxtField(txtfield: nameTextField)
        tableView.reloadData()
        tableView.layoutIfNeeded()
        //self.setupPulseView()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
        
        if let evento = eventoPai {
            self.title = evento.nome
        }
        else{
            let leftItem = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height))
            leftItem.text = "Projects"
            leftItem.textColor = UIColor.black
            leftItem.font = UIFont.systemFont(ofSize: 30)
            leftItem.isEnabled = false
            navigationItem.titleView = leftItem
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        self.view.bringSubviewToFront(self.pulseView)
        //self.updateTutorial(to: .add)
        //self.pulseView.center = self.addButtonOutlet.customView!.center
    }
    
    override func viewDidAppear(_ animated: Bool) {
        akira = self.addView.frame.origin.y
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Pulse and tutorial methods
    func setupPulseView(){
        
//        UIView.animate(withDuration: 0.3, delay: 0, options: [.repeat, .autoreverse, .allowAnimatedContent, .allowUserInteraction], animations: {
//            self.pulseView.transform = self.pulseView.transform.scaledBy(x: 1.3, y: 1.3)
//            self.pulseView.alpha = 0.5
//        }, completion: {(_) in
//            self.pulseView.transform = .identity
//            self.pulseView.alpha = 1
//        })
    }
    /*
    func updateTutorial(to stage: TutorialStage){
        
        self.pulseView.layer.removeAllAnimations()
        self.pulseView.transform = .identity
        self.pulseView.alpha = 1
        self.tutorialStage = self.model.completouTutorial() ? .ended : .add
        if self.tutorialStage == .ended {
            self.model.completarTutorial()
            return
        }
        
        self.tutorialStage = stage
        switch self.tutorialStage {
        case .add:
            self.pulseView = self.addButtonOutlet.customView!
            self.setupPulseView()
        case .name:
            self.pulseView = self.nameTextField
            self.setupPulseView()
        case .search: break
        case .ended:
            self.pulseView.layer.removeAllAnimations()
        }
    }
    */
    
    func moveView() {
        var translationFactor: CGFloat = 1
        if self.addView.frame.origin.y != akira {
            translationFactor = -1
        }
        let translateAmount = self.addView.frame.height * translationFactor
        let translationAdd = addView.transform.translatedBy(x: 0, y: CGFloat(translateAmount))
        let translationTable = tableView.transform.translatedBy(x: 0, y: CGFloat(translateAmount))
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: [.curveEaseInOut], animations: {
            self.addView.transform = translationAdd
            self.tableView.transform = translationTable
        }) { (_) in }
    }
    
    
  
    // MARK: - TableView delegate methods
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
            let rounded = round((evento.calcProgresso()*10)/10)
            cell.progress.text = String(rounded) + " %"
            cell.evento = evento
            color = colors[indexPath.row % colors.count]
            tamanhoView = cell.view.frame.size.width
            //cell.progressView.superview?.constraints.filter( { $0.secondAttribute == .width} ).first!.constant =  1
            let barProgress = cell.view.frame.size.width
            cell.progressView.frame.size.width = barProgress * CGFloat(rounded/100)
            cell.progressView.backgroundColor = .gray
            cell.pontaquadrada.isHidden = true
            if rounded > 10 {
                cell.pontaquadrada.backgroundColor = .gray
                cell.pontaquadrada.isHidden = false
                
            }
        }
        else{
            let evento = listaEventos.filter({$0.done == true})[indexPath.row]
            cell.eventNameLbl.text = evento.nome
            tamanhoView = cell.view.frame.size.width
            let rounded = round((evento.calcProgresso()*100)/100)
            cell.progress.text = String(rounded) + " %"
            cell.evento = evento
            cell.progressView.frame.size.width = cell.view.frame.width
            cell.progressView.backgroundColor = UIColor(rgba: (46, 213, 115,1.0))
            cell.pontaquadrada.backgroundColor = UIColor(rgba: (46, 213, 115,1.0))
            cell.pontaquadrada.isHidden = false
            
        }
        cell.view.layer.borderColor = UIColor.gray.cgColor
        cell.view.layer.borderWidth = 0.5
        cell.progressView.clipsToBounds = true
        cell.progressView.layer.cornerRadius = 0.59*CGFloat(cell.progressView.frame.size.height)
        cell.view.clipsToBounds = true
        cell.view.layer.cornerRadius = 13
        cell.view.layer.masksToBounds = false
        cell.view.layer.shadowColor = UIColor.black.cgColor
        cell.view.layer.shadowOpacity = 0.5
        cell.view.layer.shadowOffset = CGSize(width: -1, height: 1)
        cell.view.layer.shadowRadius = 1
        
        return cell
    }
    
    //esquerda
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let id = self.idByIndexPath(indexPath: indexPath)
        let evento = self.findEventoById(id: id)!
        
        let check = UIContextualAction(style: .normal, title: "Check") { (action, _, complete) in
            complete(true)
            
            if evento.done == false {
                evento.autoDone(status: true)
            }
            else{
                evento.autoDone(status: false)
            }
            self.model.persistEvents()
            self.tableView.reloadData()
        }
        
        let status = evento.done ?? false
        check.image = status ? UIImage(named: "close") : UIImage(named: "check")
        check.backgroundColor = status ? .red : UIColor(rgba: (46, 213, 115,1.0))
        check.title = status ? "undone" : "done"
        
        return UISwipeActionsConfiguration(actions: [check])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            // criando alerta antes de deletar
            let alertController = UIAlertController(title: "Excluir etapa do projeto", message: "Tem certeza que deseja excluir?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (UIAlertAction) in
                self.delete(indexPath: indexPath)
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
            
            //self.updateTutorial(to: .ended)
            let itemID = idByIndexPath(indexPath: indexPath)
            vc.eventoPai = findEventoById(id: itemID)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if self.tutorialStage == .search{
//            self.pulseView = cell
//            self.setupPulseView()
//        }
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        let sectionLabel = UILabel(frame: CGRect(x: 8, y: 25, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
        sectionLabel.font = UIFont(name: "Helvetica", size: 20)
        sectionLabel.textColor = UIColor.gray
        let view1 = UIView(frame: CGRect(x: 8, y: 50, width:
            tamanhoView, height: tableView.bounds.size.height / 1000))
        view1.backgroundColor = UIColor.gray
        headerView.addSubview(view1)
        sectionLabel.text = sections[section]
        sectionLabel.sizeToFit()
        headerView.addSubview(sectionLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    // MARK: - TableView helpers
    func delete(indexPath: IndexPath) {
        let eventoDelete = findEventoById(id: idByIndexPath(indexPath: indexPath))!
        eventoDelete.selfDelete()
    }
    
    func addEvent(nome: String) {
        let newEvento = Evento(nome: nome, eventoPai: eventoPai)
        
        if eventoPai == nil {
            model.list.append(newEvento)
        }
        model.persistEvents()
    }
    
    func idByIndexPath(indexPath: IndexPath) -> Int{
        let cell = tableView.cellForRow(at: indexPath) as! EventosTableViewCell
        let id = cell.evento.id
        return id
    }
    
    func findEventoById(id: Int) -> Evento? {
        return listaEventos.filter({$0.id == id}).first
    }
    
    // MARK: - funcoes do teclado
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if !nameTextField.hasText { return true}
        addEvent(nome: nameTextField.text!)
        tableView.reloadData()
        nameTextField.text = ""
        //self.updateTutorial(to: .search)
        return false
    }
    
    @objc func keyboardWillAppear() {
        keyboardOnOff = true
        hideKeyboard()
    }
    
    func addToolBarDoneTxtField(txtfield: UITextField) {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addButtonNavigation))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        txtfield.inputAccessoryView = toolBar
    }
    @objc func keyboardWillDisappear() {
        keyboardOnOff = false
        view.gestureRecognizers?.forEach(view.removeGestureRecognizer)
        moveView()
    }
    
    // MARK: - Callbacks
    
    @IBAction func addButtonNavigation(_ sender: Any) {
        moveView()
        self.nameTextField.becomeFirstResponder()
        if nameTextField.text?.isEmpty == false {
            addEvent(nome: nameTextField.text!)
            tableView.reloadData()
            nameTextField.text = ""
        }
        keyboardOnOff = !keyboardOnOff
        if keyboardOnOff == true {
            DismissKeyboard()
            moveView()
        }
        //self.updateTutorial(to: .name)
    }
}


enum TutorialStage{
    
    case name
    case add
    case search
    case ended
}

extension EventosPaiTableViewController {
    func hideKeyboard() {
        let Tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(Tap)
    }
    @objc func DismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIColor {
    convenience init(_ red: Int, _ green: Int, _ blue: Int, _ alpha: Float) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha))
    }
    
    convenience init(rgba: (Int, Int, Int, Float)) {
        self.init(red: CGFloat(rgba.0) / 255.0, green: CGFloat(rgba.1) / 255.0, blue: CGFloat(rgba.2) / 255.0, alpha: CGFloat(rgba.3) )
    }
}




