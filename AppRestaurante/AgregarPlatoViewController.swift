import UIKit
import FirebaseFirestore

class AgregarPlatoViewController: UIViewController,
                                  UIImagePickerControllerDelegate,
                                  UINavigationControllerDelegate {

    var categoriaId: String = ""
    let db = Firestore.firestore()

    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtPrecio: UITextField!
    @IBOutlet weak var imgPlato: UIImageView!

    var imagenSeleccionada: UIImage?

  
    var onPlatoGuardado: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        imgPlato.layer.cornerRadius = 10
        imgPlato.clipsToBounds = true
    }

 
    @IBAction func elegirFoto(_ sender: Any) {

        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary

        present(picker, animated: true)
    }

    
    @IBAction func guardarPlato(_ sender: Any) {

        guard let nombre = txtNombre.text, !nombre.isEmpty else { return }
        let precio = Double(txtPrecio.text ?? "0") ?? 0

       
        guard let imagen = imagenSeleccionada else {
            guardarPlatoEnFirestore(nombre: nombre, precio: precio, imagenURL: "")
            return
        }

        
        CloudinaryService.shared.uploadImage(imagen) { url in

            DispatchQueue.main.async {

                guard let url = url else {
                    print("Error al subir imagen a Cloudinary")
                    return
                }

                print("Imagen subida: \(url)")

                self.guardarPlatoEnFirestore(
                    nombre: nombre,
                    precio: precio,
                    imagenURL: url
                )
            }
        }
    }


    func guardarPlatoEnFirestore(nombre: String, precio: Double, imagenURL: String) {

        db.collection("categorias")
          .document(categoriaId)
          .collection("platos")
          .addDocument(data: [
                "nombre": nombre,
                "precio": precio,
                "imagenURL": imagenURL
          ]) { _ in

                self.onPlatoGuardado?()
                self.dismiss(animated: true)
          }
    }

  
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        imagenSeleccionada = info[.originalImage] as? UIImage
        imgPlato.image = imagenSeleccionada

        picker.dismiss(animated: true)
    }
}
