import Foundation

/// Singlish (Latin letters) -> Sinhala script. Same rules as the Android keyboard.
enum SinhalaEngine {
    /// true: th = ත, dh = ද (how most people type); false: th = ථ, dh = ධ
    static var hk = true

    static let cons: [[String]] = [
        ["TH", "ඨ"], ["DH", "ඪ"], ["kh", "ඛ"], ["gh", "ඝ"], ["ch", "ච"], ["Ch", "ඡ"], ["jh", "ඣ"], ["nj", "ඤ"],
        ["th", "ථ"], ["Th", "ඨ"], ["dh", "ධ"], ["Dh", "ඪ"], ["ph", "ඵ"], ["bh", "භ"], ["sh", "ශ"], ["Sh", "ෂ"],
        ["ng", "ඟ"], ["nG", "ඟ"], ["nD", "ඬ"], ["nJ", "ඦ"], ["nB", "ඹ"], ["Ng", "ඞ"], ["gn", "ඥ"],
        ["k", "ක"], ["g", "ග"], ["c", "ච"], ["j", "ජ"], ["t", "ත"], ["T", "ට"], ["d", "ද"], ["D", "ඩ"], ["N", "ණ"],
        ["n", "න"], ["p", "ප"], ["b", "බ"], ["m", "ම"], ["y", "ය"], ["r", "ර"], ["l", "ල"], ["L", "ළ"], ["w", "ව"],
        ["v", "ව"], ["s", "ස"], ["S", "ෂ"], ["h", "හ"], ["f", "ෆ"], ["G", "ඝ"], ["K", "ඛ"], ["C", "ඡ"], ["J", "ඣ"],
        ["P", "ඵ"], ["B", "භ"], ["q", "ඳ"], ["z", "ඤ"]
    ]

    static let vow: [[String]] = [
        ["aae", "ඈ", "ෑ"], ["aa", "ආ", "ා"], ["ae", "ඇ", "ැ"], ["ai", "ඓ", "ෛ"], ["au", "ඖ", "ෞ"], ["ii", "ඊ", "ී"],
        ["ee", "ඒ", "ේ"], ["oo", "ඕ", "ෝ"], ["uu", "ඌ", "ූ"],
        ["a", "අ", ""], ["A", "ඇ", "ැ"], ["i", "ඉ", "ි"], ["I", "ඊ", "ී"], ["u", "උ", "ු"], ["U", "ඌ", "ූ"],
        ["e", "එ", "ෙ"], ["E", "ඒ", "ේ"], ["o", "ඔ", "ො"], ["O", "ඕ", "ෝ"]
    ]

    static let sign: [[String]] = [["x", "ං"], ["X", "ං"], ["H", "ඃ"]]

    private static func match(_ tab: [[String]], _ cs: [Character], _ i: Int) -> [String]? {
        for e in tab {
            let k = Array(e[0])
            if i + k.count <= cs.count && Array(cs[i..<(i + k.count)]) == k { return e }
        }
        return nil
    }

    private static func lowered(_ cs: [Character], _ i: Int) -> [Character] {
        var low = cs
        low[i] = Character(String(cs[i]).lowercased())
        return low
    }

    static func convert(_ s: String) -> String {
        let cs = Array(s)
        var o = ""
        var pend = false   // a consonant is waiting for its vowel
        var i = 0
        while i < cs.count {
            let ch = cs[i]
            let up = ch.isUppercase

            var e = match(cons, cs, i)
            if e == nil && up && ch != "H" { e = match(cons, lowered(cs, i), i) }
            if let e = e {
                if pend {
                    o += "\u{0DCA}"
                    if e[0] == "r" || e[0] == "y" { o += "\u{200D}" }
                }
                var out = e[1]
                if hk {
                    switch e[0] {
                    case "th": out = "ත"
                    case "Th": out = "ථ"
                    case "dh": out = "ද"
                    case "Dh": out = "ධ"
                    default: break
                    }
                }
                o += out
                pend = true
                i += e[0].count
                continue
            }

            var v = match(vow, cs, i)
            if v == nil && up { v = match(vow, lowered(cs, i), i) }
            if let v = v {
                o += pend ? v[2] : v[1]
                pend = false
                i += v[0].count
                continue
            }

            if let g = match(sign, cs, i) {
                pend = false
                o += g[1]
                i += g[0].count
                continue
            }

            if pend { o += "\u{0DCA}"; pend = false }
            o.append(ch)
            i += 1
        }
        if pend { o += "\u{0DCA}" }
        return o
    }
}
