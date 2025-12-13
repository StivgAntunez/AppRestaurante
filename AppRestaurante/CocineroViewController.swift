
import UIKit

class CocineroViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func btnVerPedidos(_ sender: Any) {
        irAPedidos()
    }

    func irAPedidos() {
        let vc = storyboard?.instantiateViewController(
            withIdentifier: "CocineroPedidosViewController"
        )

        vc?.modalPresentationStyle = .fullScreen
        present(vc!, animated: true)
    }
}
