import UIKit

class MesaCell: UITableViewCell {

    @IBOutlet weak var lblNumeroMesa: UILabel!
    
    @IBOutlet weak var lblEstado: UILabel!
    
    @IBOutlet weak var lblSillas: UILabel!
    
    @IBOutlet weak var estadoView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        
        estadoView.layer.cornerRadius = estadoView.frame.size.width / 2
        estadoView.clipsToBounds = true
    }

   
    func configurarEstado(_ estado: String) {
        switch estado.lowercased() {
        case "libre":
            estadoView.backgroundColor = .systemGreen
        case "ocupada":
            estadoView.backgroundColor = .systemRed
        case "atendida":
            estadoView.backgroundColor = .systemYellow
        default:
            estadoView.backgroundColor = .lightGray
        }
    }
}
