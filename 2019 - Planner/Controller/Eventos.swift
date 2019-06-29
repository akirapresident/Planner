import UIKit

class Evento: NSObject, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.nome, forKey: "nome")
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.subeventos, forKey: "subeventos")
        aCoder.encode(self.eventoPai, forKey: "eventoPai")
//        aCoder.encode(self.evento, forKey: "evento")
        aCoder.encode(self.done, forKey: "done")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeInteger(forKey: "id")
        
        self.nome = aDecoder.decodeObject(forKey: "nome") as! String
        self.eventoPai = aDecoder.decodeObject(forKey: "eventoPai") as? Evento
        self.subeventos = aDecoder.decodeObject(forKey: "subeventos") as! [Evento]
        self.done = aDecoder.decodeObject(forKey: "done") as? Bool
    }
    
    
    //Estrutura
    
    var nome: String
    var id: Int
    var subeventos: [Evento] = []
    var eventoPai: Evento?
//    var evento: Evento?
    static var ultimoID: Int = 0 // Única entre todas as instâncias
    var done: Bool! {
        didSet {
            if done {// para saber se o evento pai vai ser falso ou não de acordo com a leitura dos filhos
                if self.eventoPai?.subeventos.filter( {$0.done == false} ).count != 0{
                    self.eventoPai?.done = false
                }
                else{// caso não tenha nenhum filho Falso, o evento pai é verdadeiro
                    self.eventoPai?.done = true
                }
            } else {// caso done = false
                if self.eventoPai != nil {// e evento pai seja diferente de vazio
                    (self.eventoPai)!.done = false // deixe o evento como falso
                }
            }
        }
    }
    
    
    init(nome: String, eventoPai: Evento?) {
        self.id = Evento.ultimoID
        Evento.ultimoID += 1 // toda vez que "Evento()" for chamado, id++ , para nunca ficar com nenhum dado repetido
        
        self.nome = nome
        self.eventoPai = eventoPai
        self.done = false
        super.init()
        if self.eventoPai != nil {// se o evento pai for diferente de nil
            (self.eventoPai)!.subeventos.append(self) // adiciona o novo evento no array subeventos do pai
        }
    }
    
    convenience init(nome: String) {
        //        self.nome = nome
        //        self.eventoPai = eventoPai
        //        self.id = Evento.ultimoID
        //        Evento.ultimoID += 1
        self.init(nome: nome, eventoPai: nil) // Chamamos o outro init como os valores padrões | não necessita de pai
    }
    
    // Implementação
    
    // duvidas por aqui, Sr. Enzo
    func addFilho(evento: Evento) {
        evento.eventoPai = self // Setamos A como pai de B
        self.subeventos.append(evento) // Adicionamos B como filho de A
    }
    
    public func selfDelete() {
        self.done = true
        // duvidas por aqui, Sr. Enzo
        var selfIndex: Int
        if let eventoPai = self.eventoPai {
            selfIndex = (eventoPai.subeventos.firstIndex(where: { $0.id == self.id })!)// compara a id do evento dentro do array do subeventos do evento pai
            eventoPai.subeventos.remove(at: selfIndex)// remove do array o evento
        } else {
            selfIndex = Model.shared.list.firstIndex(where: { $0.id == self.id })!// compara a id do evento dentro do array do subeventos do evento pai
            Model.shared.list.remove(at: selfIndex)// remove do array o evento
        }
        
        
        for evento in self.subeventos{ // autodelete os eventos dentro do evento deletado, para não dar conflito na somatória dos pontos depois
            evento.selfDelete()
        }
        //        self.subeventos.map { $0.selfDelete() }
        // duvidas por aqui, Sr. Enzo
        self.eventoPai = nil
    }
    
    public func autoDone(status : Bool) {
        self.done = status
        if self.eventoPai == nil{
            for i in subeventos {
                i.done = status
                i.autoDone(status: status)
            }
        }
        else{
            let selfIndex = (self.eventoPai?.subeventos.firstIndex(where: { $0.id == self.id }))!
            self.eventoPai?.subeventos[selfIndex].done = status
            for evento in self.subeventos{
                evento.autoDone(status: status)
            }
        }
    }
    public func autoNotDone() {
        self.done = false
        if self.eventoPai == nil{
            for i in subeventos {
                i.done = false
                i.autoNotDone()
            }
        }
        else{
            let selfIndex = (self.eventoPai?.subeventos.firstIndex(where: { $0.id == self.id }))!
            self.eventoPai?.subeventos[selfIndex].done = false
            for evento in self.subeventos{
                evento.autoNotDone()
            }
        }
    }
    
    func calcProgresso() -> Float {
        if self.subeventos.isEmpty {// se chegar no final da lista
            return self.done ? 100 : 0
        }
        
        let progressoFilhos = self.subeventos.map({ $0.calcProgresso() })// varre a arvore inteira de eventos e retorna 0 ou 1 para cada evento de acordo com o if acima
        
        let progressoTotal = progressoFilhos.reduce(0, { $0 + $1 } )// soma o progresso dos filhos
        
        return progressoTotal / Float(self.subeventos.count)// calc geral do progresso pai
        //return evento.subeventos.filter( {$0.done == true} ).count / evento.subeventos.count
        
    }
    
}

