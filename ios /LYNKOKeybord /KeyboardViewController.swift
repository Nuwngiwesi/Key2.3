import UIKit

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
    }
}

/// One key. Fires on touch-down so typing feels instant.
final class Key: UIButton {
    var base = ""
    var onPress: (() -> Void)?
    var onRelease: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(down), for: .touchDown)
        addTarget(self, action: #selector(up), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func down() { onPress?() }
    @objc private func up() { onRelease?() }
}

/// LYNKO keyboard for iOS: Romantic theme, hearts on every key press, English + Sinhala (Singlish).
final class KeyboardViewController: UIInputViewController {
    private let keyColor = UIColor(hex: 0x5C1A45)
    private let textColor = UIColor(hex: 0xFFE4F0)
    private let accent = UIColor(hex: 0xFF3D7F)

    private var sinhala = true
    private var shifted = false
    private var numbers = false
    private var buf = ""
    private var letterKeys: [Key] = []
    private var delTimer: Timer?

    private let grad = CAGradientLayer()
    private let main = UIStackView()
    private let preview = UILabel()
    private let modeKey = Key(frame: .zero)
    private let shiftKey = Key(frame: .zero)

    // MARK: - setup

    override func viewDidLoad() {
        super.viewDidLoad()
        grad.colors = [UIColor(hex: 0x4A0F35).cgColor, UIColor(hex: 0x1E0618).cgColor]
        view.layer.insertSublayer(grad, at: 0)

        let h = view.heightAnchor.constraint(equalToConstant: 272)
        h.priority = UILayoutPriority(999)
        h.isActive = true

        main.axis = .vertical
        main.spacing = 6
        main.distribution = .fillEqually
        main.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(main)
        NSLayoutConstraint.activate([
            main.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            main.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            main.topAnchor.constraint(equalTo: view.topAnchor, constant: 6),
            main.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6)
        ])
        buildKeys()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        grad.frame = view.bounds
    }

    // MARK: - layout

    private func style(_ k: Key, _ title: String, accent isAccent: Bool = false, size: CGFloat = 20) {
        k.setTitle(title, for: .normal)
        k.setTitleColor(isAccent ? .white : textColor, for: .normal)
        k.titleLabel?.font = .systemFont(ofSize: size, weight: .medium)
        k.backgroundColor = isAccent ? accent : keyColor
        k.layer.cornerRadius = 9
    }

    private func rowStack() -> UIStackView {
        let r = UIStackView()
        r.axis = .horizontal
        r.spacing = 5
        r.distribution = .fill
        return r
    }

    private func fixed(_ v: UIView, in r: UIView, _ m: CGFloat) {
        let c = v.widthAnchor.constraint(equalTo: r.widthAnchor, multiplier: m)
        c.priority = UILayoutPriority(999)
        c.isActive = true
    }

    private func buildKeys() {
        main.arrangedSubviews.forEach { main.removeArrangedSubview($0); $0.removeFromSuperview() }
        letterKeys = []
        main.addArrangedSubview(makeTopBar())
        if numbers {
            main.addArrangedSubview(charRow(Array("1234567890")))
            main.addArrangedSubview(charRow(Array("-/:;()$&@\"")))
            main.addArrangedSubview(thirdRow(Array(".,?!'")))
        } else {
            main.addArrangedSubview(charRow(Array("qwertyuiop")))
            main.addArrangedSubview(charRow(Array("asdfghjkl"), pad: true))
            main.addArrangedSubview(thirdRow(Array("zxcvbnm"), withShift: true))
        }
        main.addArrangedSubview(bottomRow())
        updatePreview()
    }

    private func makeTopBar() -> UIView {
        let bar = UIView()
        preview.font = .systemFont(ofSize: 21, weight: .semibold)
        preview.textColor = textColor
        preview.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(preview)

        style(modeKey, sinhala ? "සිං" : "EN", accent: true, size: 17)
        modeKey.translatesAutoresizingMaskIntoConstraints = false
        modeKey.onPress = { [weak self] in
            guard let s = self else { return }
            s.commitComposed("")
            s.sinhala.toggle()
            s.style(s.modeKey, s.sinhala ? "සිං" : "EN", accent: true, size: 17)
            s.updatePreview()
        }
        bar.addSubview(modeKey)

        NSLayoutConstraint.activate([
            modeKey.trailingAnchor.constraint(equalTo: bar.trailingAnchor),
            modeKey.topAnchor.constraint(equalTo: bar.topAnchor),
            modeKey.bottomAnchor.constraint(equalTo: bar.bottomAnchor),
            modeKey.widthAnchor.constraint(equalToConstant: 64),
            preview.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 10),
            preview.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            preview.trailingAnchor.constraint(equalTo: modeKey.leadingAnchor, constant: -8)
        ])
        return bar
    }

    private func charKey(_ c: String) -> Key {
        let k = Key(frame: .zero)
        k.base = c
        style(k, shifted && !numbers ? c.uppercased() : c)
        k.onPress = { [weak self, weak k] in
            guard let s = self, let k = k else { return }
            if s.numbers { s.commitComposed(c) } else { s.typeLetter(c) }
            s.burst(from: k)
        }
        if !numbers { letterKeys.append(k) }
        return k
    }

    private func charRow(_ cs: [Character], pad: Bool = false) -> UIView {
        let r = rowStack()
        var first: Key?
        if pad {
            let sp = UIView()
            r.addArrangedSubview(sp)
            fixed(sp, in: r, 0.04)
        }
        for c in cs {
            let k = charKey(String(c))
            r.addArrangedSubview(k)
            if let f = first { k.widthAnchor.constraint(equalTo: f.widthAnchor).isActive = true } else { first = k }
        }
        if pad {
            let sp = UIView()
            r.addArrangedSubview(sp)
            fixed(sp, in: r, 0.04)
        }
        return r
    }

    private func thirdRow(_ cs: [Character], withShift: Bool = false) -> UIView {
        let r = rowStack()
        if withShift {
            style(shiftKey, "⇧", accent: shifted)
            shiftKey.onPress = { [weak self] in
                guard let s = self else { return }
                s.shifted.toggle()
                s.refreshCase()
            }
            r.addArrangedSubview(shiftKey)
            fixed(shiftKey, in: r, 0.14)
        }
        var first: Key?
        for c in cs {
            let k = charKey(String(c))
            r.addArrangedSubview(k)
            if let f = first { k.widthAnchor.constraint(equalTo: f.widthAnchor).isActive = true } else { first = k }
        }
        let del = Key(frame: .zero)
        style(del, "⌫", accent: true)
        del.onPress = { [weak self, weak del] in
            guard let s = self else { return }
            s.backspace()
            if let d = del { s.burst(from: d) }
            s.delTimer?.invalidate()
            s.delTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { [weak s] _ in
                s?.delTimer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true) { [weak s] _ in
                    s?.backspace()
                }
            }
        }
        del.onRelease = { [weak self] in
            self?.delTimer?.invalidate()
            self?.delTimer = nil
        }
        r.addArrangedSubview(del)
        fixed(del, in: r, 0.14)
        return r
    }

    private func bottomRow() -> UIView {
        let r = rowStack()

        let num = Key(frame: .zero)
        style(num, numbers ? "ABC" : "123", accent: true, size: 17)
        num.onPress = { [weak self] in
            guard let s = self else { return }
            s.commitComposed("")
            DispatchQueue.main.async {
                s.numbers.toggle()
                s.buildKeys()
            }
        }
        r.addArrangedSubview(num)
        fixed(num, in: r, 0.14)

        let globe = Key(frame: .zero)
        style(globe, "🌐", size: 19)
        globe.onPress = { [weak self] in self?.advanceToNextInputMode() }
        r.addArrangedSubview(globe)
        fixed(globe, in: r, 0.11)

        let comma = Key(frame: .zero)
        style(comma, ",")
        comma.onPress = { [weak self, weak comma] in
            self?.commitComposed(",")
            if let k = comma { self?.burst(from: k) }
        }
        r.addArrangedSubview(comma)
        fixed(comma, in: r, 0.09)

        let space = Key(frame: .zero)
        style(space, "LYNKO ❤️", size: 17)
        space.onPress = { [weak self, weak space] in
            self?.commitComposed(" ")
            if let k = space { self?.burst(from: k) }
        }
        r.addArrangedSubview(space)

        let dot = Key(frame: .zero)
        style(dot, ".")
        dot.onPress = { [weak self, weak dot] in
            self?.commitComposed(".")
            if let k = dot { self?.burst(from: k) }
        }
        r.addArrangedSubview(dot)
        fixed(dot, in: r, 0.09)

        let ret = Key(frame: .zero)
        style(ret, "⏎", accent: true)
        ret.onPress = { [weak self, weak ret] in
            self?.commitComposed("\n")
            if let k = ret { self?.burst(from: k) }
        }
        r.addArrangedSubview(ret)
        fixed(ret, in: r, 0.16)
        return r
    }

    // MARK: - typing

    private func typeLetter(_ base: String) {
        let ch = shifted ? base.uppercased() : base
        if sinhala {
            buf += ch
            updatePreview()
        } else {
            textDocumentProxy.insertText(ch)
        }
        if shifted {
            shifted = false
            refreshCase()
        }
    }

    /// Puts the Sinhala word that is being typed into the text box, then adds `suffix`.
    private func commitComposed(_ suffix: String) {
        if !buf.isEmpty {
            textDocumentProxy.insertText(SinhalaEngine.convert(buf))
            buf = ""
            updatePreview()
        }
        if !suffix.isEmpty { textDocumentProxy.insertText(suffix) }
    }

    private func backspace() {
        if !buf.isEmpty {
            buf.removeLast()
            updatePreview()
        } else {
            textDocumentProxy.deleteBackward()
        }
    }

    private func updatePreview() {
        preview.text = buf.isEmpty ? "LYNKO ❤️" : SinhalaEngine.convert(buf)
        preview.alpha = buf.isEmpty ? 0.6 : 1
    }

    private func refreshCase() {
        for k in letterKeys { k.setTitle(shifted ? k.base.uppercased() : k.base, for: .normal) }
        shiftKey.backgroundColor = shifted ? accent : keyColor
    }

    // MARK: - hearts

    private func burst(from v: UIView) {
        let c = v.convert(CGPoint(x: v.bounds.midX, y: v.bounds.height * 0.3), to: view)
        let hearts = ["❤️", "💖", "💕", "💗", "💘"]
        for _ in 0..<3 {
            let l = UILabel()
            l.text = hearts.randomElement()
            l.font = .systemFont(ofSize: CGFloat.random(in: 12...20))
            l.sizeToFit()
            l.center = CGPoint(x: c.x + CGFloat.random(in: -12...12), y: c.y)
            l.isUserInteractionEnabled = false
            view.addSubview(l)
            let dx = CGFloat.random(in: -25...25)
            let dy = CGFloat.random(in: 70...130)
            UIView.animate(withDuration: Double.random(in: 0.8...1.2), delay: 0, options: [.curveEaseOut], animations: {
                l.center = CGPoint(x: l.center.x + dx, y: l.center.y - dy)
                l.alpha = 0
                l.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }, completion: { _ in l.removeFromSuperview() })
        }
    }
}
