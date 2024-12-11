import UIKit

var totalCorrectAnswers: Int = 0
var totalQuestion: Int = 0

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    struct viewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBAction private func noButton(_ sender: Any) {
    }
    @IBAction private func yesButton(_ sender: Any) {
    }
    
    private var correctAnswers: Int = 0

    
    private var alertPresenter: AlertPresenter?

    private var currentQuestionIndex: Int = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    private var isButtonEnabled = true

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(viewController: self)
            
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
                
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool){
        guard isButtonEnabled else { return }
        isButtonEnabled = false
        
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.isButtonEnabled = true
            self.showNextQuestionOrResult()
        }
    }
    
    private func showNextQuestionOrResult() {
            if currentQuestionIndex == questionsAmount - 1 {
                statisticService.store(correct: correctAnswers, total: questionsAmount)
                
                let bestGame = statisticService.bestGame
                let formattedDate = statisticService.formatDate(bestGame.date)
                let accuracyText = String(format: "%.2f", statisticService.totalAccuracy * 100)
                let recordText = """
                Количество сыгранных квизов:: \(statisticService.gamesCount)
                Рекорд: \(bestGame.correct)/\(bestGame.total) (\(formattedDate))
                Средняя точность: \(accuracyText)%
                """
                
                let resultText = correctAnswers == questionsAmount
                    ? "Поздравляем, вы ответили на 10 из 10!"
                    : "Ваш результат \(correctAnswers)/10"
                
                let viewModel = QuizResultViewModel(
                    title: "Этот раунд окончен!",
                    text: "\(resultText)\n\n\(recordText)",
                    buttonText: "Сыграть ещё раз"
                )
                show(quiz: viewModel)
            } else {
                currentQuestionIndex += 1
                questionFactory?.requestNextQuestion()
            }
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
        }
        
        private func convert(model: QuizQuestion) -> QuizStepViewModel {
            QuizStepViewModel(
                image: UIImage(named: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
            )
        }
    
    private func resetGameStats() {
        correctAnswers = 0
        currentQuestionIndex = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func show(quiz result: QuizResultViewModel) {
        let alertModel = alertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                self.resetGameStats()
                self.questionFactory?.requestNextQuestion()
            }
        )
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
        
        alertPresenter?.presentAlert(with: alertModel)
    }
    
    // MARK: - Button Actions
    @IBAction private func yesButtonClicked_(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }
    @IBAction func noButtonClicked_(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
}



/*
 Mock-данные
 
 
 Картинка / image: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос / question: Рейтинг этого фильма больше чем 6?
 Ответ / button: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
