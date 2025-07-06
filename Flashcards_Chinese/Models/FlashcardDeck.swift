//
//  FlashcardDeck.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-05-22.
//

import SwiftUI
import Combine

class FlashcardDeck: ObservableObject {
    @Published var cards: [Flashcard] = []
    @Published var categories: [String] = ["All"]
    @Published var quizScore = QuizScore(correct: 0, total: 0)
    @Published var showAdminPanel = false

    private var documentsUrl: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    private var cardsFileUrl: URL {
        documentsUrl.appendingPathComponent("flashcards.json")
    }

    init() {
        loadCards()
    }

    // MARK: - Computed Properties
    var favoriteCards: [Flashcard] {
        cards.filter { $0.isFavorite }
    }

    // MARK: - Card Management
    func addCard(chinese: String, pinyin: String, english: String, french: String, pronunciation: String, category: String, difficulty: Int, exampleSentence: String, examplePinyin: String, exampleTranslation: String) {
        let newCard = Flashcard(
            chinese: chinese,
            pinyin: pinyin,
            english: english,
            french: french,
            pronunciation: pronunciation,
            category: category,
            difficulty: difficulty,
            exampleSentence: exampleSentence,
            examplePinyin: examplePinyin,
            exampleTranslation: exampleTranslation
        )
        cards.append(newCard)
        updateCategories()
        saveCards()
    }

