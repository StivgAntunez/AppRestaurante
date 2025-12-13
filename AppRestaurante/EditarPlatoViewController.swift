import UIKit
import FirebaseFirestore

class EditarPlatoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var plato: Plato!
    var categoriaId: String = ""
    let db = Firestore.firestore()

    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtPrecio: UITextField!
    @IBOutlet weak var imgPlato: UIImageView!

    var nuevaImagen: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

      
        txtNombre.text = plato.nombre
        txtPrecio.text = "\(plato.precio)"

        imgPlato.loadFromURL(plato.imagenURL)
        imgPlato.layer.cornerRadius = 10
        imgPlato.clipsToBounds = true
    }

  
    @IBAction func cambiarImagen(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        nuevaImagen = info[.originalImage] as? UIImage
        imgPlato.image = nuevaImagen
        dismiss(animated: true)
    }

    
    @IBAction func guardarCambios(_ sender: Any) {
        print("Boton de agregar")

        guard let nombre = txtNombre.text, !nombre.isEmpty else { return }
        let precio = Double(txtPrecio.text ?? "0") ?? 0

        // Si NO cambió la imagen
        if nuevaImagen == nil {
            actualizarFirestore(nombre: nombre, precio: precio, imagenURL: plato.imagenURL)
            return
        }

        // Si cambió la imagen → subir a Cloudinary
        CloudinaryService.shared.uploadImage(nuevaImagen!) { url in
            DispatchQueue.main.async {
                if let url = url {
                    self.actualizarFirestore(nombre: nombre, precio: precio, imagenURL: url)
                } else {
                    print("Error subiendo a cloudinary")
                }
            }
        }
    }

  
    func actualizarFirestore(nombre: String, precio: Double, imagenURL: String) {

        db.collection("categorias")
            .document(categoriaId)
            .collection("platos")
            .document(plato.id)
            .updateData([
                "nombre": nombre,
                "precio": precio,
                "imagenURL": imagenURL
            ]) { error in
                
                if let error = error {
                    print("Error al actualizar:", error.localizedDescription)
                    return
                }

                self.dismiss(animated: true)
            }
    }
}
