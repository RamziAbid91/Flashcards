//
//  FlashcardDeck.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-05-22.
import SwiftUI
import Combine

class FlashcardDeck: ObservableObject {
    @Published var cards: [Flashcard] = []
    @Published var categories: [String] = ["All"]
    @Published var quizScore = QuizScore(correct: 0, total: 0)
    @Published var showAdminPanel = false

    // MARK: - Cached Properties for Performance
    private var _favoriteCards: [Flashcard]?
    private var _seenCards: [Flashcard]?
    private var _basicWordsCards: [Flashcard]?
    private var _cardsByCategory: [String: [Flashcard]] = [:]
    
    private var documentsUrl: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    private var cardsFileUrl: URL {
        documentsUrl.appendingPathComponent("flashcards.json")
    }
    


    init() {
        loadCards()
    }

    // MARK: - Optimized Computed Properties with Caching
    var favoriteCards: [Flashcard] {
        if _favoriteCards == nil {
            _favoriteCards = cards.filter { $0.isFavorite }
        }
        return _favoriteCards ?? []
    }
    
    var seenCards: [Flashcard] {
        if _seenCards == nil {
            _seenCards = cards.filter { $0.seen }
        }
        return _seenCards ?? []
    }
    
    var basicWordsCards: [Flashcard] {
        if _basicWordsCards == nil {
            _basicWordsCards = cards.filter { $0.category.lowercased() == "basic words" }
        }
        return _basicWordsCards ?? []
    }
    
    // MARK: - Optimized Category Filtering
    func cards(for category: String) -> [Flashcard] {
        if category == "All" {
            return cards
        } else if category == "Favorites" {
            return favoriteCards
        } else {
            if _cardsByCategory[category] == nil {
                _cardsByCategory[category] = cards.filter { $0.category == category }
            }
            return _cardsByCategory[category] ?? []
        }
    }
    
    // MARK: - Cache Invalidation
    private func invalidateCaches() {
        _favoriteCards = nil
        _seenCards = nil
        _basicWordsCards = nil
        _cardsByCategory.removeAll()
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
        invalidateCaches() // Invalidate caches when cards are added
        updateCategories()
        saveCards()
    }

