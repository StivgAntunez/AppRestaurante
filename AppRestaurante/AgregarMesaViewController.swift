import UIKit
import FirebaseFirestore

class AgregarMesaViewController: UIViewController {

    @IBOutlet weak var txtNumero: UITextField!
    @IBOutlet weak var txtSillas: UITextField!
    @IBOutlet weak var segEstado: UISegmentedControl!

    let db = Firestore.firestore()
    var onMesaAgregada: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        txtNumero.delegate = self
        txtSillas.delegate = self

        txtNumero.keyboardType = .numberPad
        txtSillas.keyboardType = .numberPad
    }

    @IBAction func guardarMesa(_ sender: Any) {

        guard
            let numero = Int(txtNumero.text ?? ""),
            let sillas = Int(txtSillas.text ?? "")
        else {
            print("Datos inválidos")
            return
        }

        let estado = segEstado.titleForSegment(at: segEstado.selectedSegmentIndex)!.lowercased()

        db.collection("mesas").addDocument(data: [
            "numero": numero,
            "estado": estado,
            "sillas": sillas
        ]) { error in

            if let error = error {
                print("Error al guardar mesa: \(error)")
                return
            }

            let alert = UIAlertController(
                title: "Éxito",
                message: "Mesa guardada satisfactoriamente.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.onMesaAgregada?()
                self.dismiss(animated: true)
            }))

            self.present(alert, animated: true)
        }
    }

    @IBAction func cerrar(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension AgregarMesaViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