    func toggleFavorite(card: Flashcard) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].isFavorite.toggle()
            saveCards()
        }
    }

    // MARK: - Quiz Management
    func resetQuiz() {
        quizScore = QuizScore(correct: 0, total: 0)
    }
    
    func incrementCorrectAnswers() {
        quizScore.correct += 1
    }
    
    func incrementTotalQuestions() {
        quizScore.total += 1
    }

    // MARK: - Data Persistence
    func saveCards() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(cards)
            try data.write(to: cardsFileUrl, options: .atomic)
        } catch {
            print("Error saving cards: \(error.localizedDescription)")
        }
    }

    private func loadCards() {
        if FileManager.default.fileExists(atPath: cardsFileUrl.path) {
            do {
                let data = try Data(contentsOf: cardsFileUrl)
                let decoder = JSONDecoder()
                cards = try decoder.decode([Flashcard].self, from: data)
            } catch {
                print("Error loading cards: \(error.localizedDescription)")
                // If loading fails, fall back to default cards
                cards = FlashcardDeck.defaultCards()
            }
        } else {
            // If no file exists, load default cards
            cards = FlashcardDeck.defaultCards()
            saveCards() // Save the default set for the first time
        }
        updateCategories()
    }

    private func updateCategories() {
        let allCategories = Set(cards.map { $0.category })
        var uniqueCategories = Array(allCategories).sorted()
        
        // Always ensure "All" is at the start
        if let allIndex = uniqueCategories.firstIndex(of: "All") {
            uniqueCategories.remove(at: allIndex)
        }
        uniqueCategories.insert("All", at: 0)
        
        self.categories = uniqueCategories
    }
    
    // MARK: - Default Data
    // --- THIS IS THE UPDATED FUNCTION ---
    static func defaultCards() -> [Flashcard] {
        return [
            // Q/S/C/SH/ZH Words (unchanged)
            Flashcard(chinese: "去", pinyin: "qù", english: "To go", french: "Aller", pronunciation: "choo", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "我去学校。", examplePinyin: "Wǒ qù xuéxiào.", exampleTranslation: "I go to school."),
            Flashcard(chinese: "请", pinyin: "qǐng", english: "Please", french: "S'il vous plaît", pronunciation: "ching", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "请坐。", examplePinyin: "Qǐng zuò.", exampleTranslation: "Please sit down."),
            Flashcard(chinese: "三", pinyin: "sān", english: "Three", french: "Trois", pronunciation: "sahn", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "我有三个苹果。", examplePinyin: "Wǒ yǒu sān gè píngguǒ.", exampleTranslation: "I have three apples."),
            Flashcard(chinese: "四", pinyin: "sì", english: "Four", french: "Quatre", pronunciation: "suh", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "四月很暖和。", examplePinyin: "Sìyuè hěn nuǎnhuo.", exampleTranslation: "April is very warm."),
            Flashcard(chinese: "菜", pinyin: "cài", english: "Vegetable", french: "Légume", pronunciation: "tsai", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "我喜欢吃蔬菜。", examplePinyin: "Wǒ xǐhuān chī shūcài.", exampleTranslation: "I like to eat vegetables."),
            Flashcard(chinese: "从", pinyin: "cóng", english: "From", french: "De", pronunciation: "tsong", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "我从中国来。", examplePinyin: "Wǒ cóng Zhōngguó lái.", exampleTranslation: "I come from China."),
            Flashcard(chinese: "是", pinyin: "shì", english: "To be", french: "Être", pronunciation: "shuh", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "我是学生。", examplePinyin: "Wǒ shì xuéshēng.", exampleTranslation: "I am a student."),
            Flashcard(chinese: "上", pinyin: "shàng", english: "Up/On", french: "En haut/Sur", pronunciation: "shahng", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "书在桌子上。", examplePinyin: "Shū zài zhuōzi shàng.", exampleTranslation: "The book is on the table."),
            Flashcard(chinese: "这", pinyin: "zhè", english: "This", french: "Ceci", pronunciation: "juh", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "这是什么？", examplePinyin: "Zhè shì shénme?", exampleTranslation: "What is this?"),
            Flashcard(chinese: "中", pinyin: "zhōng", english: "Middle", french: "Milieu", pronunciation: "jong", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "中午见！", examplePinyin: "Zhōngwǔ jiàn!", exampleTranslation: "See you at noon!"),
            Flashcard(chinese: "吃", pinyin: "chī", english: "To eat", french: "Manger", pronunciation: "chuh", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "我想吃面条。", examplePinyin: "Wǒ xiǎng chī miàntiáo.", exampleTranslation: "I want to eat noodles."),
            Flashcard(chinese: "车", pinyin: "chē", english: "Car", french: "Voiture", pronunciation: "chuh", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "这是我的车。", examplePinyin: "Zhè shì wǒ de chē.", exampleTranslation: "This is my car."),
            Flashcard(chinese: "家", pinyin: "jiā", english: "Home/Family", french: "Maison/Famille", pronunciation: "jyah", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "我想回家。", examplePinyin: "Wǒ xiǎng huí jiā.", exampleTranslation: "I want to go home."),
            Flashcard(chinese: "今天", pinyin: "jīntiān", english: "Today", french: "Aujourd'hui", pronunciation: "jin tyen", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "今天天气很好。", examplePinyin: "Jīntiān tiānqì hěn hǎo.", exampleTranslation: "The weather is nice today."),
            Flashcard(chinese: "在", pinyin: "zài", english: "At/In", french: "À/Dans", pronunciation: "dzai", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "我在学校。", examplePinyin: "Wǒ zài xuéxiào.", exampleTranslation: "I'm at school."),
            Flashcard(chinese: "走", pinyin: "zǒu", english: "To walk", french: "Marcher", pronunciation: "dzoh", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "我们走吧！", examplePinyin: "Wǒmen zǒu ba!", exampleTranslation: "Let's go!"),
            Flashcard(chinese: "七", pinyin: "qī", english: "Seven", french: "Sept", pronunciation: "chee", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "一个星期有七天。", examplePinyin: "Yī gè xīngqī yǒu qī tiān.", exampleTranslation: "There are seven days in a week."),
            Flashcard(chinese: "起", pinyin: "qǐ", english: "To rise/get up", french: "Se lever/commencer", pronunciation: "chee", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "我早上七点起床。", examplePinyin: "Wǒ zǎoshang qī diǎn qǐchuáng.", exampleTranslation: "I get up at 7 o'clock in the morning."),
            Flashcard(chinese: "钱", pinyin: "qián", english: "Money", french: "Argent", pronunciation: "chyen", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "这个多少钱？", examplePinyin: "Zhège duōshao qián?", exampleTranslation: "How much is this?"),
            Flashcard(chinese: "前", pinyin: "qián", english: "Front/Before", french: "Avant/Devant", pronunciation: "chyen", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "请在前面下车。", examplePinyin: "Qǐng zài qiánmiàn xiàchē.", exampleTranslation: "Please get off at the front."),
            Flashcard(chinese: "字", pinyin: "zì", english: "Character/Word", french: "Caractère/Mot", pronunciation: "dzuh", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "这个字怎么写？", examplePinyin: "Zhège zì zěnme xiě?", exampleTranslation: "How do you write this character?"),
            Flashcard(chinese: "早", pinyin: "zǎo", english: "Early/Morning", french: "Tôt/Matin", pronunciation: "dzao", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "早上好！", examplePinyin: "Zǎoshang hǎo!", exampleTranslation: "Good morning!"),
            Flashcard(chinese: "再", pinyin: "zài", english: "Again/Once more", french: "Encore/De nouveau", pronunciation: "dzai", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "请再说一遍。", examplePinyin: "Qǐng zài shuō yī biàn.", exampleTranslation: "Please say it again."),
            Flashcard(chinese: "自己", pinyin: "zìjǐ", english: "Oneself/Myself/Yourself", french: "Soi-même", pronunciation: "dzuh-jee", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "你必须相信你自己。", examplePinyin: "Nǐ bìxū xiāngxìn nǐ zìjǐ.", exampleTranslation: "You must believe in yourself."),
            Flashcard(chinese: "次", pinyin: "cì", english: "Time (measure word for occurrences)", french: "Fois (classificateur)", pronunciation: "tsuh", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "我去过中国三次。", examplePinyin: "Wǒ qùguo Zhōngguó sān cì.", exampleTranslation: "I have been to China three times."),
            Flashcard(chinese: "错", pinyin: "cuò", english: "Wrong/Mistake", french: "Faux/Erreur", pronunciation: "tswaw", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "对不起，我错了。", examplePinyin: "Duìbuqǐ, wǒ cuò le.", exampleTranslation: "Sorry, I was wrong."),
            Flashcard(chinese: "长", pinyin: "cháng", english: "Long (length)", french: "Long (longueur)", pronunciation: "chahng", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "这条路很长。", examplePinyin: "Zhè tiáo lù hěn cháng.", exampleTranslation: "This road is very long."),
            Flashcard(chinese: "十", pinyin: "shí", english: "Ten", french: "Dix", pronunciation: "shih", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "我有十个手指。", examplePinyin: "Wǒ yǒu shí gè shǒuzhǐ.", exampleTranslation: "I have ten fingers."),
            Flashcard(chinese: "时", pinyin: "shí", english: "Time/When/Hour", french: "Temps/Quand/Heure", pronunciation: "shih", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "什么时候开始？", examplePinyin: "Shénme shíhou kāishǐ?", exampleTranslation: "When does it start?"),
            Flashcard(chinese: "手", pinyin: "shǒu", english: "Hand", french: "Main", pronunciation: "show", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "请举手。", examplePinyin: "Qǐng jǔ shǒu.", exampleTranslation: "Please raise your hand."),
            Flashcard(chinese: "书", pinyin: "shū", english: "Book", french: "Livre", pronunciation: "shoo", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "我喜欢看书。", examplePinyin: "Wǒ xǐhuān kàn shū.", exampleTranslation: "I like to read books."),
            Flashcard(chinese: "出", pinyin: "chū", english: "To go out/To come out", french: "Sortir", pronunciation: "choo", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "他出去了。", examplePinyin: "Tā chūqù le.", exampleTranslation: "He went out."),
            Flashcard(chinese: "穿", pinyin: "chuān", english: "To wear (clothes)", french: "Porter (vêtements)", pronunciation: "chwan", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "今天你穿什么？", examplePinyin: "Jīntiān nǐ chuān shénme?", exampleTranslation: "What are you wearing today?"),
            Flashcard(chinese: "床", pinyin: "chuáng", english: "Bed", french: "Lit", pronunciation: "chwahng", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "我的床很舒服。", examplePinyin: "Wǒ de chuáng hěn shūfu.", exampleTranslation: "My bed is very comfortable."),
            Flashcard(chinese: "唱歌", pinyin: "chànggē", english: "To sing (a song)", french: "Chanter (une chanson)", pronunciation: "chahng-guh", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "她喜欢唱歌。", examplePinyin: "Tā xǐhuān chànggē.", exampleTranslation: "She likes to sing."),
            Flashcard(chinese: "找", pinyin: "zhǎo", english: "To look for/To find", french: "Chercher/Trouver", pronunciation: "jao", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "我在找我的钥匙。", examplePinyin: "Wǒ zài zhǎo wǒ de yàoshi.", exampleTranslation: "I am looking for my keys."),
            Flashcard(chinese: "知道", pinyin: "zhīdào", english: "To know", french: "Savoir/Connaître", pronunciation: "jyh-dao", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "我知道这个问题的答案。", examplePinyin: "Wǒ zhīdào zhège wèntí de dá'àn.", exampleTranslation: "I know the answer to this question."),
            Flashcard(chinese: "张", pinyin: "zhāng", english: "Measure word (for flat objects like paper, table)", french: "Classificateur (pour objets plats)", pronunciation: "jahng", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "请给我一张纸。", examplePinyin: "Qǐng gěi wǒ yī zhāng zhǐ.", exampleTranslation: "Please give me a piece of paper."),
            Flashcard(chinese: "站", pinyin: "zhàn", english: "Station/To stand", french: "Gare/Station/Se tenir debout", pronunciation: "jan", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "火车站离这里远吗？", examplePinyin: "Huǒchēzhàn lí zhèlǐ yuǎn ma?", exampleTranslation: "Is the train station far from here?"),
            Flashcard(chinese: "上课", pinyin: "shàngkè", english: "To attend class/To start class", french: "Aller en cours/Commencer le cours", pronunciation: "shahng-kuh", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "我们九点上课。", examplePinyin: "Wǒmen jiǔ diǎn shàngkè.", exampleTranslation: "We start class at nine."),
            Flashcard(chinese: "身体", pinyin: "shēntǐ", english: "Body/Health", french: "Corps/Santé", pronunciation: "shen-tee", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "注意身体健康。", examplePinyin: "Zhùyì shēntǐ jiànkāng.", exampleTranslation: "Pay attention to your health."),
            Flashcard(chinese: "送", pinyin: "sòng", english: "To give (as a gift)/To send/To see off", french: "Offrir (cadeau)/Envoyer/Accompagner (départ)", pronunciation: "song", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "我送你一个礼物。", examplePinyin: "Wǒ sòng nǐ yī gè lǐwù.", exampleTranslation: "I'll give you a gift."),
            Flashcard(chinese: "岁", pinyin: "suì", english: "Year (of age)", french: "An (âge)", pronunciation: "sway", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "你几岁了？", examplePinyin: "Nǐ jǐ suì le?", exampleTranslation: "How old are you?"),
            Flashcard(chinese: "西", pinyin: "xī", english: "West", french: "Ouest", pronunciation: "shee", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "太阳从西边落下。", examplePinyin: "Tàiyáng cóng xībian luòxià.", exampleTranslation: "The sun sets in the west."),
            Flashcard(chinese: "想", pinyin: "xiǎng", english: "To want/To think/To miss", french: "Vouloir/Penser/Manquer (à qqn)", pronunciation: "shyahng", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "我想喝水。", examplePinyin: "Wǒ xiǎng hē shuǐ.", exampleTranslation: "I want to drink water."),
            Flashcard(chinese: "小", pinyin: "xiǎo", english: "Small/Little", french: "Petit", pronunciation: "shyao", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "这是一只小猫。", examplePinyin: "Zhè shì yī zhī xiǎo māo.", exampleTranslation: "This is a small cat."),
            Flashcard(chinese: "写", pinyin: "xiě", english: "To write", french: "Écrire", pronunciation: "shyeh", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "请写下你的名字。", examplePinyin: "Qǐng xiěxià nǐ de míngzi.", exampleTranslation: "Please write down your name."),
            Flashcard(chinese: "九", pinyin: "jiǔ", english: "Nine", french: "Neuf", pronunciation: "jyo", category: "Q/S/C/SH/ZH Words", difficulty: 1, exampleSentence: "他九岁了。", examplePinyin: "Tā jiǔ suì le.", exampleTranslation: "He is nine years old."),
            Flashcard(chinese: "进", pinyin: "jìn", english: "To enter", french: "Entrer", pronunciation: "jin", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "请进！", examplePinyin: "Qǐng jìn!", exampleTranslation: "Please come in!"),
            Flashcard(chinese: "近", pinyin: "jìn", english: "Near/Close", french: "Près/Proche", pronunciation: "jin", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "我家离学校很近。", examplePinyin: "Wǒ jiā lí xuéxiào hěn jìn.", exampleTranslation: "My home is very close to the school."),
            Flashcard(chinese: "觉得", pinyin: "juéde", english: "To feel/To think", french: "Sentir/Penser (avoir l'impression)", pronunciation: "jweh-duh", category: "Q/S/C/SH/ZH Words", difficulty: 2, exampleSentence: "我觉得有点冷。", examplePinyin: "Wǒ juéde yǒudiǎn lěng.", exampleTranslation: "I feel a bit cold."),

            // Basic Words (updated)
            Flashcard(chinese: "你好", pinyin: "nǐ hǎo", english: "Hello", french: "Bonjour", pronunciation: "nee how", category: "Basic Words", difficulty: 1, exampleSentence: "你好！", examplePinyin: "Nǐ hǎo!", exampleTranslation: "Hello!"),
            Flashcard(chinese: "谢谢", pinyin: "xièxiè", english: "Thank you", french: "Merci", pronunciation: "shyeh shyeh", category: "Basic Words", difficulty: 1, exampleSentence: "谢谢你的帮助。", examplePinyin: "Xièxie nǐ de bāngzhù.", exampleTranslation: "Thank you for your help."), // Changed to xièxiè
            Flashcard(chinese: "再见", pinyin: "zàijiàn", english: "Goodbye", french: "Au revoir", pronunciation: "zai jee-en", category: "Basic Words", difficulty: 1, exampleSentence: "明天见，再见！", examplePinyin: "Míngtiān jiàn, zàijiàn!", exampleTranslation: "See you tomorrow, goodbye!"),
            Flashcard(chinese: "对不起", pinyin: "duìbuqǐ", english: "Sorry", french: "Désolé", pronunciation: "dway boo chee", category: "Basic Words", difficulty: 1, exampleSentence: "对不起，我迟到了。", examplePinyin: "Duìbuqǐ, wǒ chídào le.", exampleTranslation: "Sorry, I'm late."),
            Flashcard(chinese: "是", pinyin: "shì", english: "Yes", french: "Oui", pronunciation: "shir", category: "Basic Words", difficulty: 1, exampleSentence: "是的，我是学生。", examplePinyin: "Shì de, wǒ shì xuéshēng.", exampleTranslation: "Yes, I am a student."),
            Flashcard(chinese: "不", pinyin: "bù", english: "No", french: "Non", pronunciation: "boo", category: "Basic Words", difficulty: 1, exampleSentence: "不，我不喜欢。", examplePinyin: "Bù, wǒ bù xǐhuān.", exampleTranslation: "No, I don't like it."),
            Flashcard(chinese: "我", pinyin: "wǒ", english: "I/Me", french: "Je/Moi", pronunciation: "woh", category: "Basic Words", difficulty: 1, exampleSentence: "我是法国人。", examplePinyin: "Wǒ shì Fǎguó rén.", exampleTranslation: "I am French."),
            Flashcard(chinese: "你", pinyin: "nǐ", english: "You", french: "Tu/Vous", pronunciation: "nee", category: "Basic Words", difficulty: 1, exampleSentence: "你好吗？", examplePinyin: "Nǐ hǎo ma?", exampleTranslation: "How are you?"),
            Flashcard(chinese: "好", pinyin: "hǎo", english: "Good", french: "Bon", pronunciation: "how", category: "Basic Words", difficulty: 1, exampleSentence: "我很好。", examplePinyin: "Wǒ hěn hǎo.", exampleTranslation: "I'm very good."),
            Flashcard(chinese: "爱", pinyin: "ài", english: "Love", french: "Amour", pronunciation: "eye", category: "Basic Words", difficulty: 1, exampleSentence: "我爱中国。", examplePinyin: "Wǒ ài Zhōngguó.", exampleTranslation: "I love China."),
            Flashcard(chinese: "朋友", pinyin: "péngyou", english: "Friend", french: "Ami", pronunciation: "pung yo", category: "Basic Words", difficulty: 1, exampleSentence: "他是我的朋友。", examplePinyin: "Tā shì wǒ de péngyou.", exampleTranslation: "He is my friend."),
            Flashcard(chinese: "学校", pinyin: "xuéxiào", english: "School", french: "École", pronunciation: "shweh shee-ow", category: "Basic Words", difficulty: 1, exampleSentence: "我的学校很大。", examplePinyin: "Wǒ de xuéxiào hěn dà.", exampleTranslation: "My school is very big."),
            Flashcard(chinese: "工作", pinyin: "gōngzuò", english: "Work", french: "Travail", pronunciation: "gong dzwo", category: "Basic Words", difficulty: 1, exampleSentence: "我在医院工作。", examplePinyin: "Wǒ zài yīyuàn gōngzuò.", exampleTranslation: "I work at a hospital."),

            // HSK 1 (unchanged)
            Flashcard(chinese: "人", pinyin: "rén", english: "Person", french: "Personne", pronunciation: "ren", category: "HSK 1", difficulty: 1, exampleSentence: "这个人很友好。", examplePinyin: "Zhège rén hěn yǒuhǎo.", exampleTranslation: "This person is very friendly."),
            Flashcard(chinese: "名字", pinyin: "míngzi", english: "Name", french: "Nom", pronunciation: "ming dz", category: "HSK 1", difficulty: 1, exampleSentence: "你叫什么名字？", examplePinyin: "Nǐ jiào shénme míngzi?", exampleTranslation: "What's your name?"),
            Flashcard(chinese: "明天", pinyin: "míngtiān", english: "Tomorrow", french: "Demain", pronunciation: "ming tee-en", category: "HSK 1", difficulty: 1, exampleSentence: "明天见！", examplePinyin: "Míngtiān jiàn!", exampleTranslation: "See you tomorrow!"),
            Flashcard(chinese: "昨天", pinyin: "zuótiān", english: "Yesterday", french: "Hier", pronunciation: "dzwo tee-en", category: "HSK 1", difficulty: 1, exampleSentence: "昨天我去了公园。", examplePinyin: "Zuótiān wǒ qùle gōngyuán.", exampleTranslation: "I went to the park yesterday."),
            Flashcard(chinese: "年", pinyin: "nián", english: "Year", french: "Année", pronunciation: "nee-en", category: "HSK 1", difficulty: 1, exampleSentence: "今年是2023年。", examplePinyin: "Jīnnián shì èr líng èr sān nián.", exampleTranslation: "This year is 2023."),
            Flashcard(chinese: "月", pinyin: "yuè", english: "Month/Moon", french: "Mois/Lune", pronunciation: "yweh", category: "HSK 1", difficulty: 1, exampleSentence: "一月很冷。", examplePinyin: "Yī yuè hěn lěng.", exampleTranslation: "January is very cold."),
            Flashcard(chinese: "日", pinyin: "rì", english: "Day/Sun", french: "Jour/Soleil", pronunciation: "rr", category: "HSK 1", difficulty: 1, exampleSentence: "星期日我们休息。", examplePinyin: "Xīngqīrì wǒmen xiūxi.", exampleTranslation: "We rest on Sunday."),
            Flashcard(chinese: "时间", pinyin: "shíjiān", english: "Time", french: "Temps", pronunciation: "shir jee-en", category: "HSK 1", difficulty: 1, exampleSentence: "现在是什么时间？", examplePinyin: "Xiànzài shì shénme shíjiān?", exampleTranslation: "What time is it now?"),
            Flashcard(chinese: "现在", pinyin: "xiànzài", english: "Now", french: "Maintenant", pronunciation: "she-en dzai", category: "HSK 1", difficulty: 1, exampleSentence: "现在几点？", examplePinyin: "Xiànzài jǐ diǎn?", exampleTranslation: "What time is it now?"),
            Flashcard(chinese: "早上", pinyin: "zǎoshang", english: "Morning", french: "Matin", pronunciation: "dzow shung", category: "HSK 1", difficulty: 1, exampleSentence: "早上我喝咖啡。", examplePinyin: "Zǎoshang wǒ hē kāfēi.", exampleTranslation: "I drink coffee in the morning."),
            Flashcard(chinese: "晚上", pinyin: "wǎnshang", english: "Evening", french: "Soir", pronunciation: "wan shung", category: "HSK 1", difficulty: 1, exampleSentence: "晚上我学习中文。", examplePinyin: "Wǎnshang wǒ xuéxí Zhōngwén.", exampleTranslation: "I study Chinese in the evening."),
            Flashcard(chinese: "中午", pinyin: "zhōngwǔ", english: "Noon", french: "Midi", pronunciation: "jong woo", category: "HSK 1", difficulty: 1, exampleSentence: "中午我们吃午饭。", examplePinyin: "Zhōngwǔ wǒmen chī wǔfàn.", exampleTranslation: "We eat lunch at noon."),
            Flashcard(chinese: "分钟", pinyin: "fēnzhōng", english: "Minute", french: "Minute", pronunciation: "fen jong", category: "HSK 1", difficulty: 1, exampleSentence: "请等五分钟。", examplePinyin: "Qǐng děng wǔ fēnzhōng.", exampleTranslation: "Please wait five minutes."),

            // HSK 2 (unchanged)
            Flashcard(chinese: "电脑", pinyin: "diànnǎo", english: "Computer", french: "Ordinateur", pronunciation: "dee-en now", category: "HSK 2", difficulty: 2, exampleSentence: "我用电脑工作。", examplePinyin: "Wǒ yòng diànnǎo gōngzuò.", exampleTranslation: "I use a computer for work."),
            Flashcard(chinese: "手机", pinyin: "shǒujī", english: "Mobile phone", french: "Téléphone portable", pronunciation: "show jee", category: "HSK 2", difficulty: 2, exampleSentence: "我的手机很新。", examplePinyin: "Wǒ de shǒujī hěn xīn.", exampleTranslation: "My phone is very new."),
            Flashcard(chinese: "电视", pinyin: "diànshì", english: "Television", french: "Télévision", pronunciation: "dee-en shir", category: "HSK 2", difficulty: 2, exampleSentence: "晚上我看电视。", examplePinyin: "Wǎnshang wǒ kàn diànshì.", exampleTranslation: "I watch TV in the evening."),
            Flashcard(chinese: "电影", pinyin: "diànyǐng", english: "Movie", french: "Film", pronunciation: "dee-en eeng", category: "HSK 2", difficulty: 2, exampleSentence: "我喜欢看中国电影。", examplePinyin: "Wǒ xǐhuān kàn Zhōngguó diànyǐng.", exampleTranslation: "I like watching Chinese movies."),
            Flashcard(chinese: "音乐", pinyin: "yīnyuè", english: "Music", french: "Musique", pronunciation: "een yweh", category: "HSK 2", difficulty: 2, exampleSentence: "我喜欢听音乐。", examplePinyin: "Wǒ xǐhuān tīng yīnyuè.", exampleTranslation: "I like listening to music."),
            Flashcard(chinese: "运动", pinyin: "yùndòng", english: "Sports/Exercise", french: "Sport/Exercice", pronunciation: "yoon dong", category: "HSK 2", difficulty: 2, exampleSentence: "运动对身体好。", examplePinyin: "Yùndòng duì shēntǐ hǎo.", exampleTranslation: "Exercise is good for health."),
            Flashcard(chinese: "跑步", pinyin: "pǎobù", english: "Running", french: "Courir", pronunciation: "pow boo", category: "HSK 2", difficulty: 2, exampleSentence: "我每天早上跑步。", examplePinyin: "Wǒ měitiān zǎoshang pǎobù.", exampleTranslation: "I run every morning."),
            Flashcard(chinese: "游泳", pinyin: "yóuyǒng", english: "Swimming", french: "Natation", pronunciation: "yo yong", category: "HSK 2", difficulty: 2, exampleSentence: "夏天我喜欢游泳。", examplePinyin: "Xiàtiān wǒ xǐhuān yóuyǒng.", exampleTranslation: "I like swimming in summer."),
            Flashcard(chinese: "旅行", pinyin: "lǚxíng", english: "Travel", french: "Voyage", pronunciation: "lyoo shing", category: "HSK 2", difficulty: 2, exampleSentence: "明年我想去中国旅行。", examplePinyin: "Míngnián wǒ xiǎng qù Zhōngguó lǚxíng.", exampleTranslation: "Next year I want to travel to China."),
            Flashcard(chinese: "飞机", pinyin: "fēijī", english: "Airplane", french: "Avion", pronunciation: "fay jee", category: "HSK 2", difficulty: 2, exampleSentence: "我坐飞机去北京。", examplePinyin: "Wǒ zuò fēijī qù Běijīng.", exampleTranslation: "I fly to Beijing by plane."),
            Flashcard(chinese: "火车", pinyin: "huǒchē", english: "Train", french: "Train", pronunciation: "hwoh cher", category: "HSK 2", difficulty: 2, exampleSentence: "火车比飞机便宜。", examplePinyin: "Huǒchē bǐ fēijī piányi.", exampleTranslation: "Trains are cheaper than planes."),
            Flashcard(chinese: "地铁", pinyin: "dìtiě", english: "Subway", french: "Métro", pronunciation: "dee tee-eh", category: "HSK 2", difficulty: 2, exampleSentence: "我每天坐地铁上班。", examplePinyin: "Wǒ měitiān zuò dìtiě shàngbān.", exampleTranslation: "I take the subway to work every day."),
            Flashcard(chinese: "公共汽车", pinyin: "gōnggòng qìchē", english: "Bus", french: "Bus", pronunciation: "gong gong chee cher", category: "HSK 2", difficulty: 2, exampleSentence: "公共汽车站在哪里？", examplePinyin: "Gōnggòng qìchē zhàn zài nǎlǐ?", exampleTranslation: "Where is the bus stop?"),
            Flashcard(chinese: "自行车", pinyin: "zìxíngchē", english: "Bicycle", french: "Vélo", pronunciation: "dz shing cher", category: "HSK 2", difficulty: 2, exampleSentence: "我骑自行车去学校。", examplePinyin: "Wǒ qí zìxíngchē qù xuéxiào.", exampleTranslation: "I ride my bike to school."),
            Flashcard(chinese: "出租车", pinyin: "chūzūchē", english: "Taxi", french: "Taxi", pronunciation: "choo dzoo cher", category: "HSK 2", difficulty: 2, exampleSentence: "我们坐出租车去吧。", examplePinyin: "Wǒmen zuò chūzūchē qù ba.", exampleTranslation: "Let's take a taxi."),

            // Food (unchanged)
            Flashcard(chinese: "米饭", pinyin: "mǐfàn", english: "Rice", french: "Riz", pronunciation: "mee fan", category: "Food", difficulty: 1, exampleSentence: "我喜欢吃米饭。", examplePinyin: "Wǒ xǐhuān chī mǐfàn.", exampleTranslation: "I like eating rice."),
            Flashcard(chinese: "面条", pinyin: "miàntiáo", english: "Noodles", french: "Nouilles", pronunciation: "mee-en tee-ow", category: "Food", difficulty: 1, exampleSentence: "中国面条很好吃。", examplePinyin: "Zhōngguó miàntiáo hěn hǎochī.", exampleTranslation: "Chinese noodles are very delicious."),
            Flashcard(chinese: "包子", pinyin: "bāozi", english: "Steamed buns", french: "Bouchées vapeur", pronunciation: "bow dz", category: "Food", difficulty: 1, exampleSentence: "早上我吃包子。", examplePinyin: "Zǎoshang wǒ chī bāozi.", exampleTranslation: "I eat steamed buns in the morning."),
            Flashcard(chinese: "饺子", pinyin: "jiǎozi", english: "Dumplings", french: "Raviolis", pronunciation: "jee-ow dz", category: "Food", difficulty: 1, exampleSentence: "春节我们吃饺子。", examplePinyin: "Chūnjié wǒmen chī jiǎozi.", exampleTranslation: "We eat dumplings during Spring Festival."),
            Flashcard(chinese: "茶", pinyin: "chá", english: "Tea", french: "Thé", pronunciation: "chah", category: "Food", difficulty: 1, exampleSentence: "请给我一杯茶。", examplePinyin: "Qǐng gěi wǒ yī bēi chá.", exampleTranslation: "Please give me a cup of tea."),
            Flashcard(chinese: "咖啡", pinyin: "kāfēi", english: "Coffee", french: "Café", pronunciation: "kah fay", category: "Food", difficulty: 1, exampleSentence: "我每天喝咖啡。", examplePinyin: "Wǒ měitiān hē kāfēi.", exampleTranslation: "I drink coffee every day."),
            Flashcard(chinese: "水", pinyin: "shuǐ", english: "Water", french: "Eau", pronunciation: "shway", category: "Food", difficulty: 1, exampleSentence: "请给我一杯水。", examplePinyin: "Qǐng gěi wǒ yī bēi shuǐ.", exampleTranslation: "Please give me a glass of water."),
            Flashcard(chinese: "啤酒", pinyin: "píjiǔ", english: "Beer", french: "Bière", pronunciation: "pee jee-oh", category: "Food", difficulty: 1, exampleSentence: "夏天喝啤酒很舒服。", examplePinyin: "Xiàtiān hē píjiǔ hěn shūfú.", exampleTranslation: "Drinking beer in summer is very comfortable."),
            Flashcard(chinese: "水果", pinyin: "shuǐguǒ", english: "Fruit", french: "Fruit", pronunciation: "shway gwo", category: "Food", difficulty: 1, exampleSentence: "多吃水果对身体好。", examplePinyin: "Duō chī shuǐguǒ duì shēntǐ hǎo.", exampleTranslation: "Eating more fruit is good for health."),
            Flashcard(chinese: "苹果", pinyin: "píngguǒ", english: "Apple", french: "Pomme", pronunciation: "ping gwo", category: "Food", difficulty: 1, exampleSentence: "一天一个苹果。", examplePinyin: "Yī tiān yī gè píngguǒ.", exampleTranslation: "An apple a day."),
            Flashcard(chinese: "香蕉", pinyin: "xiāngjiāo", english: "Banana", french: "Banane", pronunciation: "she-ang jee-ow", category: "Food", difficulty: 1, exampleSentence: "香蕉很好吃。", examplePinyin: "Xiāngjiāo hěn hǎochī.", exampleTranslation: "Bananas are delicious."),
            Flashcard(chinese: "蔬菜", pinyin: "shūcài", english: "Vegetables", french: "Légumes", pronunciation: "shoo tsai", category: "Food", difficulty: 1, exampleSentence: "多吃蔬菜很健康。", examplePinyin: "Duō chī shūcài hěn jiànkāng.", exampleTranslation: "Eating more vegetables is healthy."),
            Flashcard(chinese: "肉", pinyin: "ròu", english: "Meat", french: "Viande", pronunciation: "row", category: "Food", difficulty: 1, exampleSentence: "我不吃牛肉。", examplePinyin: "Wǒ bù chī niúròu.", exampleTranslation: "I don't eat beef."),
            Flashcard(chinese: "鱼", pinyin: "yú", english: "Fish", french: "Poisson", pronunciation: "yoo", category: "Food", difficulty: 1, exampleSentence: "鱼很有营养。", examplePinyin: "Yú hěn yǒu yíngyǎng.", exampleTranslation: "Fish is very nutritious."),
            Flashcard(chinese: "鸡蛋", pinyin: "jīdàn", english: "Egg", french: "Œuf", pronunciation: "jee dan", category: "Food", difficulty: 1, exampleSentence: "我早餐吃鸡蛋。", examplePinyin: "Wǒ zǎocān chī jīdàn.", exampleTranslation: "I eat eggs for breakfast."),

            // Social Media Slang (unchanged)
            Flashcard(chinese: "绝绝子", pinyin: "juéjuézi", english: "Absolutely amazing/terrible (contextual)", french: "Absolument génial/terrible (selon le contexte)", pronunciation: "jweh-jweh-dzuh", category: "Social Media Slang", difficulty: 3, exampleSentence: "这部电影真是绝绝子！", examplePinyin: "Zhè bù diànyǐng zhēnshi juéjuézi!", exampleTranslation: "This movie is absolutely amazing!"),
            Flashcard(chinese: "爷青回", pinyin: "yéqīnghuí", english: "My youth is back (nostalgic)", french: "Ma jeunesse revient (nostalgique)", pronunciation: "yeh-ching-hway", category: "Social Media Slang", difficulty: 3, exampleSentence: "听到这首歌，我直接爷青回！", examplePinyin: "Tīngdào zhè shǒu gē, wǒ zhíjiē yéqīnghuí!", exampleTranslation: "Hearing this song, my youth instantly came back!"),
            Flashcard(chinese: "YYDS", pinyin: "yǒngyuǎn de shén", english: "Forever god/GOAT", french: "Dieu éternel/Le meilleur", pronunciation: "yong-ywen duh shen / wai-wai-di-es", category: "Social Media Slang", difficulty: 2, exampleSentence: "他简直是YYDS！", examplePinyin: "Tā jiǎnzhí shì YYDS!", exampleTranslation: "He is simply the GOAT!"),
            Flashcard(chinese: "破防", pinyin: "pòfáng", english: "Emotionally hit/ defenses broken", french: "Touché émotionnellement/défenses brisées", pronunciation: "pwuh-fahng", category: "Social Media Slang", difficulty: 3, exampleSentence: "这个故事让我破防了。", examplePinyin: "Zhège gùshi ràng wǒ pòfáng le.", exampleTranslation: "This story broke my emotional defenses."),
            Flashcard(chinese: "摆烂", pinyin: "bǎilàn", english: "Giving up/not trying anymore", french: "Abandonner/ne plus essayer", pronunciation: "bai-lan", category: "Social Media Slang", difficulty: 2, exampleSentence: "他选择摆烂。", examplePinyin: "Tā xuǎnzé bǎilàn.", exampleTranslation: "He chose to just give up."),
            Flashcard(chinese: "姐妹们", pinyin: "jiěmèimen", english: "\"Sisters\" (addressing followers)", french: "\"Les sœurs\" (aux abonnés)", pronunciation: "jyeh-mey-men", category: "Social Media Slang", difficulty: 1, exampleSentence: "姐妹们，看过来！", examplePinyin: "Jiěmèimen, kàn guòlai!", exampleTranslation: "Sisters, look over here!"),
            Flashcard(chinese: "种草/拔草", pinyin: "zhòngcǎo/bácǎo", english: "Wanting to buy / Losing interest", french: "Vouloir acheter / Perdre l'intérêt", pronunciation: "jong-tsao / ba-tsao", category: "Social Media Slang", difficulty: 2, exampleSentence: "我被种草了，然后又拔草了。", examplePinyin: "Wǒ bèi zhòngcǎo le, ránhòu yòu bácǎo le.", exampleTranslation: "I wanted to buy it, then I lost interest."),
            Flashcard(chinese: "好物", pinyin: "hǎowù", english: "Good finds/recommendations", french: "Bonnes trouvailles", pronunciation: "hao-woo", category: "Social Media Slang", difficulty: 1, exampleSentence: "分享一些好物。", examplePinyin: "Fēnxiǎng yīxiē hǎowù.", exampleTranslation: "Sharing some good finds."),
            Flashcard(chinese: "踩雷", pinyin: "cǎiléi", english: "Buying sth disappointing", french: "Acheter qqch de décevant", pronunciation: "tsai-ley", category: "Social Media Slang", difficulty: 2, exampleSentence: "这次购物踩雷了。", examplePinyin: "Zhè cì gòuwù cǎiléi le.", exampleTranslation: "This purchase was disappointing."),
            Flashcard(chinese: "干货", pinyin: "gānhuò", english: "Useful content/tips", french: "Contenu utile/conseils", pronunciation: "gan-hwoh", category: "Social Media Slang", difficulty: 2, exampleSentence: "这篇都是干货。", examplePinyin: "Zhè piān dōu shì gānhuò.", exampleTranslation: "This piece is full of useful tips."),
            Flashcard(chinese: "打工人", pinyin: "dǎgōngrén", english: "Working person/wage earner", french: "Travailleur/salarié", pronunciation: "da-gong-ren", category: "Social Media Slang", difficulty: 2, exampleSentence: "每个打工人都不容易。", examplePinyin: "Měi gè dǎgōngrén dōu bù róngyì.", exampleTranslation: "It's not easy for any working person."),
            Flashcard(chinese: "内卷", pinyin: "nèijuǎn", english: "Intense competition/rat race", french: "Compétition intense", pronunciation: "nay-jwuen", category: "Social Media Slang", difficulty: 3, exampleSentence: "这个行业太内卷了。", examplePinyin: "Zhège hángyè tài nèijuǎn le.", exampleTranslation: "This industry is too competitive."),
            Flashcard(chinese: "躺平", pinyin: "tǎngpíng", english: "Lying flat/giving up rat race", french: "S'allonger/abandonner la course", pronunciation: "tahng-ping", category: "Social Media Slang", difficulty: 2, exampleSentence: "他决定躺平了。", examplePinyin: "Tā juédìng tǎngpíng le.", exampleTranslation: "He decided to 'lie flat'."),
            Flashcard(chinese: "凡尔赛", pinyin: "fán'ěrsài", english: "Humble bragging", french: "Fausse modestie", pronunciation: "fan-er-sai", category: "Social Media Slang", difficulty: 3, exampleSentence: "他又在凡尔赛了。", examplePinyin: "Tā yòu zài fán'ěrsài le.", exampleTranslation: "He's humble bragging again."),
            Flashcard(chinese: "社死", pinyin: "shèsǐ", english: "Social death/extreme embarrassment", french: "Mort sociale/embarras extrême", pronunciation: "shuh-ssuh", category: "Social Media Slang", difficulty: 2, exampleSentence: "那真是大型社死现场。", examplePinyin: "Nà zhēnshi dàxíng shèsǐ xiànchǎng.", exampleTranslation: "That was a majorly embarrassing scene."),

            // Quebecois (new category)
            Flashcard(chinese: "该死", pinyin: "gāisǐ", english: "Damn it!/Holy shit!", french: "Tabarnak", pronunciation: "ta-bar-nak", category: "Quebecois", difficulty: 3, exampleSentence: "Tabarnak, j'ai oublié mes clés!", examplePinyin: "Tabarnak, j'ai oublié mes clés!", exampleTranslation: "Damn it, I forgot my keys!"),
            Flashcard(chinese: "妈的", pinyin: "māde", english: "Damn it!/Fuck!", french: "Câlisse", pronunciation: "ka-liss", category: "Quebecois", difficulty: 3, exampleSentence: "Câlisse, c'est froid!", examplePinyin: "Câlisse, c'est froid!", exampleTranslation: "Damn it, it's cold!"),
            Flashcard(chinese: "天啊", pinyin: "tiānā", english: "Damn it!/Christ!", french: "Crisse", pronunciation: "kriss", category: "Quebecois", difficulty: 3, exampleSentence: "Crisse, c'est cher!", examplePinyin: "Crisse, c'est cher!", exampleTranslation: "Damn it, it's expensive!"),
            Flashcard(chinese: "见鬼", pinyin: "jiànguǐ", english: "Damn it!/Host!", french: "Osti", pronunciation: "oss-tee", category: "Quebecois", difficulty: 3, exampleSentence: "Osti, j'ai mal à la tête!", examplePinyin: "Osti, j'ai mal à la tête!", exampleTranslation: "Damn it, I have a headache!"),
            Flashcard(chinese: "我的男朋友", pinyin: "wǒde nánpéngyou", english: "My boyfriend/guy friend", french: "Mon chum", pronunciation: "mon chum", category: "Quebecois", difficulty: 2, exampleSentence: "Mon chum est venu me chercher.", examplePinyin: "Mon chum est venu me chercher.", exampleTranslation: "My boyfriend came to pick me up."),
            Flashcard(chinese: "我的女朋友", pinyin: "wǒde nǚpéngyou", english: "My girlfriend", french: "Ma blonde", pronunciation: "ma blonde", category: "Quebecois", difficulty: 2, exampleSentence: "Ma blonde cuisine très bien.", examplePinyin: "Ma blonde cuisine très bien.", exampleTranslation: "My girlfriend cooks very well."),
            Flashcard(chinese: "抓住", pinyin: "zhuāzhù", english: "To catch/get/understand", french: "Pogner", pronunciation: "pog-nay", category: "Quebecois", difficulty: 2, exampleSentence: "Je pogne pas ce que tu veux dire.", examplePinyin: "Je pogne pas ce que tu veux dire.", exampleTranslation: "I don't understand what you mean."),
            Flashcard(chinese: "购物", pinyin: "gòuwù", english: "To go shopping", french: "Magasiner", pronunciation: "ma-ga-zee-nay", category: "Quebecois", difficulty: 2, exampleSentence: "On va magasiner demain.", examplePinyin: "On va magasiner demain.", exampleTranslation: "We're going shopping tomorrow."),
            Flashcard(chinese: "便利店", pinyin: "biànlìdiàn", english: "Convenience store", french: "Dépanneur", pronunciation: "day-pan-nur", category: "Quebecois", difficulty: 2, exampleSentence: "Je vais au dépanneur acheter du lait.", examplePinyin: "Je vais au dépanneur acheter du lait.", exampleTranslation: "I'm going to the convenience store to buy milk."),
            Flashcard(chinese: "肉汁薯条", pinyin: "ròuzhī shǔtiáo", english: "Poutine (fries with gravy and cheese curds)", french: "Poutine", pronunciation: "poo-teen", category: "Quebecois", difficulty: 1, exampleSentence: "J'aime manger de la poutine.", examplePinyin: "J'aime manger de la poutine.", exampleTranslation: "I like eating poutine."),
            Flashcard(chinese: "提姆霍顿", pinyin: "tímù huòdùn", english: "Tim Hortons (coffee chain)", french: "Tim Hortons", pronunciation: "tim hor-tons", category: "Quebecois", difficulty: 1, exampleSentence: "On va prendre un café chez Tim Hortons.", examplePinyin: "On va prendre un café chez Tim Hortons.", exampleTranslation: "We're going to get coffee at Tim Hortons."),
            Flashcard(chinese: "水电公司", pinyin: "shuǐdiàn gōngsī", english: "Hydro-Quebec (electricity company)", french: "Hydro", pronunciation: "high-dro", category: "Quebecois", difficulty: 2, exampleSentence: "J'ai reçu ma facture d'Hydro.", examplePinyin: "J'ai reçu ma facture d'Hydro.", exampleTranslation: "I received my Hydro bill."),
            Flashcard(chinese: "酒类专卖店", pinyin: "jiǔlèi zhuānmàidiàn", english: "SAQ (liquor store)", french: "SAQ", pronunciation: "sak", category: "Quebecois", difficulty: 2, exampleSentence: "Je vais à la SAQ acheter du vin.", examplePinyin: "Je vais à la SAQ acheter du vin.", exampleTranslation: "I'm going to the SAQ to buy wine."),
            Flashcard(chinese: "大麻专卖店", pinyin: "dàmá zhuānmàidiàn", english: "SQDC (cannabis store)", french: "SQDC", pronunciation: "ess-kew-day-say", category: "Quebecois", difficulty: 2, exampleSentence: "La SQDC est fermée le dimanche.", examplePinyin: "La SQDC est fermée le dimanche.", exampleTranslation: "The SQDC is closed on Sunday."),
            Flashcard(chinese: "欢迎", pinyin: "huānyíng", english: "Welcome/You're welcome", french: "Bienvenue", pronunciation: "bee-en-ven-ew", category: "Quebecois", difficulty: 1, exampleSentence: "Bienvenue au Québec!", examplePinyin: "Bienvenue au Québec!", exampleTranslation: "Welcome to Quebec!"),
            Flashcard(chinese: "没关系", pinyin: "méiguānxì", english: "It's okay/That's fine", french: "C'est correct", pronunciation: "say kor-rekt", category: "Quebecois", difficulty: 2, exampleSentence: "C'est correct, pas de problème.", examplePinyin: "C'est correct, pas de problème.", exampleTranslation: "It's okay, no problem."),
            Flashcard(chinese: "不错", pinyin: "bùcuò", english: "Not bad/pretty good", french: "Pas pire", pronunciation: "pa peer", category: "Quebecois", difficulty: 2, exampleSentence: "Le film était pas pire.", examplePinyin: "Le film était pas pire.", exampleTranslation: "The movie wasn't bad."),
            Flashcard(chinese: "很有趣", pinyin: "hěnyǒuqù", english: "It's fun/That's cool", french: "C'est le fun", pronunciation: "say luh fun", category: "Quebecois", difficulty: 2, exampleSentence: "C'est le fun de voyager.", examplePinyin: "C'est le fun de voyager.", exampleTranslation: "It's fun to travel."),
            Flashcard(chinese: "很无聊", pinyin: "hěnwúliáo", english: "It's boring/That sucks", french: "C'est plate", pronunciation: "say plat", category: "Quebecois", difficulty: 2, exampleSentence: "C'est plate, il pleut.", examplePinyin: "C'est plate, il pleut.", exampleTranslation: "That sucks, it's raining."),
            Flashcard(chinese: "我想", pinyin: "wǒxiǎng", english: "I feel like/I want to", french: "J'ai le goût", pronunciation: "zhay luh goo", category: "Quebecois", difficulty: 2, exampleSentence: "J'ai le goût de manger une poutine.", examplePinyin: "J'ai le goût de manger une poutine.", exampleTranslation: "I feel like eating a poutine."),
            Flashcard(chinese: "很烦人", pinyin: "hěnfánrén", english: "It's annoying/That's irritating", french: "C'est gossant", pronunciation: "say go-sant", category: "Quebecois", difficulty: 3, exampleSentence: "C'est gossant, il fait toujours la même chose.", examplePinyin: "C'est gossant, il fait toujours la même chose.", exampleTranslation: "It's annoying, he always does the same thing."),
            Flashcard(chinese: "很好玩", pinyin: "hěnhǎowán", english: "It's fun/That's cool", french: "C'est l'fun", pronunciation: "say luh fun", category: "Quebecois", difficulty: 2, exampleSentence: "C'est l'fun de skier en hiver.", examplePinyin: "C'est l'fun de skier en hiver.", exampleTranslation: "It's fun to ski in winter."),
            Flashcard(chinese: "很可爱", pinyin: "hěnkěài", english: "It's cute/That's sweet", french: "C'est cute", pronunciation: "say cute", category: "Quebecois", difficulty: 1, exampleSentence: "Ton chien est cute!", examplePinyin: "Ton chien est cute!", exampleTranslation: "Your dog is cute!"),
            Flashcard(chinese: "很酷", pinyin: "hěnkù", english: "It's hot/That's cool", french: "C'est hot", pronunciation: "say hot", category: "Quebecois", difficulty: 2, exampleSentence: "Cette voiture est hot!", examplePinyin: "Cette voiture est hot!", exampleTranslation: "This car is hot!"),
            Flashcard(chinese: "很便宜", pinyin: "hěnpiányi", english: "It's cheap/That's inexpensive", french: "C'est cheap", pronunciation: "say cheap", category: "Quebecois", difficulty: 2, exampleSentence: "Ce restaurant est cheap.", examplePinyin: "Ce restaurant est cheap.", exampleTranslation: "This restaurant is cheap."),
            Flashcard(chinese: "很奇怪", pinyin: "hěnqíguài", english: "It's weird/That's strange", french: "C'est weird", pronunciation: "say weird", category: "Quebecois", difficulty: 2, exampleSentence: "C'est weird, il ne répond jamais.", examplePinyin: "C'est weird, il ne répond jamais.", exampleTranslation: "It's weird, he never answers."),
            Flashcard(chinese: "很好", pinyin: "hěnhǎo", english: "It's nice/That's good", french: "C'est nice", pronunciation: "say nice", category: "Quebecois", difficulty: 1, exampleSentence: "C'est nice de te voir!", examplePinyin: "C'est nice de te voir!", exampleTranslation: "It's nice to see you!"),
            Flashcard(chinese: "很难", pinyin: "hěnnán", english: "It's tough/That's difficult", french: "C'est tough", pronunciation: "say tough", category: "Quebecois", difficulty: 2, exampleSentence: "C'est tough d'apprendre le français.", examplePinyin: "C'est tough d'apprendre le français.", exampleTranslation: "It's tough to learn French."),
            Flashcard(chinese: "很放松", pinyin: "hěnfàngsōng", english: "It's chill/That's relaxed", french: "C'est chill", pronunciation: "say chill", category: "Quebecois", difficulty: 2, exampleSentence: "C'est chill ici, on peut rester.", examplePinyin: "C'est chill ici, on peut rester.", exampleTranslation: "It's chill here, we can stay."),
            Flashcard(chinese: "很可疑", pinyin: "hěnkěyí", english: "It's sketchy/That's suspicious", french: "C'est sketchy", pronunciation: "say sketchy", category: "Quebecois", difficulty: 3, exampleSentence: "Ce quartier est sketchy.", examplePinyin: "Ce quartier est sketchy.", exampleTranslation: "This neighborhood is sketchy."),
            Flashcard(chinese: "很正宗", pinyin: "hěnzhèngzōng", english: "It's legit/That's legitimate", french: "C'est legit", pronunciation: "say legit", category: "Quebecois", difficulty: 2, exampleSentence: "Ce restaurant est legit.", examplePinyin: "Ce restaurant est legit.", exampleTranslation: "This restaurant is legit."),
            Flashcard(chinese: "很厉害", pinyin: "hěnlìhai", english: "It's sick/That's awesome", french: "C'est sick", pronunciation: "say sick", category: "Quebecois", difficulty: 2, exampleSentence: "Ce concert était sick!", examplePinyin: "Ce concert était sick!", exampleTranslation: "This concert was sick!"),
            Flashcard(chinese: "很酷", pinyin: "hěnkù", english: "It's dope/That's cool", french: "C'est dope", pronunciation: "say dope", category: "Quebecois", difficulty: 2, exampleSentence: "Cette musique est dope!", examplePinyin: "Cette musique est dope!", exampleTranslation: "This music is dope!"),
            Flashcard(chinese: "很火", pinyin: "hěnhuǒ", english: "It's fire/That's amazing", french: "C'est fire", pronunciation: "say fire", category: "Quebecois", difficulty: 2, exampleSentence: "Ce repas est fire!", examplePinyin: "Ce repas est fire!", exampleTranslation: "This meal is fire!"),
            Flashcard(chinese: "很赞", pinyin: "hěnzàn", english: "It's a banger/That's great", french: "C'est banger", pronunciation: "say ban-jer", category: "Quebecois", difficulty: 3, exampleSentence: "Cette chanson est un banger!", examplePinyin: "Cette chanson est un banger!", exampleTranslation: "This song is a banger!"),
            Flashcard(chinese: "很有感觉", pinyin: "hěnyǒugǎnjué", english: "It's vibe/That's the mood", french: "C'est vibe", pronunciation: "say vibe", category: "Quebecois", difficulty: 2, exampleSentence: "Cette soirée a une bonne vibe.", examplePinyin: "Cette soirée a une bonne vibe.", exampleTranslation: "This party has a good vibe."),
            Flashcard(chinese: "很有氛围", pinyin: "hěnyǒufēnwéi", english: "It's mood/That's the feeling", french: "C'est mood", pronunciation: "say mood", category: "Quebecois", difficulty: 2, exampleSentence: "Cette musique est mood.", examplePinyin: "Cette musique est mood.", exampleTranslation: "This music is mood."),
            Flashcard(chinese: "很有美感", pinyin: "hěnyǒuměigǎn", english: "It's aesthetic/That's beautiful", french: "C'est aesthetic", pronunciation: "say aesthetic", category: "Quebecois", difficulty: 3, exampleSentence: "Cette photo est aesthetic.", examplePinyin: "Cette photo est aesthetic.", exampleTranslation: "This photo is aesthetic."),
            Flashcard(chinese: "非常有美感", pinyin: "fēichánghǎoyǒuměigǎn", english: "It's very aesthetic", french: "C'est aesthetic af", pronunciation: "say aesthetic af", category: "Quebecois", difficulty: 3, exampleSentence: "Ce café est aesthetic af.", examplePinyin: "Ce café est aesthetic af.", exampleTranslation: "This café is very aesthetic.")
        ]
    }
}

// MARK: - Helper Structs & Extensions
struct QuizScore {
    var correct: Int
    var total: Int
}

enum QuizType {
    case meaning
}

extension String {
    func trimmed() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
