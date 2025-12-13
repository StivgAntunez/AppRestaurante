import UIKit

class MeseroViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnIrAPedidoPressed(_ sender: Any) {
        irAPedidos()
    }
    
    func irAPedidos() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MeseroPedidoViewController")
        vc?.modalPresentationStyle = .fullScreen
        present(vc!, animated: true)
    }
}
