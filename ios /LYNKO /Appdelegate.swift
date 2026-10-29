import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let w = UIWindow(frame: UIScreen.main.bounds)
        w.rootViewController = HomeViewController()
        w.makeKeyAndVisible()
        window = w
        return true
    }
}

final class HomeViewController: UIViewController {
    private let field = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.16, green: 0.04, blue: 0.13, alpha: 1)

        let title = UILabel()
        title.text = "LYNKO ❤️"
        title.font = .systemFont(ofSize: 34, weight: .bold)
        title.textColor = UIColor(red: 1, green: 0.24, blue: 0.5, alpha: 1)

        let steps = UILabel()
        steps.numberOfLines = 0
        steps.textColor = UIColor(red: 1, green: 0.89, blue: 0.94, alpha: 1)
        steps.font = .systemFont(ofSize: 16)
        steps.text = """
        1. Settings → General → Keyboard → Keyboards → Add New Keyboard → LYNKO
        2. In any text box, hold the 🌐 key and choose LYNKO
        3. Tap EN / සිං on the keyboard to switch English and Sinhala (Singlish: mama → මම)
        """

        let button = UIButton(type: .system)
        button.setTitle("Open Settings", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 1, green: 0.24, blue: 0.5, alpha: 1)
        button.layer.cornerRadius = 14
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.addTarget(self, action: #selector(openSettings), for: .touchUpInside)

        field.backgroundColor = UIColor(white: 1, alpha: 0.08)
        field.textColor = .white
        field.font = .systemFont(ofSize: 20)
        field.layer.cornerRadius = 12
        field.heightAnchor.constraint(equalToConstant: 140).isActive = true

        let stack = UIStackView(arrangedSubviews: [title, steps, button, field])
        stack.axis = .vertical
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30)
        ])
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
    }

    @objc private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
