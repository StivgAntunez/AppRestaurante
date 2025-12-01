import UIKit
import FirebaseFirestore


class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    var categorias: [Categoria] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        cargarCategorias()
    }
    
    func cargarCategorias() {
        db.collection("categorias").getDocuments { snapshot, error in
            if let error = error {
                print("Error cargando categorías: \(error.localizedDescription)")
                return
            }
            
            self.categorias = snapshot?.documents.compactMap({ doc in
                let nombre = doc["nombre"] as? String ?? "Sin nombre"
                return Categoria(id: doc.documentID, nombre: nombre)
            }) ?? []
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorias.count
    }
    
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "categoriaCell",
            for: indexPath
        )
        
        cell.textLabel?.text = categorias[indexPath.row].nombre
        return cell
    }
    
    @IBAction func btnAgregarPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Nueva Categoría",
                                      message: "Ingrese el nombre",
                                      preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Nombre de categoría"
        }

        let aceptar = UIAlertAction(title: "Guardar", style: .default) { _ in
            let nombre = alert.textFields?.first?.text ?? ""

            if nombre.isEmpty {
                return
            }

            self.guardarCategoria(nombre: nombre)
        }

        let cancelar = UIAlertAction(title: "Cancelar", style: .cancel)

        alert.addAction(aceptar)
        alert.addAction(cancelar)

        present(alert, animated: true)
    }


    func guardarCategoria(nombre: String) {
        let nuevaCategoria = [
            "nombre": nombre
        ]

        db.collection("categorias").addDocument(data: nuevaCategoria) { error in
            if let error = error {
                print("Error guardando: \(error.localizedDescription)")
                return
            }

            print("Categoría registrada correctamente")
            self.cargarCategorias()   // recargar tabla
        }
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {

        let editar = UIContextualAction(style: .normal, title: "Editar") { _, _, _ in
            self.editarCategoria(index: indexPath.row)
        }

        editar.backgroundColor = .systemBlue

        let eliminar = UIContextualAction(style: .destructive, title: "Eliminar") { _, _, _ in
            self.eliminarCategoria(index: indexPath.row)
        }

        return UISwipeActionsConfiguration(actions: [eliminar, editar])
    }


    func editarCategoria(index: Int) {

        let categoria = categorias[index]

        let alert = UIAlertController(title: "Editar Categoría",
                                      message: "Modifique el nombre",
                                      preferredStyle: .alert)

        alert.addTextField { textField in
            textField.text = categoria.nombre
        }

        let aceptar = UIAlertAction(title: "Guardar", style: .default) { _ in
            let nuevoNombre = alert.textFields?.first?.text ?? ""

            self.db.collection("categorias")
                .document(categoria.id)
                .updateData(["nombre": nuevoNombre])

            self.cargarCategorias()
        }

        alert.addAction(aceptar)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))

        present(alert, animated: true)
    }

    func eliminarCategoria(index: Int) {

        let categoria = categorias[index]

        db.collection("categorias")
            .document(categoria.id)
            .delete { error in

                if let error = error {
                    print("Error eliminando: \(error.localizedDescription)")
                    return
                }

                print("Categoría eliminada")
                self.cargarCategorias()
            }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let categoria = categorias[indexPath.row]

        // Ir a la pantalla de platos
        let vc = storyboard?.instantiateViewController(withIdentifier: "PlatosViewController") as! PlatosViewController
        
        // Pasar el ID de la categoría
        vc.categoriaId = categoria.id

        present(vc, animated: true)
    }
}
