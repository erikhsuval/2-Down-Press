import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeUtils {
    static func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)
        filter.correctionLevel = "H"  // High error correction
        
        guard let qrImage = filter.outputImage else { return nil }
        
        // Scale up the image for better visibility
        let scale = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQRImage = qrImage.transformed(by: scale)
        
        guard let cgImage = context.createCGImage(scaledQRImage, from: scaledQRImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
} 