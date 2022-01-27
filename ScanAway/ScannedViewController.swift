
import UIKit


class ScannedViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let image = UIImageView()
    private let label = UITextView()
    
    var img = UIImage()
    var text = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Result"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Copy all text", style: .plain, target: self, action: #selector(copyText))
        
        config()
    }
    
    @objc func copyText() {
        UIPasteboard.general.string = text
    }
    
    func config() {
        view.addSubview(scrollView)
        scrollView.addSubview(image)
        scrollView.addSubview(label)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            image.topAnchor.constraint(equalTo: scrollView.topAnchor),
            image.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            image.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            image.heightAnchor.constraint(equalTo: image.widthAnchor),
            
            label.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 15),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
        ])
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // configure scrollview
        scrollView.backgroundColor = .systemBackground
        
        // configure image
        image.layer.cornerRadius = 15
        image.clipsToBounds = true
        image.image = img
        image.contentMode = .scaleAspectFit
        
        // configure label
        label.backgroundColor = .tertiarySystemFill
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.text = "\n\(text)\n"
        label.isScrollEnabled = false
        label.isEditable = false
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("View Did Appear: ")
        print(view.bounds.height)
        print( (view.bounds.width - 30) + label.requiredHeight + 100 )
        print(label.requiredHeight)
        
        if view.bounds.height < (view.bounds.width - 30) + label.requiredHeight + 100 {
            scrollView.contentSize = CGSize(width: view.bounds.width, height: (view.bounds.width - 30) + label.requiredHeight + 100)
        }
    }
  

}


extension UILabel{

public var requiredHeight: CGFloat {
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = font
    label.text = text
    label.attributedText = attributedText
    label.sizeToFit()
    return label.frame.height
  }
}

extension UITextView{

public var requiredHeight: CGFloat {
    let label = UITextView(frame: CGRect(x: 0, y: 0, width: frame.width, height: CGFloat.greatestFiniteMagnitude))
//    label.numberOfLines = 0
//    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.isScrollEnabled = false
    label.font = font
    label.text = text
    label.attributedText = attributedText
    label.sizeToFit()
    label.isEditable = false
    return label.frame.height
  }
}
