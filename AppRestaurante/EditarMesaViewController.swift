import UIKit
import FirebaseFirestore

class EditarMesaViewController: UIViewController {

    @IBOutlet weak var txtNumero: UITextField!
    @IBOutlet weak var txtSillas: UITextField!
    @IBOutlet weak var segEstado: UISegmentedControl!

    let db = Firestore.firestore()
    var mesa: Mesa!
    var onMesaEditada: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        
        txtNumero.delegate = self
        txtSillas.delegate = self

        txtNumero.keyboardType = .numberPad
        txtSillas.keyboardType = .numberPad

        cargarDatos()
    }

    func cargarDatos() {
        txtNumero.text = "\(mesa.numero)"
        txtSillas.text = "\(mesa.sillas)"

        switch mesa.estado {
        case "libre": segEstado.selectedSegmentIndex = 0
        case "ocupada": segEstado.selectedSegmentIndex = 1
        case "atendida": segEstado.selectedSegmentIndex = 2
        default: segEstado.selectedSegmentIndex = 0
        }
    }

    @IBAction func guardarCambios(_ sender: Any) {

        guard
            let numero = Int(txtNumero.text ?? ""),
            let sillas = Int(txtSillas.text ?? "")
        else {
            mostrarAlerta(titulo: "Error", mensaje: "Ingrese solo números válidos.")
            return
        }

        let estado = segEstado.titleForSegment(at: segEstado.selectedSegmentIndex)!
            .lowercased()

        db.collection("mesas").document(mesa.id).updateData([
            "numero": numero,
            "estado": estado,
            "sillas": sillas
        ]) { error in

            if let error = error {
                print("Error al editar mesa: \(error)")
                return
            }

            // 🔥 Mensaje de éxito
            self.mostrarAlerta(titulo: "Actualizado", mensaje: "Mesa actualizada correctamente.") {
                self.onMesaEditada?()
                self.dismiss(animated: true)
            }
        }
    }

    @IBAction func cerrar(_ sender: Any) {
        dismiss(animated: true)
    }

  
    func mostrarAlerta(titulo: String, mensaje: String, completado: (() -> Void)? = nil) {
        let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completado?()
        }))

        present(alert, animated: true)
    }
}

extension EditarMesaViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        
        let allowed = CharacterSet.decimalDigits
        let chars = CharacterSet(charactersIn: string)
        return allowed.isSuperset(of: chars)
    }
}