    func toggleFavorite(card: Flashcard) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].isFavorite.toggle()
            invalidateCaches() // Invalidate caches when favorites change
            
            // Force SwiftUI to update by triggering objectWillChange
            objectWillChange.send()
            
            saveCards()
        }
    }

    func shuffleCardsInCategory(_ category: String) {
        // Simple shuffle - just shuffle all cards
        cards.shuffle()
        saveCards()
    }

    func restoreDefaultOrder() {
        // Simply restore to default cards
        cards = FlashcardDeck.defaultCards()
        updateCategories()
        saveCards()
    }
    
    func resetToDefaultCards() {
        // Simply reset to default cards
        cards = FlashcardDeck.defaultCards()
        updateCategories()
        saveCards()
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
    private var saveTask: DispatchWorkItem?
    
    func saveCards() {
        // Cancel any pending save task
        saveTask?.cancel()
        
        // Create a new save task with debouncing
        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            do {
                let data = try encoder.encode(self.cards)
                try data.write(to: self.cardsFileUrl, options: .atomic)
            } catch {
                print("Error saving cards: \(error.localizedDescription)")
            }
        }
        
        saveTask = task
        
        // Debounce saves to avoid excessive I/O
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 0.5, execute: task)
    }

    private func loadCards() {
        // Try to load saved cards from file first
        if let data = try? Data(contentsOf: cardsFileUrl),
           let savedCards = try? JSONDecoder().decode([Flashcard].self, from: data) {
            cards = savedCards
        } else {
            // If no saved file exists or loading fails, use default cards
            cards = FlashcardDeck.defaultCards()
            saveCards() // Save the default set
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
        invalidateCaches() // Invalidate caches when categories change
    }
    
    // MARK: - Default Data
    // --- THIS IS THE UPDATED FUNCTION ---
    static func defaultCards() -> [Flashcard] {
        return [
           

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
            Flashcard(chinese: "他", pinyin: "tā", english: "He/Him", french: "Il/Lui", pronunciation: "tah", category: "Basic Words", difficulty: 1, exampleSentence: "他是我的老师。", examplePinyin: "Tā shì wǒ de lǎoshī.", exampleTranslation: "He is my teacher."),
            Flashcard(chinese: "她", pinyin: "tā", english: "She/Her", french: "Elle", pronunciation: "tah", category: "Basic Words", difficulty: 1, exampleSentence: "她是我的朋友。", examplePinyin: "Tā shì wǒ de péngyou.", exampleTranslation: "She is my friend."),
            Flashcard(chinese: "我们", pinyin: "wǒmen", english: "We/Us", french: "Nous", pronunciation: "woh-men", category: "Basic Words", difficulty: 1, exampleSentence: "我们是学生。", examplePinyin: "Wǒmen shì xuéshēng.", exampleTranslation: "We are students."),
            Flashcard(chinese: "他们", pinyin: "tāmen", english: "They/Them", french: "Ils/Elles", pronunciation: "tah-men", category: "Basic Words", difficulty: 1, exampleSentence: "他们是老师。", examplePinyin: "Tāmen shì lǎoshī.", exampleTranslation: "They are teachers."),
            Flashcard(chinese: "这", pinyin: "zhè", english: "This", french: "Ce/Cette", pronunciation: "juh", category: "Basic Words", difficulty: 1, exampleSentence: "这是什么？", examplePinyin: "Zhè shì shénme?", exampleTranslation: "What is this?"),
            Flashcard(chinese: "那", pinyin: "nà", english: "That", french: "Ce/Cette-là", pronunciation: "nah", category: "Basic Words", difficulty: 1, exampleSentence: "那是什么？", examplePinyin: "Nà shì shénme?", exampleTranslation: "What is that?"),
            Flashcard(chinese: "什么", pinyin: "shénme", english: "What", french: "Quoi/Qu'est-ce que", pronunciation: "shen-muh", category: "Basic Words", difficulty: 1, exampleSentence: "你在做什么？", examplePinyin: "Nǐ zài zuò shénme?", exampleTranslation: "What are you doing?"),
            Flashcard(chinese: "谁", pinyin: "shéi", english: "Who", french: "Qui", pronunciation: "shay", category: "Basic Words", difficulty: 1, exampleSentence: "他是谁？", examplePinyin: "Tā shì shéi?", exampleTranslation: "Who is he?"),
            Flashcard(chinese: "哪里", pinyin: "nǎlǐ", english: "Where", french: "Où", pronunciation: "nah-lee", category: "Basic Words", difficulty: 1, exampleSentence: "你在哪里？", examplePinyin: "Nǐ zài nǎlǐ?", exampleTranslation: "Where are you?"),
            Flashcard(chinese: "什么时候", pinyin: "shénme shíhou", english: "When", french: "Quand", pronunciation: "shen-muh shir-how", category: "Basic Words", difficulty: 1, exampleSentence: "你什么时候来？", examplePinyin: "Nǐ shénme shíhou lái?", exampleTranslation: "When are you coming?"),
            Flashcard(chinese: "为什么", pinyin: "wèishénme", english: "Why", french: "Pourquoi", pronunciation: "way-shen-muh", category: "Basic Words", difficulty: 1, exampleSentence: "你为什么迟到？", examplePinyin: "Nǐ wèishénme chídào?", exampleTranslation: "Why are you late?"),
            Flashcard(chinese: "怎么", pinyin: "zěnme", english: "How", french: "Comment", pronunciation: "dzuhn-muh", category: "Basic Words", difficulty: 1, exampleSentence: "你怎么去学校？", examplePinyin: "Nǐ zěnme qù xuéxiào?", exampleTranslation: "How do you go to school?"),
            Flashcard(chinese: "多少", pinyin: "duōshao", english: "How much/How many", french: "Combien", pronunciation: "dwoh-shao", category: "Basic Words", difficulty: 1, exampleSentence: "这个多少钱？", examplePinyin: "Zhège duōshao qián?", exampleTranslation: "How much is this?"),
            Flashcard(chinese: "大", pinyin: "dà", english: "Big/Large", french: "Grand", pronunciation: "dah", category: "Basic Words", difficulty: 1, exampleSentence: "这个房子很大。", examplePinyin: "Zhège fángzi hěn dà.", exampleTranslation: "This house is very big."),
            Flashcard(chinese: "小", pinyin: "xiǎo", english: "Small/Little", french: "Petit", pronunciation: "shyao", category: "Basic Words", difficulty: 1, exampleSentence: "这是一只小猫。", examplePinyin: "Zhè shì yī zhī xiǎo māo.", exampleTranslation: "This is a small cat."),
            Flashcard(chinese: "新", pinyin: "xīn", english: "New", french: "Nouveau/Nouvelle", pronunciation: "sheen", category: "Basic Words", difficulty: 1, exampleSentence: "我买了一本新书。", examplePinyin: "Wǒ mǎi le yī běn xīn shū.", exampleTranslation: "I bought a new book."),
            Flashcard(chinese: "旧", pinyin: "jiù", english: "Old", french: "Vieux/Vieille", pronunciation: "jyo", category: "Basic Words", difficulty: 1, exampleSentence: "这是一辆旧车。", examplePinyin: "Zhè shì yī liàng jiù chē.", exampleTranslation: "This is an old car."),
            Flashcard(chinese: "好", pinyin: "hǎo", english: "Good", french: "Bon", pronunciation: "how", category: "Basic Words", difficulty: 1, exampleSentence: "我很好。", examplePinyin: "Wǒ hěn hǎo.", exampleTranslation: "I'm very good."),
            Flashcard(chinese: "坏", pinyin: "huài", english: "Bad", french: "Mauvais", pronunciation: "hwai", category: "Basic Words", difficulty: 1, exampleSentence: "这个主意很坏。", examplePinyin: "Zhège zhǔyì hěn huài.", exampleTranslation: "This idea is very bad."),
            Flashcard(chinese: "多", pinyin: "duō", english: "Many/Much", french: "Beaucoup", pronunciation: "dwoh", category: "Basic Words", difficulty: 1, exampleSentence: "这里有很多人。", examplePinyin: "Zhèlǐ yǒu hěn duō rén.", exampleTranslation: "There are many people here."),
            Flashcard(chinese: "少", pinyin: "shǎo", english: "Few/Little", french: "Peu", pronunciation: "shao", category: "Basic Words", difficulty: 1, exampleSentence: "这里人很少。", examplePinyin: "Zhèlǐ rén hěn shǎo.", exampleTranslation: "There are few people here."),
            Flashcard(chinese: "有", pinyin: "yǒu", english: "Have/There is", french: "Avoir/Il y a", pronunciation: "yo", category: "Basic Words", difficulty: 1, exampleSentence: "我有两个朋友。", examplePinyin: "Wǒ yǒu liǎng gè péngyou.", exampleTranslation: "I have two friends."),
            Flashcard(chinese: "没有", pinyin: "méiyǒu", english: "Don't have/There isn't", french: "Ne pas avoir/Il n'y a pas", pronunciation: "may-yo", category: "Basic Words", difficulty: 1, exampleSentence: "我没有钱。", examplePinyin: "Wǒ méiyǒu qián.", exampleTranslation: "I don't have money."),
            Flashcard(chinese: "可以", pinyin: "kěyǐ", english: "Can/May", french: "Pouvoir", pronunciation: "kuh-yee", category: "Basic Words", difficulty: 1, exampleSentence: "我可以帮你。", examplePinyin: "Wǒ kěyǐ bāng nǐ.", exampleTranslation: "I can help you."),
            Flashcard(chinese: "不能", pinyin: "bùnéng", english: "Cannot", french: "Ne pas pouvoir", pronunciation: "boo-nung", category: "Basic Words", difficulty: 1, exampleSentence: "我不能去。", examplePinyin: "Wǒ bùnéng qù.", exampleTranslation: "I cannot go."),
            Flashcard(chinese: "要", pinyin: "yào", english: "Want/Need", french: "Vouloir/Besoin", pronunciation: "yao", category: "Basic Words", difficulty: 1, exampleSentence: "我要喝水。", examplePinyin: "Wǒ yào hē shuǐ.", exampleTranslation: "I want to drink water."),
            Flashcard(chinese: "不要", pinyin: "bùyào", english: "Don't want/Don't", french: "Ne pas vouloir/Ne pas", pronunciation: "boo-yao", category: "Basic Words", difficulty: 1, exampleSentence: "不要说话。", examplePinyin: "Bùyào shuōhuà.", exampleTranslation: "Don't speak."),
            Flashcard(chinese: "会", pinyin: "huì", english: "Can/Will", french: "Pouvoir/Aller", pronunciation: "hway", category: "Basic Words", difficulty: 1, exampleSentence: "我会说中文。", examplePinyin: "Wǒ huì shuō Zhōngwén.", exampleTranslation: "I can speak Chinese."),
            Flashcard(chinese: "不会", pinyin: "bùhuì", english: "Cannot/Don't know how", french: "Ne pas pouvoir/Ne pas savoir", pronunciation: "boo-hway", category: "Basic Words", difficulty: 1, exampleSentence: "我不会游泳。", examplePinyin: "Wǒ bùhuì yóuyǒng.", exampleTranslation: "I cannot swim."),
            Flashcard(chinese: "喜欢", pinyin: "xǐhuān", english: "Like", french: "Aimer", pronunciation: "shee-hwan", category: "Basic Words", difficulty: 1, exampleSentence: "我喜欢音乐。", examplePinyin: "Wǒ xǐhuān yīnyuè.", exampleTranslation: "I like music."),
            Flashcard(chinese: "不喜欢", pinyin: "bùxǐhuān", english: "Don't like", french: "Ne pas aimer", pronunciation: "boo-shee-hwan", category: "Basic Words", difficulty: 1, exampleSentence: "我不喜欢咖啡。", examplePinyin: "Wǒ bùxǐhuān kāfēi.", exampleTranslation: "I don't like coffee."),
            Flashcard(chinese: "知道", pinyin: "zhīdào", english: "Know", french: "Savoir/Connaître", pronunciation: "jyh-dao", category: "Basic Words", difficulty: 1, exampleSentence: "我知道答案。", examplePinyin: "Wǒ zhīdào dá'àn.", exampleTranslation: "I know the answer."),
            Flashcard(chinese: "不知道", pinyin: "bùzhīdào", english: "Don't know", french: "Ne pas savoir", pronunciation: "boo-jyh-dao", category: "Basic Words", difficulty: 1, exampleSentence: "我不知道。", examplePinyin: "Wǒ bùzhīdào.", exampleTranslation: "I don't know."),
            Flashcard(chinese: "现在", pinyin: "xiànzài", english: "Now", french: "Maintenant", pronunciation: "sheen-dzai", category: "Basic Words", difficulty: 1, exampleSentence: "现在几点了？", examplePinyin: "Xiànzài jǐ diǎn le?", exampleTranslation: "What time is it now?"),
            Flashcard(chinese: "以前", pinyin: "yǐqián", english: "Before/Previously", french: "Avant/Précédemment", pronunciation: "yee-chee-en", category: "Basic Words", difficulty: 1, exampleSentence: "我以前住在这里。", examplePinyin: "Wǒ yǐqián zhù zài zhèlǐ.", exampleTranslation: "I used to live here."),
            Flashcard(chinese: "以后", pinyin: "yǐhòu", english: "After/Later", french: "Après/Plus tard", pronunciation: "yee-how", category: "Basic Words", difficulty: 1, exampleSentence: "我们以后见。", examplePinyin: "Wǒmen yǐhòu jiàn.", exampleTranslation: "See you later."),
            Flashcard(chinese: "今天", pinyin: "jīntiān", english: "Today", french: "Aujourd'hui", pronunciation: "jin-tyen", category: "Basic Words", difficulty: 1, exampleSentence: "今天天气很好。", examplePinyin: "Jīntiān tiānqì hěn hǎo.", exampleTranslation: "The weather is nice today."),
            Flashcard(chinese: "昨天", pinyin: "zuótiān", english: "Yesterday", french: "Hier", pronunciation: "dzwo-tyen", category: "Basic Words", difficulty: 1, exampleSentence: "昨天我去了学校。", examplePinyin: "Zuótiān wǒ qù le xuéxiào.", exampleTranslation: "Yesterday I went to school."),
            Flashcard(chinese: "明天", pinyin: "míngtiān", english: "Tomorrow", french: "Demain", pronunciation: "ming-tyen", category: "Basic Words", difficulty: 1, exampleSentence: "明天见！", examplePinyin: "Míngtiān jiàn!", exampleTranslation: "See you tomorrow!"),
            Flashcard(chinese: "这里", pinyin: "zhèlǐ", english: "Here", french: "Ici", pronunciation: "juh-lee", category: "Basic Words", difficulty: 1, exampleSentence: "请来这里。", examplePinyin: "Qǐng lái zhèlǐ.", exampleTranslation: "Please come here."),
            Flashcard(chinese: "那里", pinyin: "nàlǐ", english: "There", french: "Là", pronunciation: "nah-lee", category: "Basic Words", difficulty: 1, exampleSentence: "他在那里。", examplePinyin: "Tā zài nàlǐ.", exampleTranslation: "He is there."),
            Flashcard(chinese: "里面", pinyin: "lǐmiàn", english: "Inside", french: "Dedans/À l'intérieur", pronunciation: "lee-mee-en", category: "Basic Words", difficulty: 1, exampleSentence: "书在包里面。", examplePinyin: "Shū zài bāo lǐmiàn.", exampleTranslation: "The book is inside the bag."),
            Flashcard(chinese: "外面", pinyin: "wàimiàn", english: "Outside", french: "Dehors/À l'extérieur", pronunciation: "wai-mee-en", category: "Basic Words", difficulty: 1, exampleSentence: "他在外面。", examplePinyin: "Tā zài wàimiàn.", exampleTranslation: "He is outside."),
            Flashcard(chinese: "上面", pinyin: "shàngmiàn", english: "Above/On top", french: "Au-dessus/Sur", pronunciation: "shahng-mee-en", category: "Basic Words", difficulty: 1, exampleSentence: "书在桌子上面。", examplePinyin: "Shū zài zhuōzi shàngmiàn.", exampleTranslation: "The book is on the table."),
            Flashcard(chinese: "下面", pinyin: "xiàmiàn", english: "Below/Under", french: "En-dessous/Sous", pronunciation: "shyah-mee-en", category: "Basic Words", difficulty: 1, exampleSentence: "猫在桌子下面。", examplePinyin: "Māo zài zhuōzi xiàmiàn.", exampleTranslation: "The cat is under the table."),
            
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
            Flashcard(chinese: "面包", pinyin: "miànbāo", english: "Bread", french: "Pain", pronunciation: "mee-en bow", category: "Food", difficulty: 1, exampleSentence: "我每天早上吃面包。", examplePinyin: "Wǒ měitiān zǎoshang chī miànbāo.", exampleTranslation: "I eat bread every morning."),
            Flashcard(chinese: "牛奶", pinyin: "niúnǎi", english: "Milk", french: "Lait", pronunciation: "nyo nai", category: "Food", difficulty: 1, exampleSentence: "我喜欢喝牛奶。", examplePinyin: "Wǒ xǐhuān hē niúnǎi.", exampleTranslation: "I like drinking milk."),
            Flashcard(chinese: "奶酪", pinyin: "nǎilào", english: "Cheese", french: "Fromage", pronunciation: "nai lao", category: "Food", difficulty: 1, exampleSentence: "这个奶酪很好吃。", examplePinyin: "Zhège nǎilào hěn hǎochī.", exampleTranslation: "This cheese is very delicious."),
            Flashcard(chinese: "黄油", pinyin: "huángyóu", english: "Butter", french: "Beurre", pronunciation: "hwahng yo", category: "Food", difficulty: 1, exampleSentence: "面包上涂黄油。", examplePinyin: "Miànbāo shàng tú huángyóu.", exampleTranslation: "Spread butter on bread."),
            Flashcard(chinese: "糖", pinyin: "táng", english: "Sugar", french: "Sucre", pronunciation: "tahng", category: "Food", difficulty: 1, exampleSentence: "咖啡里加糖。", examplePinyin: "Kāfēi lǐ jiā táng.", exampleTranslation: "Add sugar to coffee."),
            Flashcard(chinese: "盐", pinyin: "yán", english: "Salt", french: "Sel", pronunciation: "yen", category: "Food", difficulty: 1, exampleSentence: "菜里放盐。", examplePinyin: "Cài lǐ fàng yán.", exampleTranslation: "Add salt to the dish."),
            Flashcard(chinese: "油", pinyin: "yóu", english: "Oil", french: "Huile", pronunciation: "yo", category: "Food", difficulty: 1, exampleSentence: "用油炒菜。", examplePinyin: "Yòng yóu chǎo cài.", exampleTranslation: "Stir-fry vegetables with oil."),
            Flashcard(chinese: "酱油", pinyin: "jiàngyóu", english: "Soy sauce", french: "Sauce soja", pronunciation: "jyahng yo", category: "Food", difficulty: 1, exampleSentence: "米饭配酱油。", examplePinyin: "Mǐfàn pèi jiàngyóu.", exampleTranslation: "Rice with soy sauce."),
            Flashcard(chinese: "醋", pinyin: "cù", english: "Vinegar", french: "Vinaigre", pronunciation: "tsoo", category: "Food", difficulty: 1, exampleSentence: "凉菜加醋。", examplePinyin: "Liángcài jiā cù.", exampleTranslation: "Add vinegar to cold dishes."),
            Flashcard(chinese: "辣椒", pinyin: "làjiāo", english: "Chili pepper", french: "Piment", pronunciation: "lah jyao", category: "Food", difficulty: 1, exampleSentence: "这个辣椒很辣。", examplePinyin: "Zhège làjiāo hěn là.", exampleTranslation: "This chili pepper is very spicy."),
            Flashcard(chinese: "大蒜", pinyin: "dàsuàn", english: "Garlic", french: "Ail", pronunciation: "dah swan", category: "Food", difficulty: 1, exampleSentence: "炒菜放大蒜。", examplePinyin: "Chǎo cài fàng dàsuàn.", exampleTranslation: "Add garlic when stir-frying."),
            Flashcard(chinese: "洋葱", pinyin: "yángcōng", english: "Onion", french: "Oignon", pronunciation: "yahng tsong", category: "Food", difficulty: 1, exampleSentence: "洋葱炒鸡蛋。", examplePinyin: "Yángcōng chǎo jīdàn.", exampleTranslation: "Stir-fry eggs with onions."),
            Flashcard(chinese: "土豆", pinyin: "tǔdòu", english: "Potato", french: "Pomme de terre", pronunciation: "too doh", category: "Food", difficulty: 1, exampleSentence: "土豆炖牛肉。", examplePinyin: "Tǔdòu dùn niúròu.", exampleTranslation: "Stew beef with potatoes."),
            Flashcard(chinese: "胡萝卜", pinyin: "húluóbo", english: "Carrot", french: "Carotte", pronunciation: "hoo lwo buh", category: "Food", difficulty: 1, exampleSentence: "胡萝卜很有营养。", examplePinyin: "Húluóbo hěn yǒu yíngyǎng.", exampleTranslation: "Carrots are very nutritious."),
            Flashcard(chinese: "西红柿", pinyin: "xīhóngshì", english: "Tomato", french: "Tomate", pronunciation: "she hong shir", category: "Food", difficulty: 1, exampleSentence: "西红柿炒鸡蛋。", examplePinyin: "Xīhóngshì chǎo jīdàn.", exampleTranslation: "Stir-fry eggs with tomatoes."),
            Flashcard(chinese: "黄瓜", pinyin: "huángguā", english: "Cucumber", french: "Concombre", pronunciation: "hwahng gwah", category: "Food", difficulty: 1, exampleSentence: "凉拌黄瓜。", examplePinyin: "Liángbàn huángguā.", exampleTranslation: "Cold cucumber salad."),
            Flashcard(chinese: "白菜", pinyin: "báicài", english: "Chinese cabbage", french: "Chou chinois", pronunciation: "bai tsai", category: "Food", difficulty: 1, exampleSentence: "白菜汤很清淡。", examplePinyin: "Báicài tāng hěn qīngdàn.", exampleTranslation: "Chinese cabbage soup is light."),
            Flashcard(chinese: "菠菜", pinyin: "bōcài", english: "Spinach", french: "Épinards", pronunciation: "bwo tsai", category: "Food", difficulty: 1, exampleSentence: "菠菜炒鸡蛋。", examplePinyin: "Bōcài chǎo jīdàn.", exampleTranslation: "Stir-fry eggs with spinach."),
            Flashcard(chinese: "豆腐", pinyin: "dòufu", english: "Tofu", french: "Tofu", pronunciation: "doh foo", category: "Food", difficulty: 1, exampleSentence: "麻婆豆腐很辣。", examplePinyin: "Mápó dòufu hěn là.", exampleTranslation: "Mapo tofu is very spicy."),
            Flashcard(chinese: "花生", pinyin: "huāshēng", english: "Peanut", french: "Cacahuète", pronunciation: "hwah shung", category: "Food", difficulty: 1, exampleSentence: "花生酱很好吃。", examplePinyin: "Huāshēngjiàng hěn hǎochī.", exampleTranslation: "Peanut butter is delicious."),
            Flashcard(chinese: "瓜子", pinyin: "guāzǐ", english: "Sunflower seeds", french: "Graines de tournesol", pronunciation: "gwah dz", category: "Food", difficulty: 1, exampleSentence: "看电视时嗑瓜子。", examplePinyin: "Kàn diànshì shí kè guāzǐ.", exampleTranslation: "Eat sunflower seeds while watching TV."),
            Flashcard(chinese: "橙子", pinyin: "chéngzi", english: "Orange", french: "Orange", pronunciation: "chung dz", category: "Food", difficulty: 1, exampleSentence: "橙子很甜。", examplePinyin: "Chéngzi hěn tián.", exampleTranslation: "Oranges are sweet."),
            Flashcard(chinese: "葡萄", pinyin: "pútáo", english: "Grape", french: "Raisin", pronunciation: "poo tao", category: "Food", difficulty: 1, exampleSentence: "葡萄很新鲜。", examplePinyin: "Pútáo hěn xīnxiān.", exampleTranslation: "The grapes are very fresh."),
            Flashcard(chinese: "草莓", pinyin: "cǎoméi", english: "Strawberry", french: "Fraise", pronunciation: "tsao may", category: "Food", difficulty: 1, exampleSentence: "草莓蛋糕。", examplePinyin: "Cǎoméi dàngāo.", exampleTranslation: "Strawberry cake."),
            Flashcard(chinese: "西瓜", pinyin: "xīguā", english: "Watermelon", french: "Pastèque", pronunciation: "she gwah", category: "Food", difficulty: 1, exampleSentence: "夏天吃西瓜。", examplePinyin: "Xiàtiān chī xīguā.", exampleTranslation: "Eat watermelon in summer."),
            Flashcard(chinese: "柠檬", pinyin: "níngméng", english: "Lemon", french: "Citron", pronunciation: "ning mung", category: "Food", difficulty: 1, exampleSentence: "柠檬水很酸。", examplePinyin: "Níngméng shuǐ hěn suān.", exampleTranslation: "Lemon water is sour."),
            Flashcard(chinese: "葡萄柚", pinyin: "pútáoyòu", english: "Grapefruit", french: "Pamplemousse", pronunciation: "poo tao yo", category: "Food", difficulty: 1, exampleSentence: "葡萄柚很酸。", examplePinyin: "Pútáoyòu hěn suān.", exampleTranslation: "Grapefruit is sour."),
            Flashcard(chinese: "鸡肉", pinyin: "jīròu", english: "Chicken", french: "Poulet", pronunciation: "jee row", category: "Food", difficulty: 1, exampleSentence: "宫保鸡丁。", examplePinyin: "Gōngbǎo jīdīng.", exampleTranslation: "Kung pao chicken."),
            Flashcard(chinese: "猪肉", pinyin: "zhūròu", english: "Pork", french: "Porc", pronunciation: "joo row", category: "Food", difficulty: 1, exampleSentence: "红烧肉。", examplePinyin: "Hóngshāo ròu.", exampleTranslation: "Braised pork."),
            Flashcard(chinese: "牛肉", pinyin: "niúròu", english: "Beef", french: "Bœuf", pronunciation: "nyo row", category: "Food", difficulty: 1, exampleSentence: "牛肉面。", examplePinyin: "Niúròu miàn.", exampleTranslation: "Beef noodles."),
            Flashcard(chinese: "羊肉", pinyin: "yángròu", english: "Lamb", french: "Agneau", pronunciation: "yahng row", category: "Food", difficulty: 1, exampleSentence: "烤羊肉。", examplePinyin: "Kǎo yángròu.", exampleTranslation: "Roasted lamb."),
            Flashcard(chinese: "虾", pinyin: "xiā", english: "Shrimp", french: "Crevette", pronunciation: "shyah", category: "Food", difficulty: 1, exampleSentence: "清炒虾仁。", examplePinyin: "Qīng chǎo xiārén.", exampleTranslation: "Stir-fried shrimp."),
            Flashcard(chinese: "螃蟹", pinyin: "pángxiè", english: "Crab", french: "Crabe", pronunciation: "pahng shyeh", category: "Food", difficulty: 1, exampleSentence: "清蒸螃蟹。", examplePinyin: "Qīngzhēng pángxiè.", exampleTranslation: "Steamed crab."),
            Flashcard(chinese: "鱿鱼", pinyin: "yóuyú", english: "Squid", french: "Calamar", pronunciation: "yo yoo", category: "Food", difficulty: 1, exampleSentence: "铁板鱿鱼。", examplePinyin: "Tiěbǎn yóuyú.", exampleTranslation: "Sizzling squid."),
            Flashcard(chinese: "蛋糕", pinyin: "dàngāo", english: "Cake", french: "Gâteau", pronunciation: "dah gao", category: "Food", difficulty: 1, exampleSentence: "生日蛋糕。", examplePinyin: "Shēngrì dàngāo.", exampleTranslation: "Birthday cake."),
            Flashcard(chinese: "饼干", pinyin: "bǐnggān", english: "Cookie", french: "Biscuit", pronunciation: "bing gan", category: "Food", difficulty: 1, exampleSentence: "巧克力饼干。", examplePinyin: "Qiǎokèlì bǐnggān.", exampleTranslation: "Chocolate cookies."),
            Flashcard(chinese: "冰淇淋", pinyin: "bīngqílín", english: "Ice cream", french: "Crème glacée", pronunciation: "bing chee lin", category: "Food", difficulty: 1, exampleSentence: "香草冰淇淋。", examplePinyin: "Xiāngcǎo bīngqílín.", exampleTranslation: "Vanilla ice cream."),
            Flashcard(chinese: "巧克力", pinyin: "qiǎokèlì", english: "Chocolate", french: "Chocolat", pronunciation: "chyao kuh lee", category: "Food", difficulty: 1, exampleSentence: "黑巧克力。", examplePinyin: "Hēi qiǎokèlì.", exampleTranslation: "Dark chocolate."),
            Flashcard(chinese: "糖果", pinyin: "tángguǒ", english: "Candy", french: "Bonbon", pronunciation: "tahng gwo", category: "Food", difficulty: 1, exampleSentence: "水果糖。", examplePinyin: "Shuǐguǒ táng.", exampleTranslation: "Fruit candy."),
            Flashcard(chinese: "口香糖", pinyin: "kǒuxiāngtáng", english: "Chewing gum", french: "Gomme à mâcher", pronunciation: "koh shyahng tahng", category: "Food", difficulty: 1, exampleSentence: "薄荷口香糖。", examplePinyin: "Bòhé kǒuxiāngtáng.", exampleTranslation: "Mint chewing gum."),
            Flashcard(chinese: "薯条", pinyin: "shǔtiáo", english: "French fries", french: "Frites", pronunciation: "shoo tyao", category: "Food", difficulty: 1, exampleSentence: "麦当劳薯条。", examplePinyin: "Màidāngláo shǔtiáo.", exampleTranslation: "McDonald's fries."),
            Flashcard(chinese: "汉堡", pinyin: "hànbǎo", english: "Hamburger", french: "Hamburger", pronunciation: "han bow", category: "Food", difficulty: 1, exampleSentence: "牛肉汉堡。", examplePinyin: "Niúròu hànbǎo.", exampleTranslation: "Beef hamburger."),
            Flashcard(chinese: "披萨", pinyin: "pīsà", english: "Pizza", french: "Pizza", pronunciation: "pee sah", category: "Food", difficulty: 1, exampleSentence: "意大利披萨。", examplePinyin: "Yìdàlì pīsà.", exampleTranslation: "Italian pizza."),
            Flashcard(chinese: "寿司", pinyin: "shòusī", english: "Sushi", french: "Sushi", pronunciation: "show suh", category: "Food", difficulty: 1, exampleSentence: "日本寿司。", examplePinyin: "Rìběn shòusī.", exampleTranslation: "Japanese sushi."),
            Flashcard(chinese: "火锅", pinyin: "huǒguō", english: "Hot pot", french: "Fondue chinoise", pronunciation: "hwo gwo", category: "Food", difficulty: 1, exampleSentence: "四川火锅。", examplePinyin: "Sìchuān huǒguō.", exampleTranslation: "Sichuan hot pot."),
            Flashcard(chinese: "烧烤", pinyin: "shāokǎo", english: "Barbecue", french: "Barbecue", pronunciation: "shao kao", category: "Food", difficulty: 1, exampleSentence: "户外烧烤。", examplePinyin: "Hùwài shāokǎo.", exampleTranslation: "Outdoor barbecue."),
            Flashcard(chinese: "沙拉", pinyin: "shālā", english: "Salad", french: "Salade", pronunciation: "shah lah", category: "Food", difficulty: 1, exampleSentence: "蔬菜沙拉。", examplePinyin: "Shūcài shālā.", exampleTranslation: "Vegetable salad."),
            Flashcard(chinese: "汤", pinyin: "tāng", english: "Soup", french: "Soupe", pronunciation: "tahng", category: "Food", difficulty: 1, exampleSentence: "鸡汤。", examplePinyin: "Jī tāng.", exampleTranslation: "Chicken soup."),
            Flashcard(chinese: "粥", pinyin: "zhōu", english: "Porridge", french: "Porridge", pronunciation: "joh", category: "Food", difficulty: 1, exampleSentence: "白粥。", examplePinyin: "Bái zhōu.", exampleTranslation: "Plain porridge."),
            Flashcard(chinese: "面条", pinyin: "miàntiáo", english: "Noodles", french: "Nouilles", pronunciation: "mee-en tee-ow", category: "Food", difficulty: 1, exampleSentence: "中国面条很好吃。", examplePinyin: "Zhōngguó miàntiáo hěn hǎochī.", exampleTranslation: "Chinese noodles are very delicious."),

            // Travel (new category)
            Flashcard(chinese: "旅行", pinyin: "lǚxíng", english: "Travel", french: "Voyage", pronunciation: "lyoo-shing", category: "Travel", difficulty: 1, exampleSentence: "我喜欢旅行。", examplePinyin: "Wǒ xǐhuān lǚxíng.", exampleTranslation: "I like traveling."),
            Flashcard(chinese: "旅游", pinyin: "lǚyóu", english: "Tourism", french: "Tourisme", pronunciation: "lyoo-yo", category: "Travel", difficulty: 1, exampleSentence: "中国旅游很受欢迎。", examplePinyin: "Zhōngguó lǚyóu hěn shòu huānyíng.", exampleTranslation: "Chinese tourism is very popular."),
            Flashcard(chinese: "护照", pinyin: "hùzhào", english: "Passport", french: "Passeport", pronunciation: "hoo-jao", category: "Travel", difficulty: 1, exampleSentence: "请出示您的护照。", examplePinyin: "Qǐng chūshì nín de hùzhào.", exampleTranslation: "Please show your passport."),
            Flashcard(chinese: "签证", pinyin: "qiānzhèng", english: "Visa", french: "Visa", pronunciation: "chee-en-jung", category: "Travel", difficulty: 1, exampleSentence: "我需要申请签证。", examplePinyin: "Wǒ xūyào shēnqǐng qiānzhèng.", exampleTranslation: "I need to apply for a visa."),
            Flashcard(chinese: "机票", pinyin: "jīpiào", english: "Airplane ticket", french: "Billet d'avion", pronunciation: "jee-pee-ow", category: "Travel", difficulty: 1, exampleSentence: "我买了机票。", examplePinyin: "Wǒ mǎi le jīpiào.", exampleTranslation: "I bought an airplane ticket."),
            Flashcard(chinese: "火车票", pinyin: "huǒchēpiào", english: "Train ticket", french: "Billet de train", pronunciation: "hwo-chuh-pee-ow", category: "Travel", difficulty: 1, exampleSentence: "请给我一张火车票。", examplePinyin: "Qǐng gěi wǒ yī zhāng huǒchēpiào.", exampleTranslation: "Please give me a train ticket."),
            Flashcard(chinese: "酒店", pinyin: "jiǔdiàn", english: "Hotel", french: "Hôtel", pronunciation: "jyo-dee-en", category: "Travel", difficulty: 1, exampleSentence: "我住在酒店。", examplePinyin: "Wǒ zhù zài jiǔdiàn.", exampleTranslation: "I'm staying at a hotel."),
            Flashcard(chinese: "旅馆", pinyin: "lǚguǎn", english: "Inn/Guesthouse", french: "Auberge", pronunciation: "lyoo-gwan", category: "Travel", difficulty: 1, exampleSentence: "这个旅馆很便宜。", examplePinyin: "Zhège lǚguǎn hěn piányi.", exampleTranslation: "This inn is very cheap."),
            Flashcard(chinese: "房间", pinyin: "fángjiān", english: "Room", french: "Chambre", pronunciation: "fahng-jee-en", category: "Travel", difficulty: 1, exampleSentence: "我要一个房间。", examplePinyin: "Wǒ yào yī gè fángjiān.", exampleTranslation: "I want a room."),
            Flashcard(chinese: "预订", pinyin: "yùdìng", english: "Reservation/Booking", french: "Réservation", pronunciation: "yoo-ding", category: "Travel", difficulty: 1, exampleSentence: "我要预订房间。", examplePinyin: "Wǒ yào yùdìng fángjiān.", exampleTranslation: "I want to book a room."),
            Flashcard(chinese: "机场", pinyin: "jīchǎng", english: "Airport", french: "Aéroport", pronunciation: "jee-chahng", category: "Travel", difficulty: 1, exampleSentence: "机场离市区很远。", examplePinyin: "Jīchǎng lí shìqū hěn yuǎn.", exampleTranslation: "The airport is far from the city center."),
            Flashcard(chinese: "火车站", pinyin: "huǒchēzhàn", english: "Train station", french: "Gare", pronunciation: "hwo-chuh-jan", category: "Travel", difficulty: 1, exampleSentence: "火车站在哪里？", examplePinyin: "Huǒchēzhàn zài nǎlǐ?", exampleTranslation: "Where is the train station?"),
            Flashcard(chinese: "地铁", pinyin: "dìtiě", english: "Subway/Metro", french: "Métro", pronunciation: "dee-tyeh", category: "Travel", difficulty: 1, exampleSentence: "我坐地铁去上班。", examplePinyin: "Wǒ zuò dìtiě qù shàngbān.", exampleTranslation: "I take the subway to work."),
            Flashcard(chinese: "公交车", pinyin: "gōngjiāochē", english: "Bus", french: "Bus", pronunciation: "gong-jyao-chuh", category: "Travel", difficulty: 1, exampleSentence: "公交车很拥挤。", examplePinyin: "Gōngjiāochē hěn yōngjǐ.", exampleTranslation: "The bus is very crowded."),
            Flashcard(chinese: "出租车", pinyin: "chūzūchē", english: "Taxi", french: "Taxi", pronunciation: "choo-dzoo-chuh", category: "Travel", difficulty: 1, exampleSentence: "请叫一辆出租车。", examplePinyin: "Qǐng jiào yī liàng chūzūchē.", exampleTranslation: "Please call a taxi."),
            Flashcard(chinese: "地图", pinyin: "dìtú", english: "Map", french: "Carte", pronunciation: "dee-too", category: "Travel", difficulty: 1, exampleSentence: "请给我一张地图。", examplePinyin: "Qǐng gěi wǒ yī zhāng dìtú.", exampleTranslation: "Please give me a map."),
            Flashcard(chinese: "导游", pinyin: "dǎoyóu", english: "Tour guide", french: "Guide touristique", pronunciation: "dao-yo", category: "Travel", difficulty: 1, exampleSentence: "我们的导游很专业。", examplePinyin: "Wǒmen de dǎoyóu hěn zhuānyè.", exampleTranslation: "Our tour guide is very professional."),
            Flashcard(chinese: "景点", pinyin: "jǐngdiǎn", english: "Tourist attraction", french: "Attraction touristique", pronunciation: "jing-dee-en", category: "Travel", difficulty: 1, exampleSentence: "这个景点很著名。", examplePinyin: "Zhège jǐngdiǎn hěn zhùmíng.", exampleTranslation: "This tourist attraction is very famous."),
            Flashcard(chinese: "博物馆", pinyin: "bówùguǎn", english: "Museum", french: "Musée", pronunciation: "bwo-woo-gwan", category: "Travel", difficulty: 1, exampleSentence: "我们去博物馆参观。", examplePinyin: "Wǒmen qù bówùguǎn cānguān.", exampleTranslation: "We're going to visit the museum."),
            Flashcard(chinese: "公园", pinyin: "gōngyuán", english: "Park", french: "Parc", pronunciation: "gong-ywen", category: "Travel", difficulty: 1, exampleSentence: "这个公园很漂亮。", examplePinyin: "Zhège gōngyuán hěn piàoliang.", exampleTranslation: "This park is very beautiful."),
            Flashcard(chinese: "广场", pinyin: "guǎngchǎng", english: "Square/Plaza", french: "Place", pronunciation: "gwahng-chahng", category: "Travel", difficulty: 1, exampleSentence: "天安门广场很大。", examplePinyin: "Tiān'ānmén guǎngchǎng hěn dà.", exampleTranslation: "Tiananmen Square is very large."),
            Flashcard(chinese: "寺庙", pinyin: "sìmiào", english: "Temple", french: "Temple", pronunciation: "suh-mee-ow", category: "Travel", difficulty: 1, exampleSentence: "这个寺庙很古老。", examplePinyin: "Zhège sìmiào hěn gǔlǎo.", exampleTranslation: "This temple is very ancient."),
            Flashcard(chinese: "教堂", pinyin: "jiàotáng", english: "Church", french: "Église", pronunciation: "jyao-tahng", category: "Travel", difficulty: 1, exampleSentence: "这个教堂很宏伟。", examplePinyin: "Zhège jiàotáng hěn hóngwěi.", exampleTranslation: "This church is very magnificent."),
            Flashcard(chinese: "购物中心", pinyin: "gòuwù zhōngxīn", english: "Shopping center/Mall", french: "Centre commercial", pronunciation: "go-woo jong-sheen", category: "Travel", difficulty: 1, exampleSentence: "购物中心人很多。", examplePinyin: "Gòuwù zhōngxīn rén hěn duō.", exampleTranslation: "There are many people in the shopping center."),
            Flashcard(chinese: "餐厅", pinyin: "cāntīng", english: "Restaurant", french: "Restaurant", pronunciation: "tsan-ting", category: "Travel", difficulty: 1, exampleSentence: "这个餐厅很好吃。", examplePinyin: "Zhège cāntīng hěn hǎochī.", exampleTranslation: "This restaurant is very delicious."),
            Flashcard(chinese: "咖啡厅", pinyin: "kāfēitīng", english: "Café", french: "Café", pronunciation: "kah-fay-ting", category: "Travel", difficulty: 1, exampleSentence: "我们去咖啡厅坐坐。", examplePinyin: "Wǒmen qù kāfēitīng zuòzuo.", exampleTranslation: "Let's sit in the café."),
            Flashcard(chinese: "银行", pinyin: "yínháng", english: "Bank", french: "Banque", pronunciation: "yin-hahng", category: "Travel", difficulty: 1, exampleSentence: "银行在哪里？", examplePinyin: "Yínháng zài nǎlǐ?", exampleTranslation: "Where is the bank?"),
            Flashcard(chinese: "邮局", pinyin: "yóujú", english: "Post office", french: "Bureau de poste", pronunciation: "yo-jyoo", category: "Travel", difficulty: 1, exampleSentence: "我要去邮局寄信。", examplePinyin: "Wǒ yào qù yóujú jì xìn.", exampleTranslation: "I need to go to the post office to mail a letter."),
            Flashcard(chinese: "医院", pinyin: "yīyuàn", english: "Hospital", french: "Hôpital", pronunciation: "ee-ywen", category: "Travel", difficulty: 1, exampleSentence: "最近的医院在哪里？", examplePinyin: "Zuìjìn de yīyuàn zài nǎlǐ?", exampleTranslation: "Where is the nearest hospital?"),
            Flashcard(chinese: "药店", pinyin: "yàodiàn", english: "Pharmacy", french: "Pharmacie", pronunciation: "yao-dee-en", category: "Travel", difficulty: 1, exampleSentence: "我要去药店买药。", examplePinyin: "Wǒ yào qù yàodiàn mǎi yào.", exampleTranslation: "I need to go to the pharmacy to buy medicine."),
            Flashcard(chinese: "警察局", pinyin: "jǐngchájú", english: "Police station", french: "Commissariat", pronunciation: "jing-chah-jyoo", category: "Travel", difficulty: 1, exampleSentence: "警察局在市中心。", examplePinyin: "Jǐngchájú zài shì zhōngxīn.", exampleTranslation: "The police station is in the city center."),
            Flashcard(chinese: "大使馆", pinyin: "dàshǐguǎn", english: "Embassy", french: "Ambassade", pronunciation: "dah-shir-gwan", category: "Travel", difficulty: 1, exampleSentence: "美国大使馆在哪里？", examplePinyin: "Měiguó dàshǐguǎn zài nǎlǐ?", exampleTranslation: "Where is the US embassy?"),
            Flashcard(chinese: "领事馆", pinyin: "lǐngshìguǎn", english: "Consulate", french: "Consulat", pronunciation: "ling-shir-gwan", category: "Travel", difficulty: 1, exampleSentence: "我要去领事馆办签证。", examplePinyin: "Wǒ yào qù lǐngshìguǎn bàn qiānzhèng.", exampleTranslation: "I need to go to the consulate to apply for a visa."),
            Flashcard(chinese: "行李", pinyin: "xíngli", english: "Luggage", french: "Bagages", pronunciation: "shing-lee", category: "Travel", difficulty: 1, exampleSentence: "我的行李很重。", examplePinyin: "Wǒ de xíngli hěn zhòng.", exampleTranslation: "My luggage is very heavy."),
            Flashcard(chinese: "行李箱", pinyin: "xínglixiāng", english: "Suitcase", french: "Valise", pronunciation: "shing-lee-shyahng", category: "Travel", difficulty: 1, exampleSentence: "我的行李箱坏了。", examplePinyin: "Wǒ de xínglixiāng huài le.", exampleTranslation: "My suitcase is broken."),
            Flashcard(chinese: "背包", pinyin: "bēibāo", english: "Backpack", french: "Sac à dos", pronunciation: "bay-bow", category: "Travel", difficulty: 1, exampleSentence: "我的背包很轻。", examplePinyin: "Wǒ de bēibāo hěn qīng.", exampleTranslation: "My backpack is very light."),
            Flashcard(chinese: "相机", pinyin: "xiàngjī", english: "Camera", french: "Appareil photo", pronunciation: "shyahng-jee", category: "Travel", difficulty: 1, exampleSentence: "我用相机拍照。", examplePinyin: "Wǒ yòng xiàngjī pāizhào.", exampleTranslation: "I take photos with my camera."),
            Flashcard(chinese: "充电器", pinyin: "chōngdiànqì", english: "Charger", french: "Chargeur", pronunciation: "chong-dee-en-chee", category: "Travel", difficulty: 1, exampleSentence: "我的充电器忘带了。", examplePinyin: "Wǒ de chōngdiànqì wàng dài le.", exampleTranslation: "I forgot to bring my charger."),
            Flashcard(chinese: "钱包", pinyin: "qiánbāo", english: "Wallet", french: "Portefeuille", pronunciation: "chee-en-bow", category: "Travel", difficulty: 1, exampleSentence: "我的钱包丢了。", examplePinyin: "Wǒ de qiánbāo diū le.", exampleTranslation: "I lost my wallet."),
            Flashcard(chinese: "信用卡", pinyin: "xìnyòngkǎ", english: "Credit card", french: "Carte de crédit", pronunciation: "sheen-yong-kah", category: "Travel", difficulty: 1, exampleSentence: "我用信用卡付款。", examplePinyin: "Wǒ yòng xìnyòngkǎ fùkuǎn.", exampleTranslation: "I pay with my credit card."),
            Flashcard(chinese: "现金", pinyin: "xiànjīn", english: "Cash", french: "Espèces", pronunciation: "sheen-jin", category: "Travel", difficulty: 1, exampleSentence: "我没有现金。", examplePinyin: "Wǒ méiyǒu xiànjīn.", exampleTranslation: "I don't have cash."),
            Flashcard(chinese: "兑换", pinyin: "duìhuàn", english: "Exchange", french: "Échanger", pronunciation: "dway-hwan", category: "Travel", difficulty: 1, exampleSentence: "我要兑换货币。", examplePinyin: "Wǒ yào duìhuàn huòbì.", exampleTranslation: "I need to exchange currency."),
            Flashcard(chinese: "汇率", pinyin: "huìlǜ", english: "Exchange rate", french: "Taux de change", pronunciation: "hway-lyoo", category: "Travel", difficulty: 1, exampleSentence: "今天的汇率是多少？", examplePinyin: "Jīntiān de huìlǜ shì duōshao?", exampleTranslation: "What's today's exchange rate?"),
            Flashcard(chinese: "时差", pinyin: "shíchā", english: "Time difference", french: "Décalage horaire", pronunciation: "shir-chah", category: "Travel", difficulty: 1, exampleSentence: "中国和法国的时差是六小时。", examplePinyin: "Zhōngguó hé Fǎguó de shíchā shì liù xiǎoshí.", exampleTranslation: "The time difference between China and France is six hours."),
            Flashcard(chinese: "时区", pinyin: "shíqū", english: "Time zone", french: "Fuseau horaire", pronunciation: "shir-chyoo", category: "Travel", difficulty: 1, exampleSentence: "北京在东八时区。", examplePinyin: "Běijīng zài dōng bā shíqū.", exampleTranslation: "Beijing is in the UTC+8 time zone."),
            Flashcard(chinese: "天气", pinyin: "tiānqì", english: "Weather", french: "Météo", pronunciation: "tee-en-chee", category: "Travel", difficulty: 1, exampleSentence: "今天天气很好。", examplePinyin: "Jīntiān tiānqì hěn hǎo.", exampleTranslation: "The weather is nice today."),
            Flashcard(chinese: "温度", pinyin: "wēndù", english: "Temperature", french: "Température", pronunciation: "wun-doo", category: "Travel", difficulty: 1, exampleSentence: "今天的温度是25度。", examplePinyin: "Jīntiān de wēndù shì èrshíwǔ dù.", exampleTranslation: "Today's temperature is 25 degrees."),
            Flashcard(chinese: "下雨", pinyin: "xiàyǔ", english: "Rain", french: "Pluie", pronunciation: "shyah-yoo", category: "Travel", difficulty: 1, exampleSentence: "今天下雨了。", examplePinyin: "Jīntiān xiàyǔ le.", exampleTranslation: "It's raining today."),
            Flashcard(chinese: "下雪", pinyin: "xiàxuě", english: "Snow", french: "Neige", pronunciation: "shyah-shway", category: "Travel", difficulty: 1, exampleSentence: "冬天经常下雪。", examplePinyin: "Dōngtiān jīngcháng xiàxuě.", exampleTranslation: "It often snows in winter."),
            Flashcard(chinese: "晴天", pinyin: "qíngtiān", english: "Sunny", french: "Ensoleillé", pronunciation: "ching-tee-en", category: "Travel", difficulty: 1, exampleSentence: "今天是晴天。", examplePinyin: "Jīntiān shì qíngtiān.", exampleTranslation: "Today is sunny."),
            Flashcard(chinese: "阴天", pinyin: "yīntiān", english: "Cloudy", french: "Nuageux", pronunciation: "yin-tee-en", category: "Travel", difficulty: 1, exampleSentence: "今天是阴天。", examplePinyin: "Jīntiān shì yīntiān.", exampleTranslation: "Today is cloudy."),
            Flashcard(chinese: "热", pinyin: "rè", english: "Hot", french: "Chaud", pronunciation: "ruh", category: "Travel", difficulty: 1, exampleSentence: "夏天很热。", examplePinyin: "Xiàtiān hěn rè.", exampleTranslation: "Summer is very hot."),
            Flashcard(chinese: "冷", pinyin: "lěng", english: "Cold", french: "Froid", pronunciation: "lung", category: "Travel", difficulty: 1, exampleSentence: "冬天很冷。", examplePinyin: "Dōngtiān hěn lěng.", exampleTranslation: "Winter is very cold."),
            Flashcard(chinese: "温暖", pinyin: "wēnnuǎn", english: "Warm", french: "Chaud", pronunciation: "wun-nwan", category: "Travel", difficulty: 1, exampleSentence: "春天很温暖。", examplePinyin: "Chūntiān hěn wēnnuǎn.", exampleTranslation: "Spring is very warm."),
            Flashcard(chinese: "凉爽", pinyin: "liángshuǎng", english: "Cool", french: "Fraîche", pronunciation: "lyahng-shwahng", category: "Travel", difficulty: 1, exampleSentence: "秋天很凉爽。", examplePinyin: "Qiūtiān hěn liángshuǎng.", exampleTranslation: "Autumn is very cool."),

            // Social Media Slang (unchanged)
            Flashcard(chinese: "绝绝子", pinyin: "juéjuézi", english: "Absolutely amazing/terrible", french: "Absolument génial/terrible (selon le contexte)", pronunciation: "jweh-jweh-dzuh", category: "Social Media Slang", difficulty: 3, exampleSentence: "这部电影真是绝绝子！", examplePinyin: "Zhè bù diànyǐng zhēnshi juéjuézi!", exampleTranslation: "This movie is absolutely amazing!"),
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
            
            Flashcard(chinese: "有困难", pinyin: "yǒu kùnnán", english: "To struggle", french: "Avoir de la misère", pronunciation: "yo coon-nan", category: "Quebecois", difficulty: 2, exampleSentence: "我在学法语时有点困难。", examplePinyin: "Wǒ zài xué fǎyǔ shí yǒudiǎn kùnnán.", exampleTranslation: "I'm having some trouble learning French. / J'ai de la misère à apprendre le français."),
            Flashcard(chinese: "疯了", pinyin: "fēngle", english: "Crazy/Nuts", french: "Capote", pronunciation: "fung-luh", category: "Quebecois", difficulty: 2, exampleSentence: "他对这部电影疯了。", examplePinyin: "Tā duì zhè bù diànyǐng fēngle.", exampleTranslation: "He's crazy about this movie. / Y capote sur ce film-là."),
            Flashcard(chinese: "很棒", pinyin: "hěn bàng", english: "Awesome", french: "Sur la coche", pronunciation: "hen-bahng", category: "Quebecois", difficulty: 2, exampleSentence: "这个演出真的很棒！", examplePinyin: "Zhège yǎnchū zhēn de hěn bàng!", exampleTranslation: "The show was really awesome! / Le spectacle était vraiment sur la coche !"),

            Flashcard(chinese: "受够了", pinyin: "shòu gòu le", english: "Fed up", french: "Être tanné", pronunciation: "shoh-go-luh", category: "Quebecois", difficulty: 2, exampleSentence: "我受够这份工作了。", examplePinyin: "Wǒ shòu gòu zhè fèn gōngzuò le.", exampleTranslation: "I'm fed up with this job. / J'suis tanné de cette job-là."),

            Flashcard(chinese: "没问题", pinyin: "méi wèntí", english: "No problem", french: "Tiguidou", pronunciation: "may-wen-tee", category: "Quebecois", difficulty: 2, exampleSentence: "明天见，没问题！", examplePinyin: "Míngtiān jiàn, méi wèntí!", exampleTranslation: "See you tomorrow, no problem! / À demain, tiguidou !"),

            Flashcard(chinese: "慢慢来", pinyin: "màn màn lái", english: "Take it slow", french: "Tranquillement pas vite", pronunciation: "man-man-lie", category: "Quebecois", difficulty: 2, exampleSentence: "我们慢慢来就好。", examplePinyin: "Wǒmen màn màn lái jiù hǎo.", exampleTranslation: "Let's just take it slow. / On y va tranquillement pas vite."),

          

            Flashcard(chinese: "你懂吗？", pinyin: "nǐ dǒng ma?", english: "You know what I mean?", french: "Tsé veux dire", pronunciation: "nee-dong-ma", category: "Quebecois", difficulty: 2, exampleSentence: "这个有点奇怪，你懂吗？", examplePinyin: "Zhège yǒudiǎn qíguài, nǐ dǒng ma?", exampleTranslation: "It's kind of weird, you know? / C'est un peu bizarre, tsé veux dire."),

          

          

            Flashcard(chinese: "精疲力尽", pinyin: "jīng pí lì jìn", english: "Exhausted", french: "Avoir le trou du cul en d'sous du bras", pronunciation: "jing pee lee jin", category: "Quebecois", difficulty: 4, exampleSentence: "我搬家之后精疲力尽了。", examplePinyin: "Wǒ bānjiā zhīhòu jīng pí lì jìn le.", exampleTranslation: "I'm exhausted after moving. / Après le déménagement, j'avais le trou du cul en d'sous du bras."),

            Flashcard(chinese: "疲倦虚脱", pinyin: "pí juàn xū tuō", english: "Drained", french: "Avoir les yeux dans la graisse de binnes", pronunciation: "pee jwen shü tuo", category: "Quebecois", difficulty: 3, exampleSentence: "昨晚喝多后我很疲倦虚脱。", examplePinyin: "Zuówǎn hē duō hòu wǒ hěn píjuàn xūtuō.", exampleTranslation: "I was wiped out after drinking last night. / J'avais les yeux dans la graisse de binnes après avoir trop bu."),

            Flashcard(chinese: "打瞌睡", pinyin: "dǎ kēshuì", english: "Doze off", french: "Cogner des clous", pronunciation: "da kuh-shway", category: "Quebecois", difficulty: 2, exampleSentence: "会议中我忍不住打瞌睡。", examplePinyin: "Huìyì zhōng wǒ rěn bù zhù dǎ kēshuì.", exampleTranslation: "I couldn't help dozing off during the meeting. / J'cognais des clous pendant la réunion."),

            Flashcard(chinese: "吓坏了", pinyin: "xià huài le", english: "Freaked out", french: "Virer capot", pronunciation: "shyah hway luh", category: "Quebecois", difficulty: 3, exampleSentence: "考试结果让我吓坏了。", examplePinyin: "Kǎoshì jiéguǒ ràng wǒ xià huài le.", exampleTranslation: "I freaked out when I saw my test results. / J'ai viré capot quand j'ai vu mes résultats."),

            Flashcard(chinese: "放弃", pinyin: "fàngqì", english: "Give up", french: "Lâche pas la patate", pronunciation: "fang-chee", category: "Quebecois", difficulty: 2, exampleSentence: "你快跑完了，别放弃！", examplePinyin: "Nǐ kuài pǎowán le, bié fàngqì!", exampleTranslation: "You're almost done, don't give up! / T'es proche, lâche pas la patate !"),

            Flashcard(chinese: "勇敢", pinyin: "yǒnggǎn", english: "Brave", french: "Avoir du front tout le tour de la tête", pronunciation: "yong-gan", category: "Quebecois", difficulty: 3, exampleSentence: "她这么说真勇敢。", examplePinyin: "Tā zhème shuō zhēn yǒnggǎn.", exampleTranslation: "She's really brave to say that. / Faut avoir du front tout le tour de la tête pour dire ça."),

            Flashcard(chinese: "怕死", pinyin: "pà sǐ", english: "Scared stiff", french: "Avoir la chienne", pronunciation: "pah suh", category: "Quebecois", difficulty: 2, exampleSentence: "他打雷时怕死了。", examplePinyin: "Tā dǎ léi shí pà sǐ le.", exampleTranslation: "He was scared stiff during the thunderstorm. / Il avait la chienne pendant l'orage."),

            Flashcard(chinese: "没退路", pinyin: "méi tuìlù", english: "No way out", french: "Pas sorti du bois", pronunciation: "may tway-loo", category: "Quebecois", difficulty: 3, exampleSentence: "项目失败后，我们没退路了。", examplePinyin: "Xiàngmù shībài hòu, wǒmen méi tuìlù le.", exampleTranslation: "After the project failed, there was no way out. / Après l'échec, on était pas sortis du bois."),

            Flashcard(chinese: "人多", pinyin: "rén duō", english: "Packed (crowded)", french: "Y'a gros de monde icitte", pronunciation: "ren dwo", category: "Quebecois", difficulty: 2, exampleSentence: "节日市场人特别多。", examplePinyin: "Jiérì shìchǎng rén tèbié duō.", exampleTranslation: "The holiday market was packed. / Y'avait gros de monde icitte au marché de Noël."),

            Flashcard(chinese: "处理", pinyin: "chǔ lǐ", english: "Deal with", french: "Dealer avec une situation", pronunciation: "choo lee", category: "Quebecois", difficulty: 2, exampleSentence: "我不知道怎么处理这个问题。", examplePinyin: "Wǒ bù zhīdào zěnme chǔlǐ zhège wèntí.", exampleTranslation: "I don't know how to deal with this problem. / Je sais pas comment dealer avec cette situation."),

            Flashcard(chinese: "累", pinyin: "lèi", english: "Tired", french: "Être brûlé", pronunciation: "lay", category: "Quebecois", difficulty: 1, exampleSentence: "我今天真的很累。", examplePinyin: "Wǒ jīntiān zhēn de hěn lèi.", exampleTranslation: "I'm really tired today. / Je suis brûlé aujourd'hui."),

            Flashcard(chinese: "冒险", pinyin: "mào xiǎn", english: "Take a risk", french: "Prendre une chance", pronunciation: "mao shyen", category: "Quebecois", difficulty: 2, exampleSentence: "有时候你得冒险。", examplePinyin: "Yǒu shíhou nǐ děi màoxiǎn.", exampleTranslation: "Sometimes you have to take a risk. / Des fois faut prendre une chance."),

            Flashcard(chinese: "散步", pinyin: "sàn bù", english: "Take a walk", french: "Prendre une marche", pronunciation: "san boo", category: "Quebecois", difficulty: 1, exampleSentence: "我们去散步吧。", examplePinyin: "Wǒmen qù sànbù ba.", exampleTranslation: "Let's go for a walk. / On va prendre une marche."),

            Flashcard(chinese: "玩得开心", pinyin: "wán de kāi xīn", english: "Have fun", french: "Avoir du fun", pronunciation: "wahn duh kai sheen", category: "Quebecois", difficulty: 1, exampleSentence: "祝你玩得开心！", examplePinyin: "Zhù nǐ wán de kāixīn!", exampleTranslation: "Have fun! / Amuse-toi, aie du fun!"),

            Flashcard(chinese: "无聊", pinyin: "wú liáo", english: "Boring", french: "C'est plate", pronunciation: "woo lyaow", category: "Quebecois", difficulty: 1, exampleSentence: "这部电影太无聊了。", examplePinyin: "Zhè bù diànyǐng tài wúliáo le.", exampleTranslation: "This movie is too boring. / Ce film-là est plate."),

            Flashcard(chinese: "锁门", pinyin: "suǒ mén", english: "Lock the door", french: "Barrer une porte", pronunciation: "swaw men", category: "Quebecois", difficulty: 1, exampleSentence: "请你锁门好吗？", examplePinyin: "Qǐng nǐ suǒmén hǎo ma?", exampleTranslation: "Can you lock the door? / Peux-tu barrer la porte?"),
            Flashcard(chinese: "零用钱", pinyin: "líng yòng qián", english: "Spare change", french: "Du change", pronunciation: "ling yong chyen", category: "Quebecois", difficulty: 2, exampleSentence: "你有一点零用钱吗？", examplePinyin: "Nǐ yǒu yīdiǎn líng yòng qián ma?", exampleTranslation: "Do you have some spare change? / T'as du change?"),

            Flashcard(chinese: "昂贵", pinyin: "áng guì", english: "Expensive", french: "Dispendieux", pronunciation: "ahng gway", category: "Quebecois", difficulty: 2, exampleSentence: "这个包太昂贵了。", examplePinyin: "Zhège bāo tài áng guì le.", exampleTranslation: "This bag is too expensive. / Ce sac est trop dispendieux."),

            Flashcard(chinese: "付现金", pinyin: "fù xiàn jīn", english: "Pay in cash", french: "Payer cash", pronunciation: "foo shyen jeen", category: "Quebecois", difficulty: 2, exampleSentence: "我可以付现金吗？", examplePinyin: "Wǒ kěyǐ fù xiàn jīn ma?", exampleTranslation: "Can I pay in cash? / Je peux payer cash?"),

            Flashcard(chinese: "睾丸", pinyin: "gāo wán", english: "Testicles", french: "Gosses", pronunciation: "gaow wahn", category: "Quebecois", difficulty: 3, exampleSentence: "他受伤了，尤其是睾丸。", examplePinyin: "Tā shòushāng le, yóuqí shì gāo wán.", exampleTranslation: "He got hurt, especially in the testicles. / Il s'est blessé, surtout aux gosses."),

            Flashcard(chinese: "洋娃娃", pinyin: "yáng wá wa", english: "Doll", french: "Catin", pronunciation: "yang wah wah", category: "Quebecois", difficulty: 1, exampleSentence: "她有很多洋娃娃。", examplePinyin: "Tā yǒu hěn duō yáng wá wa.", exampleTranslation: "She has a lot of dolls. / Elle a plein de catins."),

            Flashcard(chinese: "不可思议", pinyin: "bù kě sī yì", english: "Amazing", french: "Écœurant", pronunciation: "boo kuh srr yee", category: "Quebecois", difficulty: 2, exampleSentence: "这表演真是不可思议！", examplePinyin: "Zhè biǎoyǎn zhēn shì bù kě sī yì!", exampleTranslation: "This performance is amazing! / Ce spectacle est écœurant!"),

            Flashcard(chinese: "善良", pinyin: "shàn liáng", english: "Kind", french: "Fin", pronunciation: "shan lyang", category: "Quebecois", difficulty: 1, exampleSentence: "他是个很善良的人。", examplePinyin: "Tā shì ge hěn shàn liáng de rén.", exampleTranslation: "He's a very kind person. / C'est quelqu'un de très fin."),

            Flashcard(chinese: "当然", pinyin: "dāng rán", english: "Of course", french: "Mets-en", pronunciation: "dahng rahn", category: "Quebecois", difficulty: 1, exampleSentence: "你喜欢巧克力吗？当然！", examplePinyin: "Nǐ xǐhuan qiǎokèlì ma? Dāngrán!", exampleTranslation: "Do you like chocolate? Of course! / T'aimes le chocolat? Mets-en!"),

            Flashcard(chinese: "一点也不", pinyin: "yī diǎn yě bù", english: "Not at all", french: "Pantoute", pronunciation: "yee dyan yeh boo", category: "Quebecois", difficulty: 2, exampleSentence: "我一点也不喜欢这个。", examplePinyin: "Wǒ yīdiǎn yě bù xǐhuan zhège.", exampleTranslation: "I don't like it at all. / J'aime pas ça pantoute."),

            Flashcard(chinese: "检查", pinyin: "jiǎn chá", english: "Check", french: "Checker", pronunciation: "jyen chah", category: "Quebecois", difficulty: 1, exampleSentence: "请你检查一下这份文件。", examplePinyin: "Qǐng nǐ jiǎnchá yīxià zhè fèn wénjiàn.", exampleTranslation: "Please check this document. / Peux-tu checker ce document?"),
            Flashcard(chinese: "走路", pinyin: "zǒu lù", english: "Take a walk", french: "Prendre une marche", pronunciation: "dzoh-loo", category: "Quebecois", difficulty: 2, exampleSentence: "我们去外面走路吧。", examplePinyin: "Wǒmen qù wàimiàn zǒulù ba.", exampleTranslation: "Let's go take a walk. / On va prendre une marche."),
            Flashcard(chinese: "好玩", pinyin: "hǎo wán", english: "Fun", french: "Avoir du fun", pronunciation: "how-wahn", category: "Quebecois", difficulty: 2, exampleSentence: "这场派对很好玩！", examplePinyin: "Zhè chǎng pàiduì hěn hǎowán!", exampleTranslation: "This party is fun! / Ce party est full fun !"),
            Flashcard(chinese: "无聊", pinyin: "wú liáo", english: "Boring", french: "C'est plate", pronunciation: "woo-lee-ow", category: "Quebecois", difficulty: 2, exampleSentence: "这堂课好无聊。", examplePinyin: "Zhè táng kè hǎo wúliáo.", exampleTranslation: "This class is so boring. / Ce cours est tellement plate."),
            Flashcard(chinese: "受够了", pinyin: "shòu gòu le", english: "Fed up", french: "Être tanné", pronunciation: "shoh-go-luh", category: "Quebecois", difficulty: 2, exampleSentence: "我真的受够了！", examplePinyin: "Wǒ zhēn de shòugòule!", exampleTranslation: "I'm really fed up! / J'suis ben tanné !"),
            Flashcard(chinese: "锁门", pinyin: "suǒ mén", english: "Lock the door", french: "Barrer une porte", pronunciation: "swaw-muhn", category: "Quebecois", difficulty: 2, exampleSentence: "你出门时记得锁门。", examplePinyin: "Nǐ chūmén shí jìde suǒmén.", exampleTranslation: "Remember to lock the door when you leave. / N'oublie pas de barrer la porte."),
            Flashcard(chinese: "你好", pinyin: "nǐ hǎo", english: "Hello", french: "Allo", pronunciation: "nee-how", category: "Quebecois", difficulty: 1, exampleSentence: "你好！你今天怎么样？", examplePinyin: "Nǐ hǎo! Nǐ jīntiān zěnme yàng?", exampleTranslation: "Hello! How are you today? / Allo ! Comment ça va aujourd'hui ?"),

            Flashcard(chinese: "早上好", pinyin: "zǎoshang hǎo", english: "Good morning", french: "Bon matin", pronunciation: "dzaow-shang haow", category: "Quebecois", difficulty: 1, exampleSentence: "早上好！你吃早餐了吗？", examplePinyin: "Zǎoshang hǎo! Nǐ chī zǎocān le ma?", exampleTranslation: "Good morning! Did you have breakfast? / Bon matin ! As-tu déjeuné ?"),

            Flashcard(chinese: "不用谢", pinyin: "bù yòng xiè", english: "You're welcome", french: "Bienvenue", pronunciation: "boo yohng shyeh", category: "Quebecois", difficulty: 2, exampleSentence: "谢谢你！不用谢。", examplePinyin: "Xièxie nǐ! Bù yòng xiè.", exampleTranslation: "Thank you! You're welcome. / Merci ! Bienvenue."),

            Flashcard(chinese: "没事", pinyin: "méi shì", english: "It's fine", french: "Correct", pronunciation: "mei shir", category: "Quebecois", difficulty: 1, exampleSentence: "你迟到了？没事。", examplePinyin: "Nǐ chídào le? Méi shì.", exampleTranslation: "You're late? It's fine. / T'es en retard ? C'est correct."),

            Flashcard(chinese: "周末", pinyin: "zhōumò", english: "Weekend", french: "Fin de semaine", pronunciation: "joe-moh", category: "Quebecois", difficulty: 1, exampleSentence: "这个周末你有空吗？", examplePinyin: "Zhège zhōumò nǐ yǒu kòng ma?", exampleTranslation: "Are you free this weekend? / As-tu du temps cette fin de semaine ?"),

            Flashcard(chinese: "待会儿见", pinyin: "dāihuǐr jiàn", english: "See you later", french: "À tantôt", pronunciation: "dai-hwair jyen", category: "Quebecois", difficulty: 1, exampleSentence: "我得走了，待会儿见！", examplePinyin: "Wǒ děi zǒu le, dāihuǐr jiàn!", exampleTranslation: "I have to go, see you later! / Je dois partir, à tantôt !"),

            Flashcard(chinese: "这里", pinyin: "zhèlǐ", english: "Here", french: "Icitte", pronunciation: "juh-lee", category: "Quebecois", difficulty: 2, exampleSentence: "把书放在这里。", examplePinyin: "Bǎ shū fàng zài zhèlǐ.", exampleTranslation: "Put the book here. / Mets le livre icitte."),

            Flashcard(chinese: "所以", pinyin: "suǒyǐ", english: "So / therefore", french: "Faque", pronunciation: "swaw-yee", category: "Quebecois", difficulty: 2, exampleSentence: "下雨了，所以我们不去了。", examplePinyin: "Xià yǔ le, suǒyǐ wǒmen bú qù le.", exampleTranslation: "It's raining, so we're not going. / Il pleut, faque on n'y va pas."),

            Flashcard(chinese: "到现在", pinyin: "dào xiànzài", english: "Until now", french: "À date", pronunciation: "daow syen-dzai", category: "Quebecois", difficulty: 2, exampleSentence: "到现在都很顺利。", examplePinyin: "Dào xiànzài dōu hěn shùnlì.", exampleTranslation: "Everything has gone well so far. / À date, tout va bien."),

            Flashcard(chinese: "早餐", pinyin: "zǎocān", english: "Breakfast", french: "Déjeuner", pronunciation: "dzaow-tsan", category: "Quebecois", difficulty: 1, exampleSentence: "我每天都吃早餐。", examplePinyin: "Wǒ měitiān dōu chī zǎocān.", exampleTranslation: "I eat breakfast every day. / Je prends mon déjeuner chaque jour."),


            Flashcard(chinese: "开车兜风", pinyin: "kāi chē dōu fēng", english: "Go for a drive", french: "Faire du char", pronunciation: "kai chuh doh feng", category: "Quebecois", difficulty: 2, exampleSentence: "我们周日开车兜风吧。", examplePinyin: "Wǒmen zhōurì kāichē dōu fēng ba.", exampleTranslation: "Let's go for a drive Sunday. / On va faire du char dimanche."),

            Flashcard(chinese: "购物", pinyin: "gòuwù", english: "Do shopping", french: "Magasiner", pronunciation: "go-woo", category: "Quebecois", difficulty: 1, exampleSentence: "我喜欢周末购物。", examplePinyin: "Wǒ xǐhuān zhōumò gòuwù.", exampleTranslation: "I like to go shopping on the weekend. / J'aime magasiner le weekend."),

            Flashcard(chinese: "该死", pinyin: "gāi sǐ", english: "Damn it!/Holy shit!", french: "Tabarnak", pronunciation: "gai-ssuh", category: "Quebecois", difficulty: 3, exampleSentence: "该死，我忘记带钥匙了！", examplePinyin: "Gāi sǐ, wǒ wàngjì dài yàoshi le!", exampleTranslation: "Damn it, I forgot my keys! / Tabarnak, j'ai oublié mes clés !"),
            Flashcard(chinese: "妈的", pinyin: "mā de", english: "Damn it!/Fuck!", french: "Câlisse", pronunciation: "ma-duh", category: "Quebecois", difficulty: 3, exampleSentence: "妈的，天气真冷！", examplePinyin: "Mā de, tiānqì zhēn lěng!", exampleTranslation: "Damn it, it's really cold! / Câlisse, y fait frette !"),
       
          
            Flashcard(chinese: "我的男朋友", pinyin: "wǒ de nán péng yǒu", english: "My boyfriend/guy friend", french: "Mon chum", pronunciation: "woh-duh nan-pung-yo", category: "Quebecois", difficulty: 2, exampleSentence: "我的男朋友来接我了。", examplePinyin: "Wǒ de nán péng yǒu lái jiē wǒ le.", exampleTranslation: "My boyfriend came to pick me up. / Mon chum est venu me chercher."),
            Flashcard(chinese: "我的女朋友", pinyin: "wǒ de nǚ péng yǒu", english: "My girlfriend", french: "Ma blonde", pronunciation: "woh-duh nyoo-pung-yo", category: "Quebecois", difficulty: 2, exampleSentence: "我的女朋友做饭很好吃。", examplePinyin: "Wǒ de nǚ péng yǒu zuò fàn hěn hǎochī.", exampleTranslation: "My girlfriend cooks very well. / Ma blonde cuisine très bien."),
         
            Flashcard(chinese: "抓住", pinyin: "zhuāzhù", english: "To catch/get/understand", french: "Pogner", pronunciation: "jwa-joo", category: "Quebecois", difficulty: 2, exampleSentence: "我不明白你的意思。", examplePinyin: "Wǒ bù míngbai nǐ de yìsi.", exampleTranslation: "I don't understand what you mean. / J'pogne pas c'que tu veux dire."),
            Flashcard(chinese: "购物", pinyin: "gòuwù", english: "To go shopping", french: "Magasiner", pronunciation: "go-woo", category: "Quebecois", difficulty: 2, exampleSentence: "我们明天去购物。", examplePinyin: "Wǒmen míngtiān qù gòuwù.", exampleTranslation: "We're going shopping tomorrow. / On va magasiner demain."),
            Flashcard(chinese: "停车", pinyin: "tíngchē", english: "To park", french: "Parker", pronunciation: "ting-chuh", category: "Quebecois", difficulty: 2, exampleSentence: "我要在这里停车。", examplePinyin: "Wǒ yào zài zhèlǐ tíngchē.", exampleTranslation: "I'm going to park my car here. / J'vas parker mon char icitte."),
            Flashcard(chinese: "取消", pinyin: "qǔxiāo", english: "To cancel", french: "Canceller", pronunciation: "chew-shyow", category: "Quebecois", difficulty: 2, exampleSentence: "我们要取消会议。", examplePinyin: "Wǒmen yào qǔxiāo huìyì.", exampleTranslation: "We're going to cancel the meeting. / On va canceller la réunion."),
            Flashcard(chinese: "便利店", pinyin: "biànlìdiàn", english: "Convenience store", french: "Dépanneur", pronunciation: "bee-an-lee-dee-an", category: "Quebecois", difficulty: 2, exampleSentence: "我去便利店买牛奶。", examplePinyin: "Wǒ qù biànlìdiàn mǎi niúnǎi.", exampleTranslation: "I'm going to the convenience store to buy milk. / J'vas au dépanneur acheter du lait."),
            Flashcard(chinese: "车", pinyin: "chē", english: "Car", french: "Char", pronunciation: "chuh", category: "Quebecois", difficulty: 1, exampleSentence: "我的车坏了。", examplePinyin: "Wǒ de chē huài le.", exampleTranslation: "My car is broken. / Mon char est brisé."),
            
            Flashcard(chinese: "甜甜圈", pinyin: "tiántiánquān", english: "Donut", french: "Beigne", pronunciation: "tee-an-tee-an-chwan", category: "Quebecois", difficulty: 2, exampleSentence: "我想要一个巧克力甜甜圈。", examplePinyin: "Wǒ xiǎng yào yī gè qiǎokèlì tiántiánquān.", exampleTranslation: "I want a chocolate donut. / J'veux une beigne au chocolat."),
           
            Flashcard(chinese: "没关系", pinyin: "méiguānxi", english: "It's okay/That's fine", french: "C'est correct", pronunciation: "may-gwan-she", category: "Quebecois", difficulty: 2, exampleSentence: "没关系，没问题。", examplePinyin: "Méiguānxi, méi wèntí.", exampleTranslation: "It's okay, no problem. / C'est correct, pas de problème."),
            Flashcard(chinese: "不错", pinyin: "bùcuò", english: "Not bad/pretty good", french: "Pas pire", pronunciation: "boo-tswaw", category: "Quebecois", difficulty: 2, exampleSentence: "这部电影不错。", examplePinyin: "Zhè bù diànyǐng bùcuò.", exampleTranslation: "This movie wasn't bad. / Ce film-là était pas pire."),
            Flashcard(chinese: "很有趣", pinyin: "hěn yǒuqù", english: "It's fun/That's cool", french: "C'est le fun", pronunciation: "hen-yo-chew", category: "Quebecois", difficulty: 2, exampleSentence: "旅行很有趣。", examplePinyin: "Lǚxíng hěn yǒuqù.", exampleTranslation: "It's fun to travel. / C'est le fun de voyager."),
            Flashcard(chinese: "很无聊", pinyin: "hěn wúliáo", english: "It's boring/That sucks", french: "C'est plate", pronunciation: "hen-woo-lee-ow", category: "Quebecois", difficulty: 2, exampleSentence: "下雨很无聊。", examplePinyin: "Xiàyǔ hěn wúliáo.", exampleTranslation: "That sucks, it's raining. / C'est plate, y mouille."),
            Flashcard(chinese: "我想", pinyin: "wǒ xiǎng", english: "I feel like/I want to", french: "J'ai le goût", pronunciation: "woh-shyang", category: "Quebecois", difficulty: 2, exampleSentence: "我想吃薯条。", examplePinyin: "Wǒ xiǎng chī shǔtiáo.", exampleTranslation: "I feel like eating fries. / J'ai le goût de manger des frites."),
            Flashcard(chinese: "很烦人", pinyin: "hěn fánrén", english: "It's annoying/That's irritating", french: "C'est gossant", pronunciation: "hen-fan-ren", category: "Quebecois", difficulty: 3, exampleSentence: "他总是做同样的事，很烦人。", examplePinyin: "Tā zǒngshì zuò tóngyàng de shì, hěn fánrén.", exampleTranslation: "It's annoying, he always does the same thing. / C'est gossant, y fait toujours la même affaire."),
            Flashcard(chinese: "很好玩", pinyin: "hěn hǎowán", english: "It's fun/That's cool", french: "C'est l'fun", pronunciation: "hen-how-wan", category: "Quebecois", difficulty: 2, exampleSentence: "冬天滑雪很好玩。", examplePinyin: "Dōngtiān huáxuě hěn hǎowán.", exampleTranslation: "It's fun to ski in winter. / C'est l'fun de skier l'hiver."),
            Flashcard(chinese: "一会儿", pinyin: "yīhuǐr", english: "In a bit/Shortly", french: "Tantôt", pronunciation: "yee-hway-er", category: "Quebecois", difficulty: 2, exampleSentence: "我们一会儿见。", examplePinyin: "Wǒmen yīhuǐr jiàn.", exampleTranslation: "We'll see each other in a bit. / On se voit tantôt."),
            Flashcard(chinese: "今天早上", pinyin: "jīntiān zǎoshang", english: "This morning", french: "À matin", pronunciation: "jin-tee-an dzow-shahng", category: "Quebecois", difficulty: 2, exampleSentence: "我今天早上工作了。", examplePinyin: "Wǒ jīntiān zǎoshang gōngzuò le.", exampleTranslation: "I worked this morning. / J'ai travaillé à matin."),
            Flashcard(chinese: "今天下午", pinyin: "jīntiān xiàwǔ", english: "This afternoon", french: "À soir", pronunciation: "jin-tee-an shyah-woo", category: "Quebecois", difficulty: 2, exampleSentence: "我们今天下午见。", examplePinyin: "Wǒmen jīntiān xiàwǔ jiàn.", exampleTranslation: "We'll see each other this evening. / On se voit à soir."),
            Flashcard(chinese: "很冷", pinyin: "hěn lěng", english: "It's freezing/That's cold", french: "Il fait frette", pronunciation: "hen-lung", category: "Quebecois", difficulty: 2, exampleSentence: "外面很冷！", examplePinyin: "Wàimiàn hěn lěng!", exampleTranslation: "It's freezing outside! / Y fait frette dehors !"),
            Flashcard(chinese: "小雨", pinyin: "xiǎoyǔ", english: "Light rain/Drizzle", french: "Il mouille", pronunciation: "shyow-yoo", category: "Quebecois", difficulty: 2, exampleSentence: "外面在下小雨。", examplePinyin: "Wàimiàn zài xià xiǎoyǔ.", exampleTranslation: "It's drizzling outside. / Y mouille dehors."),
            Flashcard(chinese: "暴风雪", pinyin: "bàofēngxuě", english: "Snowstorm", french: "Poudrerie", pronunciation: "bow-fung-shway", category: "Quebecois", difficulty: 3, exampleSentence: "高速公路上有暴风雪。", examplePinyin: "Gāosù gōnglù shàng yǒu bàofēngxuě.", exampleTranslation: "There's blowing snow on the highway. / Y'a de la poudrerie sur l'autoroute."),
            Flashcard(chinese: "很可爱", pinyin: "hěn kě'ài", english: "It's cute/That's sweet", french: "C'est cute", pronunciation: "hen-kuh-eye", category: "Quebecois", difficulty: 1, exampleSentence: "你的狗很可爱！", examplePinyin: "Nǐ de gǒu hěn kě'ài!", exampleTranslation: "Your dog is cute! / Ton chien est cute !"),
           
            Flashcard(chinese: "很便宜", pinyin: "hěn piányi", english: "It's cheap/That's inexpensive", french: "C'est cheap", pronunciation: "hen-pee-an-yee", category: "Quebecois", difficulty: 2, exampleSentence: "这个餐厅很便宜。", examplePinyin: "Zhège cāntīng hěn piányi.", exampleTranslation: "This restaurant is cheap. / Ce restaurant-là est cheap."),
            Flashcard(chinese: "很奇怪", pinyin: "hěn qíguài", english: "It's weird/That's strange", french: "C'est weird", pronunciation: "hen-chee-gwai", category: "Quebecois", difficulty: 2, exampleSentence: "很奇怪，他从来不回答。", examplePinyin: "Hěn qíguài, tā cónglái bù huídá.", exampleTranslation: "It's weird, he never answers. / C'est weird, y répond jamais."),
            Flashcard(chinese: "很难", pinyin: "hěn nán", english: "It's tough/That's difficult", french: "C'est tough", pronunciation: "hen-nan", category: "Quebecois", difficulty: 2, exampleSentence: "学法语很难。", examplePinyin: "Xué Fǎyǔ hěn nán.", exampleTranslation: "It's tough to learn French. / C'est tough d'apprendre le français."),
            Flashcard(chinese: "很放松", pinyin: "hěn fàngsōng", english: "It's chill/That's relaxed", french: "C'est chill", pronunciation: "hen-fahng-song", category: "Quebecois", difficulty: 2, exampleSentence: "这里很放松，我们可以待着。", examplePinyin: "Zhèlǐ hěn fàngsōng, wǒmen kěyǐ dāi zhe.", exampleTranslation: "It's chill here, we can stay. / C'est chill icitte, on peut rester."),
            Flashcard(chinese: "鞋子", pinyin: "xiézi", english: "Shoes/Sneakers", french: "Souliers", pronunciation: "shyeh-dzuh", category: "Quebecois", difficulty: 2, exampleSentence: "我买了新鞋子。", examplePinyin: "Wǒ mǎi le xīn xiézi.", exampleTranslation: "I bought new shoes. / J'ai acheté des nouveaux souliers."),
            Flashcard(chinese: "袜子", pinyin: "wàzi", english: "Socks", french: "Bas", pronunciation: "wah-dzuh", category: "Quebecois", difficulty: 2, exampleSentence: "我的袜子湿了。", examplePinyin: "Wǒ de wàzi shī le.", exampleTranslation: "My socks are wet. / Mes bas sont mouillés."),
            Flashcard(chinese: "内衣", pinyin: "nèiyī", english: "Underwear", french: "Bobettes", pronunciation: "nay-yee", category: "Quebecois", difficulty: 2, exampleSentence: "我需要新内衣。", examplePinyin: "Wǒ xūyào xīn nèiyī.", exampleTranslation: "I need new underwear. / J'ai besoin de nouvelles bobettes."),
            Flashcard(chinese: "不要放弃", pinyin: "bù yào fàngqì", english: "Don't give up/Hang in there", french: "Lâche pas la patate", pronunciation: "boo-yow-fahng-chee", category: "Quebecois", difficulty: 2, exampleSentence: "不要放弃，你会成功的！", examplePinyin: "Bù yào fàngqì, nǐ huì chénggōng de!", exampleTranslation: "Don't give up, you'll succeed! / Lâche pas la patate, tu vas réussir !"),
    
            Flashcard(chinese: "钱", pinyin: "qián", english: "Money", french: "Piastre", pronunciation: "chee-an", category: "Quebecois", difficulty: 2, exampleSentence: "这个要一百块钱。", examplePinyin: "Zhège yào yībǎi kuài qián.", exampleTranslation: "It costs a hundred bucks. / Ça coûte cent piastres."),
            Flashcard(chinese: "喝酒", pinyin: "hējiǔ", english: "To drink/party", french: "Prendre un coup", pronunciation: "huh-jyo", category: "Quebecois", difficulty: 2, exampleSentence: "我们今晚去喝酒。", examplePinyin: "Wǒmen jīnwǎn qù hējiǔ.", exampleTranslation: "We're going to drink tonight. / On va prendre un coup à soir."),
            Flashcard(chinese: "白痴", pinyin: "báichī", english: "Idiot/Dummy", french: "Nono", pronunciation: "bai-chih", category: "Quebecois", difficulty: 2, exampleSentence: "别做白痴了！", examplePinyin: "Bié zuò báichī le!", exampleTranslation: "Stop acting like an idiot! / Arrête d'être un nono !"),
            Flashcard(chinese: "厕所", pinyin: "cèsuǒ", english: "Bathroom/Toilet", french: "Bécosse", pronunciation: "tsuh-swaw", category: "Quebecois", difficulty: 2, exampleSentence: "厕所在哪里？", examplePinyin: "Cèsuǒ zài nǎlǐ?", exampleTranslation: "Where's the bathroom? / Où est la bécosse ?"),
           
           
              
        ]
    }

    func markCardSeen(_ card: Flashcard) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].seen = true
            invalidateCaches() // Invalidate caches when seen status changes
            
            // Force SwiftUI to update by triggering objectWillChange
            objectWillChange.send()
            
            saveCards()
        }
    }

    // MARK: - Data Management Methods
    func importCards(_ newCards: [Flashcard]) {
        cards.append(contentsOf: newCards)
        invalidateCaches()
        updateCategories()
        saveCards()
        objectWillChange.send()
    }
    
    func resetAllProgress() {
        for index in cards.indices {
            cards[index].seen = false
            cards[index].isFavorite = false
            cards[index].reviewCount = 0
            cards[index].lastReviewed = nil
            cards[index].nextReviewDate = nil
            cards[index].difficultyLevel = 1
            cards[index].streakCount = 0
        }
        

        
        invalidateCaches()
        saveCards()
        objectWillChange.send()
    }
    

    
    func getCardsForReview() -> [Flashcard] {
        let now = Date()
        return cards.filter { card in
            card.seen && (card.nextReviewDate == nil || card.nextReviewDate! <= now)
        }
    }
    
    func updateCardDifficulty(_ card: Flashcard, wasCorrect: Bool) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            if wasCorrect {
                cards[index].streakCount += 1
                cards[index].difficultyLevel = min(5, cards[index].difficultyLevel + 1)
            } else {
                cards[index].streakCount = 0
                cards[index].difficultyLevel = max(1, cards[index].difficultyLevel - 1)
            }
            
            cards[index].reviewCount += 1
            cards[index].lastReviewed = Date()
            
            // Calculate next review date based on spaced repetition
            let interval = calculateNextReviewInterval(for: cards[index])
            cards[index].nextReviewDate = Calendar.current.date(byAdding: .day, value: interval, to: Date())
            
            invalidateCaches()
            saveCards()
            objectWillChange.send()
        }
    }
    
    private func calculateNextReviewInterval(for card: Flashcard) -> Int {
        // Simple spaced repetition algorithm
        let baseInterval = card.difficultyLevel
        let streakMultiplier = min(card.streakCount, 5)
        return baseInterval * (1 + streakMultiplier)
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
