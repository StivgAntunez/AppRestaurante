import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {

    @IBOutlet weak var txtCorreo: UITextField!
    @IBOutlet weak var txtPassword: UITextField!

    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func btnLoginPressed(_ sender: Any) {
        print("BOTÓN LOGIN PRESIONADO")
        login()
    }
    
    func login() {
        guard let correo = txtCorreo.text, !correo.isEmpty else {
            mostrarAlerta(titulo: "Error", mensaje: "Ingrese su correo.")
            return
        }
        
        guard let password = txtPassword.text, !password.isEmpty else {
            mostrarAlerta(titulo: "Error", mensaje: "Ingrese su contraseña.")
            return
        }
        
        
        if !esCorreoValido(correo) {
            mostrarAlerta(titulo: "Correo inválido", mensaje: "Ingrese un correo electrónico válido.")
            return
        }
        
       
        if password.count < 6 {
            mostrarAlerta(titulo: "Contraseña débil", mensaje: "La contraseña debe tener al menos 6 caracteres.")
            return
        }

       
        Auth.auth().signIn(withEmail: correo, password: password) { result, error in
            if let error = error {
                self.mostrarAlerta(titulo: "Login fallido", mensaje: error.localizedDescription)
                return
            }

            guard let user = result?.user else { return }
            print("UID DEL USUARIO:", user.uid)

            self.obtenerRol(uid: user.uid)
        }
    }
    
    func esCorreoValido(_ correo: String) -> Bool {
      
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        return pred.evaluate(with: correo)
    }

    func mostrarAlerta(titulo: String, mensaje: String) {
        let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

  
    func obtenerRol(uid: String) {
        db.collection("usuarios").document(uid).getDocument { document, error in
            if let error = error {
                self.mostrarAlerta(titulo: "Error Firestore", mensaje: error.localizedDescription)
                return
            }

            guard let data = document?.data(),
                  let rol = data["rol"] as? String else {
                self.mostrarAlerta(titulo: "Error", mensaje: "El usuario no tiene rol asignado.")
                return
            }

            print("ROL OBTENIDO:", rol)
            self.redirigirSegunRol(rol)
        }
    }

    func redirigirSegunRol(_ rol: String) {
        switch rol {
        case "admin": irA("AdminViewController")
        case "mesero": irA("MeseroViewController")
        case "cocinero": irA("CocineroViewController")
        default:
            mostrarAlerta(titulo: "Error", mensaje: "Rol desconocido.")
        }
    }

    func irA(_ identifier: String) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: identifier) {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
}
