import UIKit
import FirebaseFirestore

class MesasViewController: UIViewController,
                           UITableViewDelegate,
                           UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    let db = Firestore.firestore()
    var mesas: [Mesa] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        obtenerMesas()
    }

    func obtenerMesas() {
        db.collection("mesas")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error al obtener mesas: \(error)")
                    return
                }

                self.mesas.removeAll()

                snapshot?.documents.forEach { doc in
                    let data = doc.data()

                    let mesa = Mesa(
                        id: doc.documentID,
                        numero: data["numero"] as? Int ?? 0,
                        estado: data["estado"] as? String ?? "libre",
                        sillas: data["sillas"] as? Int ?? 0
                    )

                    self.mesas.append(mesa)
                }

                self.tableView.reloadData()
            }
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return mesas.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "MesaCell",
            for: indexPath
        ) as! MesaCell

        let mesa = mesas[indexPath.row]

        cell.lblNumeroMesa.text = "Mesa \(mesa.numero)"
        cell.lblEstado.text = mesa.estado.capitalized
        cell.lblSillas.text = "\(mesa.sillas) sillas"

       
        cell.configurarEstado(mesa.estado)

        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        let mesa = mesas[indexPath.row]

        
        let eliminar = UIContextualAction(style: .destructive, title: "Eliminar") { _, _, done in
            
            self.db.collection("mesas").document(mesa.id).delete { error in
                if let error = error {
                    print("Error eliminando mesa: \(error)")
                }
            }

            done(true)
        }

      
        let editar = UIContextualAction(style: .normal, title: "Editar") { _, _, done in
            
            let vc = self.storyboard?.instantiateViewController(
                withIdentifier: "EditarMesaVC"
            ) as! EditarMesaViewController

            vc.mesa = mesa

            vc.onMesaEditada = {
                self.obtenerMesas()
            }

            self.present(vc, animated: true)
            done(true)
        }

        editar.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [eliminar, editar])
    }

    @IBAction func agregarMesa(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AgregarMesaVC") as! AgregarMesaViewController

        // Cuando se guarde, refresca la tabla
        vc.onMesaAgregada = {
            self.obtenerMesas()
        }

        present(vc, animated: true)
    }
}
