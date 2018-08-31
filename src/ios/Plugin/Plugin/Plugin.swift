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
        let alertSize = CGSize(width: 300 , height: 250 + defaultButtonHeight)
        viewController.preferredContentSize = CGSize(width: alertSize.width, height: alertSize.height)
    }

    @objc func cancel(sender: UIButton) {
        self.alert?.dismiss(animated: true, completion: nil)
        if(lastCall != nil){
            var obj:[String:Any] = [:]
            obj["value"] = nil
            lastCall?.resolve(obj)
            lastCall = nil
        }
    }

    @objc func datePickerChanged(picker: UIDatePicker) {
        if(title == nil){
            titleView?.text = titleDateFormatter?.string(from: picker.date)
        }
    }

    @objc func ok(sender: UIButton) {
        self.alert?.dismiss(animated: true, completion: nil)
        if(lastCall != nil){
            var obj:[String:Any] = [:]
            obj["value"] = dateFormatter?.string(from: (picker?.date)!)
            lastCall?.resolve(obj)
            lastCall = nil
        }
    }

    private let defaultButtonHeight: CGFloat = 50
    private let defaultTitleHeight:CGFloat = 50
    private let defaultSpacerHeight:CGFloat = 1
    private var defaultColor: UIColor?
    private var alert: PickerViewController?
    private var lastCall: CAPPluginCall?
    private var picker: UIDatePicker?
    private var title:String?
    var titleDateFormatter:DateFormatter?
    var dateFormatter: DateFormatter?
    var titleView: UILabel?

    public override func load() {
        titleDateFormatter = DateFormatter()
        dateFormatter = DateFormatter()
        defaultColor = UIColor(red:0.16, green:0.38, blue:1.00, alpha:1.0)
    }

    @objc func show(_ call: CAPPluginCall) {
        let mode = call.getString("mode") ?? "date"
        let date = call.getString("date")
        let min = call.getString("min")
        let max = call.getString("max")
        title = call.getString("title")
        let okText = call.getString("okText")
        let titleTextColor = call.getString("titleTextColor")
        let titleBgColor = call.getString("titleBgColor")
        let cancelText = call.getString("cancelText")
        let okButtonColor = call.getString("okButtonColor")
        let cancelButtonColor = call.getString("cancelButtonColor")
        let is24Hours = call.getBool("is24Hours") ?? false
        dateFormatter?.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if(mode == "date"){
            titleDateFormatter?.dateFormat = "E, MMM d, yyyy"
        }else{
            titleDateFormatter?.dateFormat = "HH:MM a"
        }

        let titleDate = titleDateFormatter?.string(from: (dateFormatter?.date(from: date!))!)

        DispatchQueue.main.async {
            self.picker = UIDatePicker(frame: CGRect(x: 0, y: self.defaultTitleHeight, width: 0, height: 0))



            self.picker?.addTarget(self, action: #selector(self.datePickerChanged(picker:)), for: .valueChanged)
            self.alert = PickerViewController()
            self.alert?.modalPresentationStyle = .popover
            self.alert?.popoverPresentationController?.delegate = self
            self.alert?.rotateDelegate = self;
            self.alert?.view.backgroundColor = UIColor.white
            let alertSize = CGSize(width: 300 , height: 250 + self.defaultButtonHeight)
            let alertView = UIView(frame: CGRect(x: 0, y: 0, width: alertSize.width, height: alertSize.height))

            self.titleView = UILabel(frame: CGRect(x: 0, y: 0, width: alertSize.width, height: self.defaultTitleHeight))
            self.titleView?.textAlignment = .center
            self.titleView?.text = self.title != nil ? self.title : titleDate
            self.titleView?.textColor = UIColor.white

            if(titleTextColor != nil){
                let titleColor = ColorName[titleTextColor!]
                self.titleView?.textColor = titleColor != nil ? UIColor(hexString: titleColor!) : UIColor.white
            }

            self.titleView?.backgroundColor = self.defaultColor
            
            if(titleBgColor != nil){
                let bgColor = ColorName[titleBgColor!]
                self.titleView?.backgroundColor = bgColor != nil ? UIColor(hexString: bgColor!) : self.defaultColor
            }

            let yPosition = alertView.bounds.size.height - self.defaultButtonHeight - self.defaultSpacerHeight
            let lineView = UIView(frame: CGRect(x: 0,
                                                y: yPosition,
                                                width: alertView.bounds.size.width,
                                                height: self.defaultSpacerHeight))

            lineView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)

            alertView.addSubview(lineView)
            alertView.addSubview(self.titleView!);
            alertView.addSubview(self.picker!)

            self.alert?.view.addSubview(alertView)


            let buttonWidth =  alertSize.width / 2
            let cancelButton = UIButton(frame: CGRect(x: 0, y: alertSize.height - self.defaultButtonHeight, width: buttonWidth, height: self.defaultButtonHeight))

            alertView.addSubview(cancelButton)

            cancelButton.setTitle(cancelText != nil ? cancelText! : "Cancel", for: .normal)
            cancelButton.setTitleColor(self.defaultColor, for: .normal)
            cancelButton.setTitleColor(self.defaultColor, for: .highlighted)
            let cancelTap = UITapGestureRecognizer(target: self, action: #selector(self.cancel))
            cancelButton.addGestureRecognizer(cancelTap)



            let okButton = UIButton(type: .custom)
            okButton.frame =  CGRect(x: buttonWidth, y: alertSize.height - self.defaultButtonHeight, width: buttonWidth, height: self.defaultButtonHeight)
            alertView.addSubview(okButton)
            okButton.setTitle(okText != nil ? okText! : "Ok", for: .normal)
            okButton.setTitleColor(self.defaultColor, for: .normal)
            okButton.setTitleColor(self.defaultColor, for: .highlighted)
            let okTap = UITapGestureRecognizer(target: self, action: #selector(self.ok))
            okButton.addGestureRecognizer(okTap)

            if(cancelButtonColor != nil){
                let cancelColor  = ColorName[cancelButtonColor!]
                cancelButton.setTitleColor(UIColor(hexString: cancelColor != nil ? cancelColor! : cancelButtonColor!), for: .normal)
                cancelButton.setTitleColor(UIColor(hexString: cancelColor != nil ? cancelColor! : cancelButtonColor!), for: .highlighted)
            }

            if(okButtonColor != nil){
                let okColor = ColorName[okButtonColor!]
                okButton.setTitleColor(UIColor(hexString: okColor != nil ? okColor! : okButtonColor!), for: .normal)
                okButton.setTitleColor(UIColor(hexString: okColor != nil ? okColor! : okButtonColor!), for: .highlighted)
            }


            self.picker?.setDate((self.dateFormatter?.date(from: date!)!)!, animated: false)

            if(max != nil){
                self.picker?.maximumDate = self.dateFormatter?.date(from: max!)!
            }
            if(min != nil){
                self.picker?.minimumDate = self.dateFormatter?.date(from: min!)!
            }

            if(mode == "time"){
                self.picker?.datePickerMode = UIDatePickerMode.time
                if(is24Hours){
                    self.picker?.locale = Locale(identifier: "en_GB")
                }
            }else{
                self.picker?.datePickerMode = UIDatePickerMode.date
            }


            self.alert?.popoverPresentationController?.sourceView = self.bridge.viewController.view
            self.alert?.preferredContentSize =  CGSize(width:alertSize.width, height: alertSize.height)

            self.alert?.bridge = self.bridge
            self.alert?.setCenteredPopover()
            self.lastCall = call
            self.bridge.viewController.present(self.alert!, animated: true,completion:nil)
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
            } else if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255

                    self.init(red: r, green: g, blue: b, alpha: 1.0)
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
