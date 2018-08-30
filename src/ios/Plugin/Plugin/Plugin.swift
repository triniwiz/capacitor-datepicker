import Foundation
import Capacitor

class PickerViewController: UIViewController {
    public var bridge: CAPBridge?
    public var rotateDelegate: PickerViewControllerDelegate?

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isPortrait {
            rotateDelegate?.deviceDidRotateWithViewController(isPortrait: true,viewController: self)
        } else {
            rotateDelegate?.deviceDidRotateWithViewController(isPortrait: false,viewController: self)
        }
    }

    func setCenteredPopover(){
        self.popoverPresentationController?.sourceRect = CGRect(x:(bridge?.viewController.view.center.x)!, y:(bridge?.viewController.view.center.y)!,width: 0,height: 0);
        self.popoverPresentationController?.sourceView = bridge?.viewController.view;
        self.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0);
    }
}

protocol PickerViewControllerDelegate {
    func deviceDidRotateWithViewController(isPortrait: Bool, viewController: PickerViewController)
}

@objc(DatePickerPlugin)
public class DatePickerPlugin: CAPPlugin , UIPopoverPresentationControllerDelegate ,PickerViewControllerDelegate{

    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {

    }

    func deviceDidRotateWithViewController(isPortrait: Bool, viewController: PickerViewController){
        let alertSize = CGSize(width: UIScreen.main.bounds.size.width / 2, height: UIScreen.main.bounds.size.height / 2)
        viewController.preferredContentSize = CGSize(width: alertSize.width, height: alertSize.height)
        //viewController.setCenteredPopover()
    }


    @objc func show(_ call: CAPPluginCall) {
        let mode = call.getString("mode") ?? "date"
        let date = call.getString("date")
        let min = call.getString("min")
        let max = call.getString("max")
        let title = call.getString("title")
        let okText = call.getString("okText")
        let cancelText = call.getString("cancelText")
        let okButtonColor = call.getString("okButtonColor")
        let cancelButtonColor = call.getString("cancelButtonColor")
        let is24Hours = call.getBool("is24Hours") ?? false
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let titleDateFormatter =  DateFormatter.init()
        titleDateFormatter.dateFormat = "E, MMM d, yyyy"
        let titleDate = titleDateFormatter.string(from: dateFormatter.date(from: date!)!)
        DispatchQueue.main.async {
            var object: [String:Any] = [:]
            let picker = UIDatePicker()
            let alert = PickerViewController() //UIAlertController.init(title: title != nil ? title : titleDate, message: nil, preferredStyle: .alert)
            alert.modalPresentationStyle = .popover
            alert.popoverPresentationController?.delegate = self
            alert.rotateDelegate = self;
            alert.view.backgroundColor = UIColor.white
            let alertSize = CGSize(width: UIScreen.main.bounds.size.width / 2, height: UIScreen.main.bounds.size.height / 2)
           // alert.view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            let alertView = UIView()
            let titleView = UILabel(frame: CGRect(x: 0, y: 0, width: alertSize.width, height: 44))
            titleView.text = title != nil ? title : titleDate
            alertView.addSubview(titleView);
            alertView.addSubview(picker)
            /*
             let cancelButton = UIAlertAction.init(title: cancelText != nil ? cancelText : "Cancel", style: .cancel, handler:{ action in
             object["value"] = nil
             call.resolve(object)
             alert.dismiss(animated: true, completion: nil)
             })

             if(cancelButtonColor != nil){
             let cancelColor  = ColorName[cancelButtonColor!]
             cancelButton.setValue(UIColor(hexString: cancelColor != nil ? cancelColor! : cancelButtonColor!), forKey: "titleTextColor")
             }

             alert.addAction(cancelButton)


             let okButton = UIAlertAction.init(title: okText != nil ? okText : "Ok", style: .default, handler:{ action in
             object["value"] = dateFormatter.string(from: picker.date)
             call.resolve(object)
             alert.dismiss(animated: true, completion: nil)
             })

             if(okButtonColor != nil){
             let okColor = ColorName[okButtonColor!]
             okButton.setValue(UIColor(hexString: okColor != nil ? okColor! : okButtonColor!), forKey: "titleTextColor")
             }

             alert.addAction(okButton)
             */

            picker.setDate(dateFormatter.date(from: date!)!, animated: false)

            if(max != nil){
                picker.maximumDate = dateFormatter.date(from: max!)!
            }
            if(min != nil){
                picker.minimumDate = dateFormatter.date(from: min!)!
            }

            if(mode == "time"){
                picker.datePickerMode = UIDatePickerMode.time
            }else{
                picker.datePickerMode = UIDatePickerMode.date
            }


            alert.popoverPresentationController?.sourceView = alertView

            alert.preferredContentSize =  CGSize(width:alertSize.width, height: alertSize.height)

            alert.bridge = self.bridge
            alert.setCenteredPopover()
            self.bridge.viewController.present(alert, animated: true,completion:nil)
        }
    }
}




extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat

        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}



