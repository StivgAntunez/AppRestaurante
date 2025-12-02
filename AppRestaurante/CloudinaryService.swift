import Foundation
import UIKit

class CloudinaryService {
    
    static let shared = CloudinaryService()
    
    // 👉 Tu cloud name REAL
    private let cloudName = "dyh8tbkfe"

    // 👉 Upload preset por defecto (funciona en Cloudinary)
    private let uploadPreset = "resto_unsigned"

    func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: no se pudo convertir la imagen a JPEG.")
            completion(nil)
            return
        }
        
        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // upload_preset
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(uploadPreset)\r\n".data(using: .utf8)!)
        
        // imagen
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"plato.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error Cloudinary:", error.localizedDescription)
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("Sin datos desde Cloudinary")
                completion(nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let url = json["secure_url"] as? String {
                completion(url)
            } else {
                print("Error Cloudinary:", String(data: data, encoding: .utf8) ?? "")
                completion(nil)
            }
            
        }.resume()
    }
}
