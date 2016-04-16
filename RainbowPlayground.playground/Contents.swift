
import UIKit

let names = ["RedStripeOnWhite.jpg","OrangeStripeOnWhite.jpg",
             "YellowStripeOnWhite.jpg","GreenStripeOnWhite.jpg",
             "BlackHorizontal.jpg","BlueStripeOnWhite.jpg",
             "IndigoStripeOnWhite.jpg","VioletStripeOnWhite.jpg"]

let images = names.map {
    UIImage(named: $0)
}

func mono(image:UIImage?) -> Bool {
    let rgba = UnsafeMutablePointer<CUnsignedChar>.alloc(4)
    let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
    let info = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
    let context: CGContextRef = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, info.rawValue)!
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image!.CGImage)
    
    if ( CGFloat(rgba[0]) <  245 && CGFloat(rgba[1]) <  245 && CGFloat(rgba[2]) <  245) {
        //monochrome (or close to it)
        return true
    }
    return false
}

let colorImages = images.filter { !mono($0) }

let ciImages = colorImages.map { (sourceImage) -> CIImage? in
    if let source = sourceImage, raw = source.CGImage {
        let colorMasking: [CGFloat] = [250, 255, 250, 255, 250, 255]
        UIGraphicsBeginImageContext(source.size)
        if let mask = CGImageCreateWithMaskingColors(raw, colorMasking) {
            CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, source.size.width, source.size.height), mask)
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let retVal = CIImage(image:img) {
                return retVal
            }
        }
    }
    return nil
}


let outputImage = ciImages.reduce(CIImage()) { (s, img) -> CIImage? in
    let f = CIFilter(name: "CISourceOverCompositing")
    f?.setValue(s, forKey: kCIInputBackgroundImageKey)
    f?.setValue(img, forKey:kCIInputImageKey)
    
    return f?.outputImage
}

if let outputImage = outputImage {
    let image = UIImage(CIImage: outputImage)
}
