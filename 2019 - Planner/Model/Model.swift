import Foundation
class Model {
    static let shared = Model()
    var eventosFilePath: String{
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return url!.appendingPathComponent("eventos").path
    }
    var list: [Evento]!{
        didSet{
            self.persistEvents()
        }
    }
    private init(){
        self.list = NSKeyedUnarchiver.unarchiveObject(withFile: eventosFilePath) as? [Evento] ?? [Evento]()
    }
    
    func persistEvents(){
        NSKeyedArchiver.archiveRootObject(list, toFile: eventosFilePath)
    }
    
    

}
