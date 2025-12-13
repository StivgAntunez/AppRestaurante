import UIKit
import FirebaseAuth

class AdminViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnCategoriasPressed(_ sender: Any) {
        irACategorias()
    }

    @IBAction func btnMesasPressed(_ sender: Any) {
        irAMesas()
    }
    
    @IBAction func cerrarSesion(_ sender: Any) {

        let alerta = UIAlertController(
            title: "Cerrar sesión",
            message: "¿Desea cerrar sesión?",
            preferredStyle: .alert
        )

        let btnCancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)

        let btnAceptar = UIAlertAction(title: "Aceptar", style: .destructive) { _ in
            do {
                try Auth.auth().signOut()

                // Volver al login
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")

                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true)

            } catch let error {
                print("Error al cerrar sesión: \(error.localizedDescription)")
            }
        }

        alerta.addAction(btnCancelar)
        alerta.addAction(btnAceptar)

        present(alerta, animated: true)
    }

    func irACategorias() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CategoryViewController")
        vc?.modalPresentationStyle = .fullScreen
        present(vc!, animated: true)
    }

    func irAMesas() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MesasViewController")
        vc?.modalPresentationStyle = .fullScreen
        present(vc!, animated: true)
    }
}