let ColorName: [String:String] = [
    "transparent" : "#00000000",
    "aliceblue" : "#F0F8FF",
    "antiquewhite" : "#FAEBD7",
    "aqua": "#00FFFF",
    "cyan" : "#00FFFF",
    "aquamarine" : "#7FFFD4",
    "azure" : "#F0FFFF",
    "beige" : "#F5F5DC",
    "bisque" : "#FFE4C4",
    "black" : "#000000",
    "blanchedAlmond" : "#FFEBCD",
    "blue" : "#0000FF",
    "blueViolet" : "#8A2BE2",
    "brown" : "#A52A2A",
    "burlyWood" : "#DEB887",
    "cadetBlue" : "#5F9EA0",
    "chartreuse" : "#7FFF00",
    "chocolate" : "#D2691E",
    "coral" : "#FF7F50",
    "cornflowerBlue" : "#6495ED",
    "cornsilk" : "#FFF8DC",
    "crimson" : "#DC143C",
    "darkblue" : "#00008B",
    "darkcyan" : "#008B8B",
    "darkgoldenrod" : "#B8860B",
    "darkgray" : "#A9A9A9",
    "darkgreen" : "#006400",
    "darkkhaki" : "#BDB76B",
    "darkmagenta" : "#8B008B",
    "darkolivegreen" : "#556B2F",
    "darkorange" : "#FF8C00",
    "darkorchid" : "#9932CC",
    "darkred" : "#8B0000",
    "darksalmon" : "#E9967A",
    "darkseaGreen" : "#8FBC8F",
    "darkslateBlue" : "#483D8B",
    "darkslateGray" : "#2F4F4F",
    "darkturquoise" : "#00CED1",
    "darkniolet" : "#9400D3",
    "deeppink" : "#FF1493",
    "deepskyBlue" : "#00BFFF",
    "dimgray" : "#696969",
    "dodgerblue" : "#1E90FF",
    "firebrick" : "#B22222",
    "floralwhite" : "#FFFAF0",
    "forestgreen" : "#228B22",
    "gainsboro" : "#DCDCDC",
    "ghostwhite" : "#F8F8FF",
    "gold" : "#FFD700",
    "goldenrod" : "#DAA520",
    "gray" : "#808080",
    "green" : "#008000",
    "greenyellow" : "#ADFF2F",
    "honeydew" : "#F0FFF0",
    "hotpink" : "#FF69B4",
    "indianred" : "#CD5C5C",
    "indigo" : "#4B0082",
    "ivory" : "#FFFFF0",
    "khaki" : "#F0E68C",
    "lavender" : "#E6E6FA",
    "lavenderblush" : "#FFF0F5",
    "lawngreen" : "#7CFC00",
    "lemonchiffon" : "#FFFACD",
    "lightblue" : "#ADD8E6",
    "lightcoral" : "#F08080",
    "lightcyan" : "#E0FFFF",
    "lightgoldenRodYellow" : "#FAFAD2",
    "lightgray" : "#D3D3D3",
    "lightgreen" : "#90EE90",
    "lightpink" : "#FFB6C1",
    "lightsalmon" : "#FFA07A",
    "lightseaGreen" : "#20B2AA",
    "lightskyBlue" : "#87CEFA",
    "lightslateGray" : "#778899",
    "lightsteelBlue" : "#B0C4DE",
    "lightyellow" : "#FFFFE0",
    "lime" : "#00FF00",
    "limegreen" : "#32CD32",
    "linen" : "#FAF0E6",
    "fuchsia": "#FF00FF",
    "magenta" : "#FF00FF",
    "maroon" : "#800000",
    "mediumaquamarine" : "#66CDAA",
    "mediumblue" : "#0000CD",
    "mediumorchid" : "#BA55D3",
    "mediumpurple" : "#9370DB",
    "mediumseagreen" : "#3CB371",
    "mediumslateblue" : "#7B68EE",
    "mediumspringgreen" : "#00FA9A",
    "mediumturquoise" : "#48D1CC",
    "mediumvioletred" : "#C71585",
    "midnightblue" : "#191970",
    "mintcream" : "#F5FFFA",
    "mistyrose" : "#FFE4E1",
    "moccasin" : "#FFE4B5",
    "navajowhite" : "#FFDEAD",
    "navy" : "#000080",
    "oldlace" : "#FDF5E6",
    "olive" : "#808000",
    "olivedrab" : "#6B8E23",
    "orange" : "#FFA500",
    "orangered" : "#FF4500",
    "orchid" : "#DA70D6",
    "palegoldenrod" : "#EEE8AA",
    "palegreen" : "#98FB98",
    "paleturquoise" : "#AFEEEE",
    "palevioletred" : "#DB7093",
    "papayawhip" : "#FFEFD5",
    "peachpuff" : "#FFDAB9",
    "peru" : "#CD853F",
    "pink" : "#FFC0CB",
    "plum" : "#DDA0DD",
    "powderblue" : "#B0E0E6",
    "purple" : "#800080",
    "red" : "#FF0000",
    "rosybrown" : "#BC8F8F",
    "royalblue" : "#4169E1",
    "saddlebrown" : "#8B4513",
    "salmon" : "#FA8072",
    "sandybrown" : "#F4A460",
    "seagreen" : "#2E8B57",
    "seashell" : "#FFF5EE",
    "sienna" : "#A0522D",
    "silver" : "#C0C0C0",
    "skyblue" : "#87CEEB",
    "slateblue" : "#6A5ACD",
    "slategray" : "#708090",
    "snow" : "#FFFAFA",
    "springgreen" : "#00FF7F",
    "steelblue" : "#4682B4",
    "tan" : "#D2B48C",
    "teal" : "#008080",
    "thistle" : "#D8BFD8",
    "tomato" : "#FF6347",
    "turquoise" : "#40E0D0",
    "violet" : "#EE82EE",
    "wheat" : "#F5DEB3",
    "white" : "#FFFFFF",
    "whitesmoke" : "#F5F5F5",
    "yellow" : "#FFFF00",
    "yellowgreen" : "#9ACD32"
]
