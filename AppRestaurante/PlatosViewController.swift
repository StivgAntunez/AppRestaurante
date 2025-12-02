import UIKit
import FirebaseFirestore

class PlatosViewController: UIViewController,
                            UITableViewDelegate,
                            UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    let db = Firestore.firestore()
    var categoriaId: String = ""
    var platos: [Plato] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        cargarPlatos()
    }

    // ============================================================
    // CARGAR PLATOS
    // ============================================================
    func cargarPlatos() {

        db.collection("categorias")
            .document(categoriaId)
            .collection("platos")
            .getDocuments { snapshot, error in

                if let error = error {
                    print("Error cargando platos:", error.localizedDescription)
                    return
                }

                self.platos = snapshot?.documents.compactMap({ doc in

                    let nombre = doc["nombre"] as? String ?? "Sin nombre"
                    let precio = doc["precio"] as? Double ?? 0
                    let imagenURL = doc["imagenURL"] as? String ?? ""

                    return Plato(
                        id: doc.documentID,
                        nombre: nombre,
                        precio: precio,
                        imagenURL: imagenURL
                    )
                }) ?? []

                self.tableView.reloadData()
            }
    }

    // ============================================================
    // TABLEVIEW
    // ============================================================
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
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
    // TOCAR CELDA → DETALLE
    // ============================================================
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let vc = storyboard?.instantiateViewController(
            withIdentifier: "DetallePlatoVC"
        ) as! DetallePlatoViewController

        vc.plato = platos[indexPath.row]
        vc.categoriaId = categoriaId

        // 🔥 Callback para cuando eliminen el plato
        vc.onPlatoEliminado = {
            self.cargarPlatos()
        }

        present(vc, animated: true)
    }

    // ============================================================
    // ABRIR AGREGAR PLATO
    // ============================================================
    @IBAction func agregarPlato(_ sender: Any) {

        let vc = storyboard?.instantiateViewController(
            withIdentifier: "AgregarPlatoVC"
        ) as! AgregarPlatoViewController

        vc.categoriaId = categoriaId

        vc.onPlatoGuardado = {
            self.cargarPlatos()
        }

        present(vc, animated: true)
    }
}
