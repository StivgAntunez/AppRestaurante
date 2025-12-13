import UIKit
import FirebaseFirestore

struct Pedido {
    var id: String
    var mesaNumero: Int
    var total: Double
    var estado: String
    var fecha: Timestamp
}

class CocineroPedidosViewController: UIViewController,
                                     UITableViewDelegate,
                                     UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    let db = Firestore.firestore()
    var pedidos: [Pedido] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        obtenerPedidosDeHoy()
    }

  
    func obtenerPedidosDeHoy() {

        
        let inicioDia = Calendar.current.startOfDay(for: Date())

        db.collection("pedidos")
            .whereField("fecha", isGreaterThanOrEqualTo: Timestamp(date: inicioDia))
            .order(by: "fecha", descending: false)
            .addSnapshotListener { snapshot, error in

                if let error = error {
                    print("Error al obtener pedidos: \(error)")
                    return
                }

                self.pedidos.removeAll()

                snapshot?.documents.forEach { doc in
                    let data = doc.data()

                    let pedido = Pedido(
                        id: doc.documentID,
                        mesaNumero: data["mesaNumero"] as? Int ?? 0,
                        total: data["total"] as? Double ?? 0,
                        estado: data["estado"] as? String ?? "pendiente",
                        fecha: data["fecha"] as? Timestamp ?? Timestamp()
                    )

                    self.pedidos.append(pedido)
                }

                self.tableView.reloadData()
            }
    }

   
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        pedidos.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PedidoCell",
            for: indexPath
        ) as! PedidoCell

        let pedido = pedidos[indexPath.row]

        cell.lblMesa.text = "Mesa \(pedido.mesaNumero)"
        cell.lblTotal.text = "S/ \(pedido.total)"

      
        let date = pedido.fecha.dateValue()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        cell.lblHora.text = formatter.string(from: date)

        cell.lblEstado.text = pedido.estado.capitalized

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let pedido = pedidos[indexPath.row]

        let vc = storyboard?.instantiateViewController(
            withIdentifier: "CocineroPedidoDetalleViewController"
        ) as! CocineroPedidoDetalleViewController

        vc.pedidoId = pedido.id
        vc.modalPresentationStyle = .fullScreen

        present(vc, animated: true)
    }
}


