import UIKit
import FirebaseFirestore

class DetallePlatoViewController: UIViewController {

    var plato: Plato!
    var categoriaId: String = ""

    var onPlatoEliminado: (() -> Void)?   // 🔥 Callback para avisar al padre

    @IBOutlet weak var imgPlato: UIImageView!
    @IBOutlet weak var lblNombre: UILabel!
    @IBOutlet weak var lblPrecio: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        lblNombre.text = plato.nombre
        lblPrecio.text = "S/ \(plato.precio)"
        imgPlato.loadFromURL(plato.imagenURL)
    }

    // ============================================================
    // EDITAR PLATO
    // ============================================================
    @IBAction func editarPlato(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(
            withIdentifier: "EditarPlatoVC"
        ) as! EditarPlatoViewController

        vc.plato = plato
        vc.categoriaId = categoriaId

        present(vc, animated: true)
    }

    // ============================================================
    // 🚨 ELIMINAR PLATO
    // ============================================================
    @IBAction func eliminarPlato(_ sender: Any) {

        let alert = UIAlertController(
            title: "Eliminar plato",
            message: "¿Deseas eliminar este plato?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))

        alert.addAction(UIAlertAction(
            title: "Eliminar",
            style: .destructive,
            handler: { _ in
                self.eliminar()
            }
        ))

        present(alert, animated: true)
    }

    private func eliminar() {
        let db = Firestore.firestore()

        db.collection("categorias")
            .document(categoriaId)
            .collection("platos")
            .document(plato.id)
            .delete { error in

                if let error = error {
                    print("❌ Error al eliminar:", error.localizedDescription)
                    return
                }

                print("✅ Plato eliminado correctamente")

                // Notificar al padre (PlatosViewController)
                self.onPlatoEliminado?()

                // Cerrar modal
                self.dismiss(animated: true)
            }
    }
}
