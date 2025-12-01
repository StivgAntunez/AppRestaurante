import UIKit
import FirebaseFirestore
import FirebaseStorage

class PlatosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    let db = Firestore.firestore()
    var categoriaId: String = ""      // ID de la categoría enviada desde la pantalla anterior
    var platos: [Plato] = []          // Lista de platos

    var imagenSeleccionada: UIImage?  // Imagen seleccionada desde la galería

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        cargarPlatos()
    }

    // ============================================================
    // Cargar Platos
    // ============================================================
    func cargarPlatos() {

        db.collection("categorias")
            .document(categoriaId)
            .collection("platos")
            .getDocuments { snapshot, error in

                if let error = error {
                    print("Error cargando platos: \(error.localizedDescription)")
                    return
                }

                self.platos = snapshot?.documents.compactMap({ doc in

                    let nombre = doc["nombre"] as? String ?? "Sin nombre"
                    let precio = doc["precio"] as? Double ?? 0.0
                    let imagenURL = doc["imagenURL"] as? String ?? ""

                    return Plato(id: doc.documentID,
                                 nombre: nombre,
                                 precio: precio,
                                 imagenURL: imagenURL)

                }) ?? []

                self.tableView.reloadData()
            }
    }

    // ============================================================
    // Subir Imagen a Firebase Storage
    // ============================================================
    func subirImagen(_ imagen: UIImage, completion: @escaping (String?) -> Void) {

        let storageRef = Storage.storage().reference()
            .child("platos/\(UUID().uuidString).jpg")

        guard let data = imagen.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        storageRef.putData(data) { _, error in

            if let error = error {
                print("Error subiendo imagen: \(error.localizedDescription)")
                completion(nil)
                return
            }

            storageRef.downloadURL { url, _ in
                completion(url?.absoluteString)
            }
        }
    }

    // ============================================================
    // Tabla
    // ============================================================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return platos.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PlatoCell",
                                                 for: indexPath) as! PlatoCell

        let plato = platos[indexPath.row]

        cell.lblNombre.text = plato.nombre
        cell.lblPrecio.text = "S/ \(plato.precio)"

        if plato.imagenURL != "" {
            cell.imgPlato.loadFromURL(plato.imagenURL)
        } else {
            cell.imgPlato.image = UIImage(systemName: "photo")
        }

        return cell
    }

    // ============================================================
    // Botón Agregar Plato
    // ============================================================
    @IBAction func agregarPlato(_ sender: Any) {

        let alert = UIAlertController(title: "Nuevo Plato",
                                      message: "Ingrese nombre y precio",
                                      preferredStyle: .alert)

        alert.addTextField { $0.placeholder = "Nombre del plato" }
        alert.addTextField {
            $0.placeholder = "Precio"
            $0.keyboardType = .decimalPad
        }

        // Seleccionar Foto
        alert.addAction(UIAlertAction(title: "Elegir Foto", style: .default) { _ in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true)
        })

        // Guardar Plato
        alert.addAction(UIAlertAction(title: "Guardar", style: .default) { _ in

            let nombre = alert.textFields?[0].text ?? ""
            let precio = Double(alert.textFields?[1].text ?? "0") ?? 0

            // Si NO hay foto
            guard let imagen = self.imagenSeleccionada else {

                self.db.collection("categorias")
                    .document(self.categoriaId)
                    .collection("platos")
                    .addDocument(data: [
                        "nombre": nombre,
                        "precio": precio,
                        "imagenURL": ""
                    ])

                self.cargarPlatos()
                return
            }

            // Si hay foto → subir primero
            self.subirImagen(imagen) { url in

                self.db.collection("categorias")
                    .document(self.categoriaId)
                    .collection("platos")
                    .addDocument(data: [
                        "nombre": nombre,
                        "precio": precio,
                        "imagenURL": url ?? ""
                    ])

                self.cargarPlatos()
            }
        })

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))

        present(alert, animated: true)
    }

    // ============================================================
    // Swipe Editar - Eliminar
    // ============================================================
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {

        let editar = UIContextualAction(style: .normal, title: "Editar") { _, _, _ in
            self.editarPlato(index: indexPath.row)
        }
        editar.backgroundColor = .systemBlue

        let eliminar = UIContextualAction(style: .destructive, title: "Eliminar") { _, _, _ in
            self.eliminarPlato(index: indexPath.row)
        }

        return UISwipeActionsConfiguration(actions: [eliminar, editar])
    }

    // ============================================================
    // Editar Plato
    // ============================================================
    func editarPlato(index: Int) {

        let plato = platos[index]

        let alert = UIAlertController(title: "Editar Plato",
                                      message: "Modifique los valores",
                                      preferredStyle: .alert)

        alert.addTextField { $0.text = plato.nombre }
        alert.addTextField {
            $0.text = "\(plato.precio)"
            $0.keyboardType = .decimalPad
        }

        alert.addAction(UIAlertAction(title: "Guardar", style: .default) { _ in

            let nuevoNombre = alert.textFields?[0].text ?? ""
            let nuevoPrecio = Double(alert.textFields?[1].text ?? "0") ?? 0

            self.db.collection("categorias")
                .document(self.categoriaId)
                .collection("platos")
                .document(plato.id)
                .updateData([
                    "nombre": nuevoNombre,
                    "precio": nuevoPrecio
                ])

            self.cargarPlatos()
        })

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }

    // ============================================================
    // Eliminar Plato
    // ============================================================
    func eliminarPlato(index: Int) {

        let plato = platos[index]

        db.collection("categorias")
            .document(categoriaId)
            .collection("platos")
            .document(plato.id)
            .delete { error in

                if let error = error {
                    print("Error eliminando: \(error.localizedDescription)")
                    return
                }

                self.cargarPlatos()
            }
    }
}

// ============================================================
// UIImagePickerController
// ============================================================
extension PlatosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        imagenSeleccionada = info[.originalImage] as? UIImage
        dismiss(animated: true)
    }
}

// ============================================================
// Extensión para cargar imagen desde URL
// ============================================================


